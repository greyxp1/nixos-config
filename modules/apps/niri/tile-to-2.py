#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ---------------------------------------------------------------------------------------------------------------------
# %% Imports

import argparse
import json
import os
import signal
import socket
from collections import deque
from dataclasses import dataclass
from time import perf_counter, sleep

# ---------------------------------------------------------------------------------------------------------------------
# %% Args

# Set built-in defaults (helpful for debugging)
default_N = 3
default_delay_ms = 1000 if perf_counter() < 5 else 0
default_maximize_solos = True
default_maximize_solo_on_close = True
default_collapse_solos_on_open = True
default_apply_on_move = False
default_debug_names = False
default_debug_data = False

# Define script arguments
parser = argparse.ArgumentParser(
    description="Script which makes niri behave like an auto-tiler when there are fewer than 'N' windows"
)
parser.add_argument(
    "-n",
    default=default_N,
    type=int,
    help=f"Number of windows handled with auto-tiling (default {default_N})",
)
parser.add_argument(
    "-delay",
    default=default_delay_ms,
    type=int,
    help=f"Number of milliseconds to delay before listening to niri IPC (default: {default_delay_ms})",
)
parser.add_argument(
    "-x",
    action="store_false" if default_maximize_solos else "store_true",
    help=f"Auto-maximize first window opened on a workspace (default: {default_maximize_solos})",
)
parser.add_argument(
    "-xc",
    action="store_false" if default_maximize_solo_on_close else "store_true",
    help=f"When closing windows, if one window remains, auto-maximize it (default: {default_maximize_solo_on_close})",
)
parser.add_argument(
    "-c",
    action="store_false" if default_collapse_solos_on_open else "store_true",
    help=f"Collapse solo maximized window when opening a second window (default: {default_collapse_solos_on_open})",
)
parser.add_argument(
    "-m",
    action="store_false" if default_apply_on_move else "store_true",
    help=f"Apply tiling logic to windows that are moved into other workspaces (default: {default_apply_on_move})",
)
parser.add_argument(
    "-e",
    "--maximize_to_edges",
    action="store_true",
    help="Use maximize-to-edges instead of maximize-column",
)
parser.add_argument(
    "-dn",
    action="store_false" if default_debug_names else "store_true",
    help="Enable event name printing, for debugging",
)
parser.add_argument(
    "-dd",
    action="store_false" if default_debug_data else "store_true",
    help="Enable event data printing, for debugging",
)
parser.add_argument(
    "-iw",
    type=int,
    action="append",
    help="Ignore workspace with this id (can be specified multiple times)",
)

# Get script configs
args, _ = parser.parse_known_args()
TILE_TO_N = args.n
STARTUP_DELAY_MS = args.delay
MAXIMIZE_SOLOS = args.x
MAXIMIZE_SOLOS_ON_CLOSE = args.xc
COLLAPSE_SOLOS_ON_OPEN = args.c
APPLY_TO_MOVED_WINDOWS = args.m
USE_MAX_TO_EDGES = args.maximize_to_edges
ENABLE_EVENT_NAME_DEBUG_PRINT = args.dn
ENABLE_EVENT_DATA_DEBUG_PRINT = args.dd
# Use frozenset for O(1) membership tests
IGNORED_WORKSPACE_IDS: frozenset[int] = frozenset(args.iw or [])

# ---------------------------------------------------------------------------------------------------------------------
# %% Data types


@dataclass
class TimeKeeper:
    t1: int = 0
    t2: int = 0

    def get_time_elapsed_ms(self) -> int:
        """Reports the time (in ms) since the last time this function was called"""
        self.t1 = self.t2
        self.t2 = round(perf_counter() * 1000)
        return self.t2 - self.t1


@dataclass
class FocusState:
    workspace_id: int | None = None
    window_id: int | None = None

    def copy_inplace(self, other: "FocusState") -> "FocusState":
        """Overwrite current data with data from another object (avoids creating new instances)"""
        self.workspace_id = other.workspace_id
        self.window_id = other.window_id
        return self


# ---------------------------------------------------------------------------------------------------------------------
# %% Classes


class NiriSocket:
    """Helper used to read & write json messages to a niri socket connection"""

    def __init__(self, socket_path: str, buffer_size: int = 4096):

        # Sanity check
        assert socket_path, "Cannot connect to niri, no socket path given..."

        self._skt = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self._skt.connect(socket_path)  # FIX: was accidentally using global `skt_path`
        self._bufsize = buffer_size

        self._msg_queue: deque[str] = deque()
        self._inprog_str: str | None = None

    def _read_next(self) -> dict:

        # Read from existing (buffered) messages, if any
        if self._msg_queue:
            return json.loads(self._msg_queue.popleft())

        while True:
            # Listen for raw (binary) string data from socket
            # -> Will return 0 bytes if connection closes
            resp_binstr = self._skt.recv(self._bufsize)
            if not resp_binstr:
                print("DEBUG - READNEXT: No data received!")
                return {}

            # If we have an in-progress result, prepend it to the new data
            resp_str = resp_binstr.decode("utf-8")
            if self._inprog_str is not None:
                resp_str = self._inprog_str + resp_str
                self._inprog_str = None

            # Stop listening if we got at least 1 complete message.
            # Expect: "message 1\nmessage 2\n..." — incomplete tail has no trailing \n.
            msg_list = resp_str.split("\n")
            last_piece = msg_list.pop()
            self._inprog_str = last_piece if last_piece else None
            if msg_list:
                break

        if not msg_list:
            raise IOError("Error reading next message (empty message list)!")

        # Return first message; queue the rest for subsequent calls
        out_msg_str = msg_list[0]
        if len(msg_list) > 1:
            self._msg_queue.extend(msg_list[1:])

        return json.loads(out_msg_str)

    def _send_string(self, string: str) -> None:
        """Helper used to send simple string messages (e.g. for requests)"""
        self._skt.sendall(f'"{string}"\n'.encode("utf-8"))

    def _send_json(self, json_data: dict) -> None:
        """Helper used to send json messages (e.g. for actions)"""
        payload = json.dumps(json_data, indent=None, separators=(",", ":")) + "\n"
        self._skt.sendall(payload.encode("utf-8"))

    def close(self) -> None:
        self._skt.close()

    @staticmethod
    def get_niri_socket_path() -> str | None:
        return os.environ.get("NIRI_SOCKET")


class NiriRequests(NiriSocket):
    """
    Helper used to make requests to niri.
    See: https://yalter.github.io/niri/niri_ipc/enum.Request.html
    """

    def get_version(self):
        return self.request("Version")

    def request(self, message: str) -> tuple[bool, dict]:
        self._send_string(message)
        resp_json = self._read_next()
        is_ok = "Ok" in resp_json
        return is_ok, resp_json["Ok" if is_ok else "Err"]

    def read_eventstream(self):
        is_ok, evt_resp = self.request("EventStream")
        if not is_ok:
            print("DEBUG - EventStream response:", evt_resp, sep="\n")
            raise IOError("Error requesting EventStream")

        while True:
            event_json = self._read_next()
            event_name = next(iter(event_json))
            yield event_name, event_json.get(event_name)


class NiriActions(NiriSocket):
    """
    Helper used to trigger actions through the niri IPC.
    See: https://yalter.github.io/niri/niri_ipc/enum.Action.html
    """

    def action(self, message: str, **kwargs) -> tuple[bool, dict]:
        self._send_json({"Action": {message: kwargs}})
        resp_json = self._read_next()
        is_ok = "Err" not in resp_json
        return is_ok, resp_json if is_ok else resp_json["Err"]


# ---------------------------------------------------------------------------------------------------------------------
# %% Functions


def catch_sigterm(signum, frame):
    """Turn SIGTERM events into exceptions for graceful shutdown"""
    raise InterruptedError


def make_workspace_state_from_WorkspacesChanged(
    event_data: dict | None,
) -> dict[int, dict]:
    """Create a mapping of workspace id -> workspace info from a WorkspacesChanged event.

    The event stream can sometimes yield None or unexpected payloads; guard against that
    to keep callers and static analysis happy.
    """
    if not event_data:
        return {}
    workspaces = event_data.get("workspaces") or []
    return {info["id"]: info for info in workspaces}


def make_window_state_from_WindowsChanged(
    event_data: dict | None, workspace_state: dict | None, output_width_lut: dict | None
) -> dict[int, dict]:
    """Create a mapping of window id -> window info from a WindowsChanged event.

    Guard against None payloads for robustness and static-analysis friendliness.
    """
    state: dict[int, dict] = {}
    if not event_data:
        return state
    for info_dict in event_data.get("windows", []):
        win_id = info_dict["id"]
        info_dict.update(
            get_additional_window_data(
                info_dict, workspace_state or {}, output_width_lut or {}
            )
        )
        state[win_id] = info_dict
    return state


def get_windows_by_conditions(
    window_state: dict[int, dict], **conditions
) -> dict[int, dict]:
    """Filter window state data according to key-value conditions"""
    return {
        wid: wdata
        for wid, wdata in window_state.items()
        if all(wdata[k] == v for k, v in conditions.items())
    }


def get_additional_window_data(
    window_data: dict,
    workspace_state: dict | None,
    output_width_lut: dict | None,
    max_width_threshold: float = 0.8,
) -> dict:
    """Generate additional window data (particularly the 'is_maximized' flag)."""
    # Ensure we have dicts to call `.get` on
    workspace_state = workspace_state or {}
    output_width_lut = output_width_lut or {}

    # Be defensive when accessing nested fields coming from IPC
    win_pos = window_data.get("layout", {}).get("pos_in_scrolling_layout")
    win_col, win_row = win_pos if win_pos is not None else (None, None)
    augment = {
        "col_idx": win_col,
        "row_idx": win_row,
        "is_maximized": False,
    }

    win_wspace_id = window_data.get("workspace_id")
    win_output = workspace_state.get(win_wspace_id, {}).get("output")
    output_width = output_width_lut.get(win_output)
    if output_width is not None:
        win_width = window_data.get("layout", {}).get("window_size", [0, 0])[0]
        augment["is_maximized"] = (win_width / output_width) > max_width_threshold

    return augment


def toggle_window_maximization(
    target_window_id: int, focused_window_id: int | None
) -> None:
    """Toggle the maximization state of a window without disturbing the focused window"""
    max_action = "MaximizeWindowToEdges" if USE_MAX_TO_EDGES else "MaximizeColumn"
    if target_window_id == focused_window_id:
        niri_action.action(max_action)
    else:
        niri_action.action("FocusWindow", id=target_window_id)
        niri_action.action(max_action)
        niri_action.action("FocusWindow", id=focused_window_id)


def maximize_window(
    window_state: dict, focus_state: FocusState, target_window_id: int
) -> bool:
    """
    Maximize a window if it's not already maximized.
    Requires window state to include the 'is_maximized' flag.
    Returns True if maximization was applied.
    """
    solo_win_data = window_state[target_window_id]
    if solo_win_data["is_maximized"]:
        return False
    toggle_window_maximization(solo_win_data["id"], focus_state.window_id)
    window_state[target_window_id]["is_maximized"] = (
        True  # FIX: was using global win_state
    )
    return True


def collapse_window(
    window_state: dict, focus_state: FocusState, target_window_id: int
) -> bool:
    """
    Collapse a maximized window.
    Requires window state to include the 'is_maximized' flag.
    Returns True if collapse was applied.
    """
    solo_win_data = window_state[target_window_id]
    if not solo_win_data["is_maximized"]:
        return False
    toggle_window_maximization(solo_win_data["id"], focus_state.window_id)
    window_state[target_window_id]["is_maximized"] = (
        False  # FIX: was using global win_state
    )
    return True


# ---------------------------------------------------------------------------------------------------------------------
# %% Setup

# Handle startup delay (prevent listening to niri during potentially busy startup)
if STARTUP_DELAY_MS > 0:
    sleep(STARTUP_DELAY_MS / 1000)

# Get niri socket from env
skt_path = NiriSocket.get_niri_socket_path()
if not skt_path:
    print("Couldn't find niri socket! (from env: NIRI_SOCKET)")
    quit()

# Create separate read/write sockets since the eventstream reader cannot issue actions
niri_reader = NiriRequests(skt_path)
niri_action = NiriActions(skt_path)

# Sanity check: make sure we have the expected niri version
is_version_ok, version_resp = niri_reader.request("Version")
expected_version = "25.11 (b35bcae)"
actual_version = version_resp.get("Version", "unknown")
if actual_version != expected_version:
    print(
        "",
        "WARNING - Unexpected niri version!",
        f"expected: {expected_version}",
        f"  actual: {actual_version}",
        "Errors may occur...",
        sep="\n",
    )


# ---------------------------------------------------------------------------------------------------------------------
# %% *** IPC listening loop ***

# Get monitor info
is_outputs_ok, outputs_resp = niri_reader.request("Outputs")
if not is_outputs_ok:
    print("Error requesting info about monitors", outputs_resp, sep="\n")
    quit()

output_width_lut: dict[str, int] = {
    key: info["logical"]["width"]
    for key, info in outputs_resp["Outputs"].items()
    if info.get("logical") is not None
}

# Initialize state tracking
prev_focus_state = FocusState()
focus_state = FocusState()
timekeeper = TimeKeeper()
# Initialize as empty mappings to avoid None-value errors reported by static analysis
win_state: dict[int, dict] = {}
wspace_state: dict[int, dict] = {}

# Main listening loop
signal.signal(signal.SIGTERM, catch_sigterm)
try:
    init_time = timekeeper.get_time_elapsed_ms()
    for evt_name, evt_data in niri_reader.read_eventstream():
        # Some event tuples may include a None payload; ignore these early to make
        # the rest of the loop simpler and satisfy static analysis.
        if evt_data is None:
            continue

        # Debug printout with spacing between event bursts
        time_elapsed_ms = timekeeper.get_time_elapsed_ms()
        if ENABLE_EVENT_NAME_DEBUG_PRINT or ENABLE_EVENT_DATA_DEBUG_PRINT:
            if time_elapsed_ms > 250:
                print(
                    "",
                    f"Time elapsed (sec): {(timekeeper.t2 - init_time) // 1000}",
                    sep="\n",
                )
            if ENABLE_EVENT_NAME_DEBUG_PRINT:
                print(evt_name)
            if ENABLE_EVENT_DATA_DEBUG_PRINT:
                print(evt_data)

        prev_focus_state.copy_inplace(focus_state)
        closed_window_data, newest_window_data = None, None

        match evt_name:
            case "WorkspacesChanged":
                wspace_state = make_workspace_state_from_WorkspacesChanged(evt_data)
                for item in wspace_state.values():
                    if item["is_focused"]:
                        focus_state.workspace_id = item["id"]

            case "WorkspaceUrgencyChanged":
                wspace_state[evt_data["id"]]["is_urgent"] = evt_data["urgent"]

            case "WorkspaceActivated":
                if evt_data["focused"]:
                    focus_state.workspace_id = evt_data["id"]
                    # Guard: prev workspace may be None on first activation
                    if prev_focus_state.workspace_id is not None:
                        wspace_state[prev_focus_state.workspace_id]["is_focused"] = (
                            False
                        )

            case "WorkspaceActiveWindowChanged":
                pass  # Unused

            case "WindowsChanged":
                win_state = make_window_state_from_WindowsChanged(
                    evt_data, wspace_state, output_width_lut
                )
                for item in win_state.values():
                    if item["is_focused"]:
                        focus_state.window_id = item["id"]

            case "WindowOpenedOrChanged":
                evt_win_id = evt_data["window"]["id"]
                evt_win_wspace_id = evt_data["window"]["workspace_id"]
                evt_is_new_window = evt_win_id not in win_state
                evt_is_moved_window = False
                if not evt_is_new_window:
                    prev_wspace_id = win_state[evt_win_id]["workspace_id"]
                    evt_is_moved_window = prev_wspace_id != evt_win_wspace_id

                if evt_data["window"]["is_focused"]:
                    focus_state.window_id = evt_win_id

                win_aug_data = get_additional_window_data(
                    evt_data["window"], wspace_state, output_width_lut
                )
                win_state[evt_win_id] = {**evt_data["window"], **win_aug_data}

                need_check = evt_is_new_window or (
                    evt_is_moved_window and APPLY_TO_MOVED_WINDOWS
                )
                newest_window_data = win_state[evt_win_id] if need_check else None

            case "WindowClosed":
                closed_window_data = win_state.pop(evt_data["id"])

            case "WindowFocusChanged":
                focus_state.window_id = evt_data["id"]

            case "WindowFocusTimestampChanged":
                win_state[evt_data["id"]]["focus_timestamp"] = evt_data[
                    "focus_timestamp"
                ]

            case "WindowUrgencyChanged":
                win_state[evt_data["id"]]["is_urgent"] = evt_data["urgent"]

            case "WindowLayoutsChanged":
                for evt_win_id, evt_new_layout in evt_data["changes"]:
                    win_state[evt_win_id]["layout"] = evt_new_layout
                    win_state[evt_win_id].update(
                        get_additional_window_data(
                            win_state[evt_win_id], wspace_state, output_width_lut
                        )
                    )

            case (
                "KeyboardLayoutsChanged"
                | "KeyboardLayoutSwitched"
                | "OverviewOpenedOrClosed"
                | "ConfigLoaded"
            ):
                pass  # Unused events

            case _:
                print("Unknown event:", evt_name)

        # Handle max-on-close
        if closed_window_data is not None and MAXIMIZE_SOLOS_ON_CLOSE:
            curr_wspace_id = closed_window_data["workspace_id"]
            curr_wins = get_windows_by_conditions(
                win_state, workspace_id=curr_wspace_id, is_floating=False
            )
            if len(curr_wins) == 1:
                solo_id = next(iter(curr_wins))
                maximize_window(win_state, focus_state, solo_id)

        # Handle window-creation behaviors
        if newest_window_data is None:
            continue

        # Skip maximized or floating windows — don't interfere with user window rules
        if newest_window_data["is_maximized"] or newest_window_data["is_floating"]:
            continue

        curr_wspace_id = newest_window_data["workspace_id"]

        if IGNORED_WORKSPACE_IDS and curr_wspace_id in IGNORED_WORKSPACE_IDS:
            print(f"Ignored event on workspace {curr_wspace_id}")
            continue

        curr_tile_wins = get_windows_by_conditions(
            win_state, workspace_id=curr_wspace_id, is_floating=False
        )
        num_tile_wins = len(curr_tile_wins)
        if num_tile_wins == 0 or num_tile_wins > TILE_TO_N:
            continue

        # Auto-maximize solo windows
        if MAXIMIZE_SOLOS and num_tile_wins == 1:
            solo_id = next(iter(curr_tile_wins))
            maximize_window(win_state, focus_state, solo_id)

        # Collapse previously maximized window when a second opens
        curr_max_wins = get_windows_by_conditions(curr_tile_wins, is_maximized=True)
        num_max_wins = len(curr_max_wins)
        if COLLAPSE_SOLOS_ON_OPEN and num_max_wins == 1 and num_tile_wins == 2:
            solo_max_id = next(iter(curr_max_wins))
            collapse_window(win_state, focus_state, solo_max_id)
            num_max_wins -= 1

        # Apply tiling for 3+ windows when none are maximized
        if num_max_wins == 0 and 2 < num_tile_wins <= TILE_TO_N:
            is_new_win_onscreen = newest_window_data["col_idx"] == 2
            consume_action = (
                "ConsumeOrExpelWindowRight"
                if is_new_win_onscreen
                else "ConsumeOrExpelWindowLeft"
            )
            niri_action.action(consume_action, id=newest_window_data["id"])

except (KeyboardInterrupt, InterruptedError):
    pass

finally:
    niri_action.close()
    niri_reader.close()
    print("", f"({os.path.basename(__file__)}) - Closed niri IPC connection", sep="\n")

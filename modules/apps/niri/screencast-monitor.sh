#!/usr/bin/env bash
dbus-monitor --session \
    "type='method_call',interface='org.freedesktop.portal.ScreenCast',member='Start'" \
    2>/dev/null |
awk '/method call/ { system("niri msg action set-dynamic-cast-monitor"); fflush() }'

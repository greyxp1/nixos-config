{ ... }:
{
  flake.nixosModules.easyeffects =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.networking.hostName == "main-pc") {
        environment.systemPackages = with pkgs; [ easyeffects ];

        home-manager.users.grey =
          { ... }:
          {
            services.easyeffects.enable = true;

            xdg.configFile = {
              "easyeffects/db/easyeffectsrc".text = ''
                [StreamInputs]
                inputDevice=alsa_input.usb-Audio-Technica_AT2005USB-00.analog-stereo
                plugins=rnnoise#0

                [StreamOutputs]
                outputDevice=alsa_output.usb-Audio-Technica_AT2005USB-00.analog-stereo
                plugins=equalizer#0

                [Window]
                showTrayIcon=false
              '';

              "easyeffects/db/equalizerrc".text = ''
                [soe][Equalizer#0]
                inputGain=-8.61
                numBands=10
                outputGain=-6.8

                [soe][Equalizer#0#left]
                band0Frequency=105
                band0Gain=9.800000190734863
                band0Mode=6
                band0Q=0.699999988079071
                band0Type=5
                band1Frequency=55.29999923706055
                band1Gain=-3.4000000953674316
                band1Mode=6
                band1Q=0.9399999976158142
                band2Frequency=81.4000015258789
                band2Gain=-6.400000095367432
                band2Mode=6
                band2Q=0.6700000166893005
                band3Frequency=236.8000030517578
                band3Gain=2.799999952316284
                band3Mode=6
                band3Q=2.450000047683716
                band4Frequency=1776.300048828125
                band4Gain=-0.5
                band4Mode=6
                band4Q=0.7599999904632568
                band5Frequency=2064.10009765625
                band5Gain=-3.5
                band5Mode=6
                band5Q=0.7400000095367432
                band6Frequency=3882.300048828125
                band6Gain=5.699999809265137
                band6Mode=6
                band6Q=3.109999895095825
                band7Frequency=5437.89990234375
                band7Gain=9
                band7Mode=6
                band7Q=2.0299999713897705
                band8Frequency=6644.60009765625
                band8Gain=-4.300000190734863
                band8Mode=6
                band8Q=5.960000038146973
                band9Frequency=10000
                band9Gain=-0.8999999761581421
                band9Mode=6
                band9Q=0.699999988079071
                band9Type=3

                [soe][Equalizer#0#right]
                band0Frequency=105
                band0Gain=9.800000190734863
                band0Mode=6
                band0Q=0.699999988079071
                band0Type=5
                band1Frequency=55.29999923706055
                band1Gain=-3.4000000953674316
                band1Mode=6
                band1Q=0.9399999976158142
                band2Frequency=81.4000015258789
                band2Gain=-6.400000095367432
                band2Mode=6
                band2Q=0.6700000166893005
                band3Frequency=236.8000030517578
                band3Gain=2.799999952316284
                band3Mode=6
                band3Q=2.450000047683716
                band4Frequency=1776.300048828125
                band4Gain=-0.5
                band4Mode=6
                band4Q=0.7599999904632568
                band5Frequency=2064.10009765625
                band5Gain=-3.5
                band5Mode=6
                band5Q=0.7400000095367432
                band6Frequency=3882.300048828125
                band6Gain=5.699999809265137
                band6Mode=6
                band6Q=3.109999895095825
                band7Frequency=5437.89990234375
                band7Gain=9
                band7Mode=6
                band7Q=2.0299999713897705
                band8Frequency=6644.60009765625
                band8Gain=-4.300000190734863
                band8Mode=6
                band8Q=5.960000038146973
                band9Frequency=10000
                band9Gain=-0.8999999761581421
                band9Mode=6
                band9Q=0.699999988079071
                band9Type=3
              '';

              "easyeffects/db/rnnoiserc".text = ''
                [sie][RNNoise#0]
                enableVad=true
                vadThres=85
              '';

              "easyeffects/db/graphrc".text = ''
                [Graph]
                colorTheme=qtGreen
              '';
            };
          };
      };
    };
}

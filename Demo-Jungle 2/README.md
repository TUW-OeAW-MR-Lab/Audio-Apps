# Demo Jungle 2

## Desciption
Typical sources in a jungle atmosphere
- channels 1-11 (11 channels): birds.wav
- channels 12-29 (18 channels): rain.wav
- channels 30-53 (24 channels): thunderstorm.wav
- channels 54-71 (18 channels): rain2.wav
- channels 72-98 (27 channels): frogs.wav
- channels 99-126 (28 channels): crickets.wav

## Spatialize Demo
- prepare your multichannel file 'Data\merged_sources.wav' (eg. Matlab or Audacity)
	- use Audacity to create wav files with up to 64 channels; Matlab can create a larger number of channels in one file
- use Matlab to merge these wav files to one single file (MergeSources.m)
- adapt and use random_position.m to assign random ranges (azimuth, elevation) for specific channels (stationary, moving)

## Play Demo
- run batch file _OPEN DEMO.bat (opened with pd)
- press green button to start demo
- optional: use light green buttons to start delayed, or to enable loop
- orange fader (left) controls volume
- demo can be combined with demo "realtime reverb" (Mix 1 configuration)
- press red "stop" button to stop demo, or close all pd windows
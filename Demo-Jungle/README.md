# Demo Jungle

## Description
Typical sources in a jungle atmosphere
- Sources  1-11: birds
- Sources 12-29: rain
- Sources 30-53: thunderstorm
- Sources 54-71: rain
- Sources 72-: frogs
- Sources : crickets
- Sources : creek

## Spatialize Demo
- prepare your multichannel source wav files in \Data folder (eg. with Audacity)
- adapt and use script MergeSources.m to merge these files to one single multichannel wav file
- adapt and use random_position.m to assign random ranges (azimuth, elevation) for specific channels
- use startSPATIALIZE.m to spatialize sound

## Play Demo
### Standalone
- run batch file _OPEN DEMO.bat (opened with pd)
- press green "start" button to start demo
- optional: use light green buttons to start delayed, or to enable loop
- orange fader (left) controls volume
- demo can be combined with demo "realtime reverb" (Mix 1 configuration)
- press "stop" or close all Pd windows to stop demo
### OSC
- launch batch file _OPEN DEMO.bat
- use OSC commands to control demo
  
## OSC Commands
The app is listening to port 10003. The following commands can be used to communicate with Demo-Fly via OSC:
| Send | Receive | Description |
|-----|-----------|-----------|
|     /Control/Response connect localhost [value] | connect localhost [value] | connect to demo app and send return channel |
|     /Control/Version| /Control/Version [value]    | get version number    |
|     /Control/SampleRate| /Control/SampleRate [value]       | get sample rate       |
|     /Control/CPULoad| /Control/CPULoad [value]       | get current CPU load       |
|     /Play/Start| -       | start demo; trigger levels sent via OSC periodically      |
|     /Play/Stop| -       | stop demo; stop sending levels       |
|     - | /Play/VU [value]      | get VU (max level of all channels) (0..100 in dB)       |
|     /Play/Volume/Set [value] | -       | set volume of app (0..100 in dB)     |
|     /Play/Volume | /Play/Volume [value]       | get volume of app (0..100 in dB)      |
|     - |  /Play/Timecode [value]    | get time code      |
|     /Play/Duration |  /Play/Duration [value]     | get duration of demo      |

# Demo Fly

## Description
a fly circling around the room

## Spatialize Demo
- prepare your source wav file (fly.wav) in \Data folder
- use startSPATIALIZE.m to spatialize sound, adapt position and movement in script

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

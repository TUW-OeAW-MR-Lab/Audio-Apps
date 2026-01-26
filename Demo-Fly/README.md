# Demo Fly
## Description
a fly circling around the room
## Play Demo
- double click link to batch file
- press green button to start demo
- optional: use light green buttons to start delayed, or to enable loop
- orange fader (left) controls volume
- demo can be combined with demo “realtime reverb” (Mix 1 configuration)
- press “stop” or close all Pd windows to stop demo
## OSC Commands
The app is listening to port 10003. The following commands can be used to communicate with Demo-Fly via OSC:
| Send | Receive | Description |
|-----:|-----------|-----------|
|     /Control/Response connect localhost 9336 | connect localhost 9336 | connect to demo app and send return channel |
|     /Control/Version| /Control/Version v1.2    | get version number    |
|     /Control/SampleRate| /Control/SampleRate 48000       | get sample rate       |
|     /Control/CPULoad| /Control/CPULoad 10.94       | get current CPU load       |
|     /Play/Start| -       | start demo; trigger levels sent via OSC periodically      |
|     /Play/Stop| -       | stop demo; stop sending levels       |
|     /SetVol 55 | -       | set volume of app       |
|     - | /Level 32.48       | get level values (max level of all channels)       |

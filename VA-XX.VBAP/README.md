# Virtual Audio: VBAP

**!!! STILL UNDER DEVELOPMENT !!!**

## Description
- vector-based amplitude panning
- XX defines the doors (open/closed -> CC/CO/OC/OO)
- based on VBAP and VBAP200, ExpSuite package

## Launch Scene
- launch batch file _LAUNCH SCENE.bat
- use OSC commands to control VBAP

## OSC Commands
The app is listening to port 10003. The following commands can be used to communicate via OSC:
| Send | Receive | Description | Example |
|-----|-----------|-----------|-----------|
|     /Control/Response connect localhost [value] | connect localhost [value] | connect to demo app and send return channel | |
|     /Control/Version| /Control/Version [value]    | get version number    | |
|     /Control/SampleRate| /Control/SampleRate [value]       | get sample rate       | |
|     /Control/CPULoad| /Control/CPULoad [value]       | get current CPU load       | |
|     /VBAP/SetStream/[VBAP object] set [source] | -       | link a source to a VBAP object      | /VBAP/SetStream/0 set adc0 |
|     /VBAP/Switch/[VBAP object] [value] | -       | switch VBAP object on (1) or off (0)      | /VBAP/Switch/0 1 |
|     /VBAP/SetVol/[VBAP object] [value] | -       | set volume for VBAP object      | /VBAP/SetVol/0 100 |
|     /VBAP/SetDirection/[VBAP object] [A value] [E value] | -       | set azimuth and elevation for VBAP object      | /VBAP/SetDirection/0 90 45 |
|     - | /Play/VU [value]      | get VU (max level of all channels) (0..100 in dB)       | |

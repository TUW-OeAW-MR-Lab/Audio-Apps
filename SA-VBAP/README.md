# Spatial Audio: VBAP

**!!! STILL UNDER DEVELOPMENT !!!**

## Description
- Spatialization of virtual sources by means of the vector-based amplitude panning.
- The state of the doors can be defined on-the-fly: open (O) or closed (C). Allowed states: CC, CO, OC, OO.
- Based on VBAP and VBAP200, ExpSuite package.

## Launch Scene
- Launch batch file _LAUNCH SCENE.bat;
- Use OSC commands to control the parameters;
- Each virtual source with the index _index_ is linked to an incoming audio channel of MADI 1 (_index_ = [0..31]) and MADI 2 (_index_ = [31..63]).
- The spatialized signals are output to the 184 broadband loudspeakers;
- The spatialized signals are also summed up, low-pass filtered at 120 Hz, and output to the 16 subwoofers;

## OSC Commands
The app is listening to port 10003. The following commands can be used to communicate via OSC:
| Send | Response | Description | Example |
|-----|-----------|-----------|-----------|
|     /Control/Response connect localhost _port_ | connect localhost _port_ | connect the OSC response channel with the master listening at _port_ | /Control/Response connect localhost 10005 |
|     /Control/Version| /Control/Version _string_ | get version number | /Control/Version 1.2.0 |
|     /Control/SampleRate| /Control/SampleRate _value_ | get sample rate (_value_ in Hz) | /Control/SampleRate 48000 |
|     /Control/CPULoad| /Control/CPULoad _value_ | get current CPU load (_value_ in %) | /Control/CPULoad 5.73 |
|     /Control/Door| /Control/Door _string_ | get current door configuration, with _string_ = { OO, OC, CO, CC} | /Control/Door OO |
|     /Control/Door/Set _door_| - | set current door configuration: _door_ = {OO, OC, CO, CC}  |  /Control/Door/Set CC |
|     /VirtualSource/_index_/Position/Set _x y z_ | - | set the position of the virtual source #_index_ with _x, y, z_ in meter | /VirtualSource/0/Position/Set 5 2 1.5  |
|     /VirtualSource/_index_/Volume/Set _volume_ | - | set the volume of the virtual source #_index_ with _volume_ in dB (0...100) | /VirtualSource/5/Volume/Set 70  |
|     /VirtualSource/_index_/Volume | /VirtualSource/_index_/Volume _volume_ | get the volume of the virtual source #_index_ with _volume_ in dB (0...100) | /VirtualSource/12/Volume 45 |
|     /VirtualSource/_index_/Switch/ _value_ | - | switch the virtual source #_index_ off and on with _value_ = { 0, 1}, respectively | /VBAP/Switch/0 1 |
|     /Total/Volume/Set _volume_ | - | set the total volume of app with _volume_ = [0..100] in dB | /Total/Volume/Set 65 | 
|     /Total/Volume | /Total/Volume _volume_ | get the total volume of app with _volume_ = [0..100] in dB | /Total/Volume 50 | 
|     - | /Total/VU _VU_ | get the instantanous maximual level across all loudspeakers, with _VU_ = [0..100] in dB | /Total/VU 25.12345 |


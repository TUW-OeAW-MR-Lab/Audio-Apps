# Stereo Walls

**!!! STILL UNDER DEVELOPMENT !!!**

## Description
- Plays a stereo signal over various sections of loudspeakers along the walls.
- The left channel is routed to the loudspeakers along the north wall
- The right channel is routed to the loudspeakers along the south wall
- The following loudspeaker section can be controlled independently
  - Curved LED: Speakers attached at the curved LED
  - Curved Door: Speakers at the doors near the curved LED
  - Spatial Audio: Speakers at the walls in the spatial-audio area
  - CAVE Door: Speakers at the doors near the CAVE
  - CAVE: Speakers attached within the CAVE

## Launch Scene
- Launch batch file _LAUNCH SCENE.bat;
- Use OSC commands to control the parameters;
- The signals are also summed up, then low-pass filtered (at 120 Hz) and output to the 16 subwoofers;

## OSC Commands
The app is listening to port 10003. The following commands can be used to communicate via OSC:
| Send | Response | Description | Example |
|-----|-----------|-----------|-----------|
|     /Control/Response connect _ip_ _port_ | connect _ip_ _port_ | connect the OSC response channel with the master listening at _ip_ and _port_ | /Control/Response connect localhost 10005 |
|     /Control/Version | /Control/Version _string_ | get version number | /Control/Version 1.2.0 |
|     /Control/SampleRate | /Control/SampleRate _value_ | get sample rate (_value_ in Hz) | /Control/SampleRate 48000 |
|     /Control/CPULoad | /Control/CPULoad _value_ | get current CPU load (_value_ in %) | /Control/CPULoad 5.73 |
|     /Total/Volume/Set _volume_ | - | set the total volume of app with _volume_ = [0..100] in dB | /Total/Volume/Set 65 | 
|     /Total/Volume | /Total/Volume _volume_ | get the total volume of app with _volume_ = [0..100] in dB | /Total/Volume 50 | 
|     No command required, it will be sent every 100 ms | /Total/VU _VU_ | instantanous maximual level across all loudspeakers, with _VU_ = [0..100] in dB | /Total/VU 25.12345 |
|     /CurvedLED/Volume/Set _volume_ | - | set the volume of the Curved-LED section with _volume_ in dB (0...100) | /CurvedLED/Volume/Set 70  |
|     /CurvedLED/Volume | /CurvedLED/Volume _volume_ | get the volume of the Curved-LED section  with _volume_ in dB (0...100) | /CurvedLED/Volume 45 |
|     /CurvedLED/Switch _value_ | - | switch the Curved-LED section off and on with _value_ = { 0, 1}, respectively | /CurvedDoor/Switch 1 |
|     /CurvedDoor/Volume/Set _volume_ | - | set the volume of the Curved-door section with _volume_ in dB (0...100) | /CurvedDoor/Volume/Set 70  |
|     /CurvedDoor/Volume | /CurvedLED/Volume _volume_ | get the volume of the Curved-door section  with _volume_ in dB (0...100) | /CurvedDoor/Volume 45 |
|     /CurvedDoor/Switch _value_ | - | switch the Curved-door section off and on with _value_ = { 0, 1}, respectively | /CurvedDoor/Switch 1 |
|     /SA/Volume/Set _volume_ | - | set the volume of the spatial-audio section with _volume_ in dB (0...100) | /SA/Volume/Set 70  |
|     /SA/Volume | /SA/Volume _volume_ | get the volume of the spatial-audio section  with _volume_ in dB (0...100) | /SA/Volume 45 |
|     /SA/Switch _value_ | - | switch the spatial-audio section off and on with _value_ = { 0, 1}, respectively | /SA/Switch 1 |
|     /CAVEDoor/Volume/Set _volume_ | - | set the volume of the CAVE-door section with _volume_ in dB (0...100) | /CAVEDoor/Volume/Set 70  |
|     /CAVEDoor/Volume | /CAVEDoor/Volume _volume_ | get the volume of the CAVE-door section  with _volume_ in dB (0...100) | /CAVEDoor/Volume 45 |
|     /CAVEDoor/Switch _value_ | - | switch the CAVE-door section off and on with _value_ = { 0, 1}, respectively | /CAVEDoor/Switch 1 |
|     /CAVE/Volume/Set _volume_ | - | set the volume of the CAVE section with _volume_ in dB (0...100) | /CAVE/Volume/Set 70  |
|     /CAVE/Volume | /CAVE/Volume _volume_ | get the volume of the CAVE section  with _volume_ in dB (0...100) | /CAVE/Volume 45 |
|     /CAVE/Switch _value_ | - | switch the CAVE section off and on with _value_ = { 0, 1}, respectively | /CAVECAVEDoor/Switch 1 |



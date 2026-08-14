# Cave: VBAP

!!! STILL UNDER DEVELOPMENT, NOT WORKING YET !!!

## Description
- Spatialization of virtual sources by means of the vector-based amplitude panning.
- Based on SA-VBAP and VBAP200, ExpSuite package.

## Launch Scene
- Launch batch file _LAUNCH SCENE.bat;
- Use OSC commands to control the parameters;
- Each virtual source with the index _index_ is linked to an incoming audio channel of MADI 1 (_index_ = [0..31]) and MADI 2 (_index_ = [31..63]).
- The spatialized signals are output to the 16 broadband loudspeakers;

## How to test
- On the tablet (= system control), "Control" scene, switch on the PDU and unmute the amps. Check if the amp status is "green" (i.e., unmuted).
- On the Curved LED PC (= virtual sound source control):
  - Start audio playback via an app, e.g., Youtube in a browser window, and set the volume to a moderate volume.
  - Go to "Open Volume Mixer" (right click on the loudspeaker icon in the right part of the taskbar):
    - In the System section, select the Output device "DVS Transmit 3-4 (Dante Virtual Sound Card" and set the Volume slider to 0 dB FS.
    - In the apps section, expand additional controls, select the Output device to the same as in the System section and set the Volume slider to 0 dB FS. 
- On the tablet, click on the scee "Spatial Audio: VBAP":
  - Click on "Launch App", wait until the status becomes "connected". If red "error" appears, click on Launch App again, until it works
  - In the Inputs section, click on "Curved LED PC: Test VBAP on Channel #3"
  - You should hear the audio coming from the center-top of the Spatial-Audio Area. Increase the volume slowly in your app on the Curved LED PC.
- For more control of the source position: On the Audio PC, in the taskbar, click on the "pd" icon with the title "DEBUG". This will open a window with a purple background. Click on one of the boxes below "virtual position" to position the virtual sound source. 

## OSC Commands
The app is listening to OSC port 10003: SYS (system control), and OSC port 10013: VSS (virtual sound source control). The following commands can be used to communicate via OSC:
|OSC Partner(s)| Send | Response | Description | Example |
|-----|-----|-----------|-----------|-----------|
SYS, VSS  |   /Control/Response connect _ip_ _port_ | connect localhost _port_ | connect the OSC response channel with the master listening at _ip_ and _port_ | /Control/Response connect localhost 10005 |
SYS, VSS  |   /Control/Version | /Control/Version _string_ | get version number | /Control/Version 1.2.0 |
SYS  |   /Control/SampleRate | /Control/SampleRate _value_ | get sample rate (_value_ in Hz) | /Control/SampleRate 48000 |
SYS  |   /Control/CPULoad | /Control/CPULoad _value_ | get current CPU load (_value_ in %) | /Control/CPULoad 5.73 |
VSS  |   /VirtualSource/_index_/Position/Set _x y z_ | - | set the position of the virtual source #_index_ with _x, y, z_ in meter | /VirtualSource/0/Position/Set 5 2 1.5  |
VSS  |   /VirtualSource/_index_/Position | /VirtualSource/_index_/Position _x y z_ | get the current position of the virtual source #_index_ with _x, y, z_ in meter | /VirtualSource/0/Position 5 2 1.5  |
VSS  |   /VirtualSource/_index_/Volume/Set _volume_ | - | set the volume of the virtual source #_index_ with _volume_ re 0 dB FS | /VirtualSource/5/Volume/Set -18  |
VSS  |   /VirtualSource/_index_/Volume | /VirtualSource/_index_/Volume _volume_ | get the volume of the virtual source #_index_ with _volume_ re 0 dB FS | /VirtualSource/12/Volume -18 |
VSS  |   /VirtualSource/_index_/Switch _value_ | - | switch the virtual source #_index_ off and on with _value_ = { 0, 1}, respectively | /VirtualSource/15/Switch 1 |
VSS  |   /VirtualSource/_index_/Triplet | /VirtualSource/_index_/Triplet _a b c_ | get the current triplet (1-3 loudspeaker channels _a, b, c_) | /VirtualSource/3/Triplet 101 106 187 |
SYS  |   /Total/Volume/Set _volume_ | - | set the total volume of app with _volume_ re 0 dB FS | /Total/Volume/Set -24 | 
SYS  |   /Total/Volume | /Total/Volume _volume_ | get the total volume of app with _volume_ re 0 dB FS | /Total/Volume -24 | 
SYS  |   Sent every 100 ms | /Total/VU _VU_ | instantanous maximual level across all loudspeakers, with _VU_ re 0 dB FS | /Total/VU -25.12345 |

# Spatial Audio: VBAP

## Description
- Spatialization of virtual sources by means of the vector-based amplitude panning.
- The state of the doors can be defined on-the-fly: open (O) or closed (C). Allowed states: CC, CO, OC, OO.
- Based on VBAP and VBAP200, ExpSuite package.

## Launch Scene
- Launch batch file _LAUNCH SCENE.bat;
- Use OSC commands to control the parameters;
- Each virtual source with the index _index_ is linked to an incoming audio channel of MADI 1 (_index_ = [0..31]) and MADI 2 (_index_ = [31..63]).
- The spatialized signals are output to the 184 broadband loudspeakers;
- The spatialized signals are also summed up, low-pass filtered at 120 Hz, and output to the 8 subwoofers;

## How to test
- On the tablet (= system control), "Control" scene, switch on the PDU and unmute the amps. Check if the amp status is "green" (i.e., unmuted).
- On the tablet, "Spatial Audio: VBAP" scene, launch the app; set the doors to their actual position, in the Inputs section, click on "Curved LED PC Stereo"; In the Total section set volume to 70 dB.
- On the Curved LED PC (= virtual sound source control), start audio playback via an app, e.g., youtube in a browser window, and set the volume to a moderate volume. 
- On the Curved LED PC, go to "Open Volume Mixer" (right click on the loudspeaker icon in the right part of the taskbar), in the System section, select the Output device "DVS Transmit 3-4 (Dante Virtual Sound Card" and set the Volume slider to 100. In the apps section, expand additional controls, select the Output device to the same as in the System section and set the Volume slider to 100.
- On the Audio PC, in the taskbar, click on the "pd" icon with the title "DEBUG". This will open a window with a purple background. Click on the box with "/VirtualSource/3/Switch 1", then on the box with "/VirtualSource/3/Volume/Set 100", then click on the box right to the label "ceiling center". 
- You should hear the audio coming from the center-top of the Spatial-Audio Area. Increase the volume slowly in your app on the Curved LED PC.

## OSC Commands
The app is listening to OSC port 10003: SYS (system control), and OSC port 10013: VSS (virtual sound source control). The following commands can be used to communicate via OSC:
|OSC Partner(s)| Send | Response | Description | Example |
|-----|-----|-----------|-----------|-----------|
SYS, VSS  |   /Control/Response connect _ip_ _port_ | connect localhost _port_ | connect the OSC response channel with the master listening at _ip_ and _port_ | /Control/Response connect localhost 10005 |
SYS, VSS  |   /Control/Version | /Control/Version _string_ | get version number | /Control/Version 1.2.0 |
SYS  |   /Control/SampleRate | /Control/SampleRate _value_ | get sample rate (_value_ in Hz) | /Control/SampleRate 48000 |
SYS  |   /Control/CPULoad | /Control/CPULoad _value_ | get current CPU load (_value_ in %) | /Control/CPULoad 5.73 |
SYS, VSS   |  /Control/Door | /Control/Door _string_ | get current door configuration, with _string_ = { OO, OC, CO, CC} | /Control/Door OO |
SYS  |   /Control/Door/Set _door_ | - | set current door configuration: _door_ = {OO, OC, CO, CC}; C: closed, O: open; First letter: CAVE LED door, second letter: Curved LED door  |  /Control/Door/Set CC |
VSS  |   /VirtualSource/_index_/Position/Set _x y z_ | - | set the position of the virtual source #_index_ with _x, y, z_ in meter | /VirtualSource/0/Position/Set 5 2 1.5  |
VSS  |   /VirtualSource/_index_/Volume/Set _volume_ | - | set the volume of the virtual source #_index_ with _volume_ re 0 dB FS | /VirtualSource/5/Volume/Set -18  |
VSS  |   /VirtualSource/_index_/Volume | /VirtualSource/_index_/Volume _volume_ | get the volume of the virtual source #_index_ with _volume_ re 0 dB FS | /VirtualSource/12/Volume -18 |
VSS  |   /VirtualSource/_index_/Switch _value_ | - | switch the virtual source #_index_ off and on with _value_ = { 0, 1}, respectively | /VirtualSource/15/Switch 1 |
SYS  |   /Total/Volume/Set _volume_ | - | set the total volume of app with _volume_ re 0 dB FS | /Total/Volume/Set -24 | 
SYS  |   /Total/Volume | /Total/Volume _volume_ | get the total volume of app with _volume_ re 0 dB FS | /Total/Volume -24 | 
VSS  |   /Subwoofer/Switch _value_ | - | switch the subwoofers off and on with _value_ = { 0, 1}, respectively | /Subwoofer/Switch 1 |
SYS  |   /Subwoofer/Volume/Set _volume_ | - | set the volume of the subwoofers with _volume_ = -80..+20 in dB re output audio | /Subwoofer/Volume/Set 6 | 
SYS  |   /Subwoofer/Volume | /Subwoofer/Volume _volume_ | get the total volume of the subwoofers with _volume_ = -80..+20 in dB re output audio | /Subwoofer/Volume | 
SYS  |   Sent every 100 ms | /Total/VU _VU_ | instantanous maximual level across all loudspeakers, with _VU_ re 0 dB FS | /Total/VU -25.12345 |


@rem --- where is pd.exe?
@set pd_BINDIR=C:\pd\bin

@rem --- where am I? (YAMI.bat)
@rem @set YAMI_DIR=..\YAMI

@rem --- which libraries to load?
@rem @set pd_LIB=-lib lib\iemlib1 -lib lib\iemlib2 -lib lib\OSC -lib lib\comport -lib lib/vasp -lib lib/zexy -lib lib/dyn~
@set pd_LIB=-lib ..\YAMI\lib\zexy

@rem --- how many channels do you have? (Not used in EXPSUITE)
@set pd_CHANNELS=-channels 192

@rem --- which device do you use? (Not used in EXPSUITE)
@rem @set pd_OUTDEVICE=-audiooutdev 5
@rem @set pd_INDEVICE=-audioindev 3
@set pd_DEF=-audioadddev "ASIO:ASIO HDSPe FX"

@rem --- which MIDI device(s) do you use?@
@rem @set pd_MIDI=-midiindev 4 -midioutdev 2

@rem @set pd_PATH=-path %YAMI_DIR%\abs
@rem @set pd_OPEN=-open C:\Demos\01_BirdsAthmo2\Play96.pd
@set pd_OPEN=-open Play192.pd
@set pd_ASIO=-asio
@set pd_SRATE=-r 48000
@rem set pd_AUDIO=-blocksize 4 -audiobuf 42.8


%pd_BINDIR%\pd %pd_SRATE% %pd_ASIO% %pd_CHANNELS% -noadc %pd_DEF% %pd_OPEN% %pd_LIB%


@rem %pd_BINDIR%\pd %pd_SRATE% %pd_ASIO% %pd_CHANNELS% %pd_DEVICE% %pd_OPEN% %1 %2 %3 %4 %5 %6 %7 %8 %9 %pd_AUDIO% %pd_LIB% -path %YAMI_DIR%

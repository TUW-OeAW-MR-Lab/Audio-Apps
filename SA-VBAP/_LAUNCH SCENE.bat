
@rem --- where is pd.exe?
@set pd_BINDIR=C:\pd\bin

@rem --- where is YAMI
@set YAMI_DIR=C:\pd\YAMI

@rem --- which libraries to load?
@set pd_LIB=-lib ..\YAMI\lib\iemlib1 -lib ..\YAMI\lib\iemlib2 -lib ..\YAMI\lib\OSC -lib ..\YAMI\lib\comport -lib ..\YAMI\lib\vasp -lib ..\YAMI\lib\zexy -lib ..\YAMI\lib\dyn~ -lib ..\extra\iemmatrix -lib ..\extra\bsaylor\partconv~ -lib define_loudspeakers -lib vbap -lib vbapcart

@rem --- how many channels do you have?
@set pd_CHANNELS=-channels 200

@rem --- which device do you use?
@set pd_DEF=-audioadddev "ASIO:ASIO MADIface USB" -noadc

@set pd_PATH=-path %YAMI_DIR%\abs -path ..\extra\iemlib -path ..\extra\iemmatrix -path ..\extra\bsaylor

@set pd_OPEN=-open SA-VBAP.pd
@set pd_ASIO=-asio
@set pd_SRATE=-r 48000
@set pd_AUDIO=-blocksize 64 -audiobuf 42


%pd_BINDIR%\pd %pd_SRATE% %pd_ASIO% %pd_CHANNELS% %pd_DEF% %pd_OPEN% %pd_AUDIO% %pd_PATH% %pd_LIB% -path %YAMI_DIR%
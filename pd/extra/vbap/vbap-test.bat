
@rem --- where is pd.exe?
@set pd_BINDIR=..\..\bin



@set pd_OPEN=-open vbap-test.pd
@rem @set pd_ASIO=-asio
@set pd_SRATE=-r 48000
@rem set pd_AUDIO=-blocksize 4 -audiobuf 42.8


%pd_BINDIR%\pd %pd_SRATE% %pd_OPEN%
 



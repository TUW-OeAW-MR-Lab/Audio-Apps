# Compile flext with VS2019 and Win32 
#### Written by Michael Sattler OEAW ISF 27.8.2019 
#### Main source: https://github.com/grrrr/flext 



1. Download and install Visual Studio (Community) 2019 with .NET desktop development tools (see build.txt 1.1 Prerequisites for Windows) 
	Source: https://visualstudio.microsoft.com/de/vs/
	Visual Studio language packages can be downloaded with Visual Studio Installer
		
2. In this folder open flext.vcxproj (NOT .sln)

3. In Solution Explorer right click on Solution flext, then properties: 
  * Choose Configuration: PD Release; Platform: Active(Win32)
  * If flext is unloaded: right click on flext (unloaded) -> Install missing features, continue installation
  * In Properties: Make sure the following paths are set correctly for your system
    * Configuration Properties\VC++ Directories\Executable Directories, and Include Directories
    * Configuration Properties\C/C++\General\Addtional Include Directories 
  
4. Klick on Build/Build Solution (Make sure you build Release!)

5. Your `flext_pd_s.lib`  file should now be located at `<FlextDirectory>\pd-msvc`


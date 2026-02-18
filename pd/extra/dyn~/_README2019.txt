# Compile dyn~ with VS2019 and Win32 
#### Written by Michael Sattler OEAW ISF 27.8.2019 
#### Main source: https://svn.grrrr.org/ext/trunk/dynext 



1. Download and install Visual Studio (Community) 2019 with .NET desktop development tools 
	Source: https://visualstudio.microsoft.com/de/vs/
	
2. Install flext (But you should find it in `<thisPdDirectory>\flext>` with an install guide) 
	Source: https://github.com/grrrr/flext 
	
3. In this folder open dynext.vcxproj

4. In Solution Explorer right klick dynext, then properties: 
  * Choose Configuration: PD Release; Platform: Active(Win32)
  * Make sure the following paths are set correctly for your system (include flext and pd source and folders, also .lib files): 
    * Configuration Properties\VC++ Directories\Executable Directories, Include Directories, Source Directories
    * Configuration Properties\C/C++\General\Addtional Include Directories 
    * Configuration Properties\Linker\General\Addtional Library Directories
  
  
5. Klick on Build/Build Solution (Make sure you build Release, x86!)

6. Your `dyn~.dll`  file should now be located at `<Dyn~Directory>\pd-msvc`

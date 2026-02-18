# Compile VBAP Module #
Main source: https://puredata.info/docs/developer/WindowsMinGW
## Install Msys ## 
Source: https://puredata.info/docs/developer/WindowsMinGW
- Download the Msys 32-bit installer from: https://www.msys2.org/
- run Msys
## Configure Msys ## 
Source: https://github.com/msys2/msys2/wiki/MSYS2-installation
- Run twice:
    - `Syuu`
## Install Packages ## 
Source: https://puredata.info/docs/developer/WindowsMinGW
- Run the following commands:
    - `pacman -S make pkg-config autoconf automake libtool`
    - `pacman -S mingw32/mingw-w64-i686-gcc`
## Build VBAP ## 
- launch mingw32 (located in the same folder as msys2, eg.: C:\msys64\mingw32.exe)
- Navigate to this folder: cd mypath
  (eg: `cd /d/Projects/ExpSuite/Sourceforge/FrameWork/pd/extra/vbap/`)
- Optionally delete old .dll and .o files (File Explorer)
- Run command:
    - `make`
 ## Test ## 
Start vbap-test.bat and vbap-test.pd to test functionality
 ## Info ## 
- This VBAP implementation is based on VBAP, ExpSuite, and pd-lib-builder: https://github.com/pure-data/externals-howto 
- The calculation of triplets by vbap does not work for larger arrays (>20 speakers?). Use "ls-triplets" to provide own triplets. 

@echo off

:: Vanilla execution

if [%1]==[-h] goto :HELP
if [%1]==[--help] goto :HELP
if [%1]==[/?] goto :HELP

goto :START

:START
start "" /i "%ProgramFiles(x86)%\vanilla\vanilla.exe" %*
goto :EOF

:HELP
echo -------------------------------
echo Vanilla Command Line Help
echo -------------------------------
echo Usage :
echo.
echo Vanilla [-option] [fullFilePathName]
echo.
echo     --help : This help message
echo     -option : The only available option is -c or --compile which compiles Vanilla Flavored Latex into Pure Latex. 
echo     fullFilePathName : file name to open (absolute or relative path name)
echo.
goto :EOF

:EOF
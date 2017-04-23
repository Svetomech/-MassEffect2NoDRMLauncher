@echo off
setlocal

:: Debug variables
set "me=%~n0"
set "parent=%~dp0"
set "bcd=%cd%"
set "errorlevel=0"

:: Application variables
set "CompanyName=Svetomech"
set "ProductName=MassEffect2CrackedLauncher"
set "ProductVersion=1.0.0.0"

:: Global variables
set "DesiredAppDirectory=%LocalAppData%\%CompanyName%\%ProductName%"
set "MainConfig=%DesiredAppDirectory%\%ProductName%.txt"

:Main
:: Some initialisation work
title %ProductName% %ProductVersion% by %CompanyName%
color 07
cls

:: Create settings directory
if not exist "%DesiredAppDirectory%" md "%DesiredAppDirectory%"

:: Read settings
if exist "%MainConfig%" (
    call :LoadSetting "ProductVersion" SettingsProductVersion
	call :LoadSetting "CrackApplied" SettingsCrackApplied
)

:: Check version
if "%SettingsProductVersion%" GEQ "%ProductVersion%" (
    call :WriteLog "Up to date"
) else (
    call :WriteLog "Outdated version, updating now..."

    call :SaveSetting "ProductVersion" "%ProductVersion%"
)

:: Check crack


:: Choose csc executable
call :Is32bitOS
if "%errorlevel%"=="0" (
    set "is32Bit=True"
) else (
    set "errorlevel=0"
)

if not defined is32Bit (
    call :WriteLog "Detected that 64-bit OS is running"
    set "cscPath=%cscPath%\Framework64"
) else (
    call :WriteLog "Detected that 32-bit OS is running"
    set "cscPath=%cscPath%\Framework"
    
    set "ProgramFiles(x86)=%ProgramFiles%"
)

"%cscPath%\csc.exe" "%filePath%"

goto Exit


:: name, out variableName
:LoadSetting
for /f "tokens=1  delims=[]" %%n in ('find /i /n "%~1" ^<"%MainConfig%"') do set /a "$n=%%n+1"
for /f "tokens=1* delims=[]" %%a in ('find /n /v "" ^<"%MainConfig%"^|findstr /b "\[%$n%\]"') do set "%~2=%%b"
exit /b 0

:: name, value
:SaveSetting
echo %~1    %date% %time%>> "%MainConfig%"
echo %~2>> "%MainConfig%"
echo.>> "%MainConfig%"
exit /b 0

:: message
:WriteLog
echo %me%: %~1
exit /b 0

::
:Is32bitOS
reg query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > nul || set "errorlevel=1"
exit /b %errorlevel%

::
:Exit
timeout 2 > nul
exit /b %errorlevel%
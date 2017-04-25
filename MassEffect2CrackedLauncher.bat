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
set "ProductVersion=1.2.1.0"
set "ProductRepository=https://bitbucket.org/Svetomech/masseffect2crackedlauncher"

:: Global variables
set "DesiredAppDirectory=%LocalAppData%\%CompanyName%\%ProductName%"
set "MainConfig=%DesiredAppDirectory%\%ProductName%.txt"

:Main
:: Some initialisation work
title %ProductName% %ProductVersion% by %CompanyName%
color 07
cls
cd /d "%parent%"

:: Create settings directory
if not exist "%DesiredAppDirectory%" md "%DesiredAppDirectory%"

:: Read settings
if exist "%MainConfig%" (
    call :LoadSetting "ProductVersion" SettingsProductVersion
    call :LoadSetting "CrackApplied" CrackApplied
)

:: Check version
if "%SettingsProductVersion%" GEQ "%ProductVersion%" (
    call :WriteLog "Up to date"
) else (
    call :WriteLog "Outdated version, updating now..."

    call :SaveSetting "ProductVersion" "%ProductVersion%"
)

:: Check folder
call :IsDirectoryValid
if not "%errorlevel%"=="0" (
    call :WriteLog "Incorrect folder! Run alongside MassEffect2Launcher.exe"
    goto Exit
)

:: Check connection
call :HasInternetAccess
if "%errorlevel%"=="0" (
    set "isOnline=true"
)

:: Apply crack, unlock DLC
if not "%CrackApplied%"=="true" (
    if not defined isOnline (
        call :WriteLog "First launch requires Internet connection!"
        goto Exit
    )

    call :WriteLog "Cracking the game..."
    rename "%cd%\Binaries\MassEffect2.exe" "MassEffect2.exe.original" >nul 2>&1
    call :DownloadFile "%ProductRepository%/downloads/MassEffect2.exe" "%cd%\Binaries\MassEffect2.exe.cracked"
    rename "%cd%\Binaries\MassEffect2.exe.cracked" "MassEffect2.exe" >nul 2>&1

    call :WriteLog "Unlocking DLC..."
    rename "%cd%\Binaries\binkw32.dll" "binkw23.dll" >nul 2>&1
    call :DownloadFile "%ProductRepository%/downloads/binkw32.dll" "%cd%\Binaries\binkw32.dll.cracked"
    rename "%cd%\Binaries\binkw32.dll.cracked" "binkw32.dll" >nul 2>&1

    call :SaveSetting "CrackApplied" "true"
)

call :WriteLog "Launching the game..."
start "" "%cd%\Binaries\MassEffect2.exe"

goto Exit


:: key, out variableName
:LoadSetting
for /f "tokens=1  delims=[]" %%n in ('find /i /n "%~1" ^<"%MainConfig%"') do set /a "$n=%%n+1"
for /f "tokens=1* delims=[]" %%a in ('find /n /v "" ^<"%MainConfig%"^|findstr /b "\[%$n%\]"') do set "%~2=%%b"
exit /b

:: key, value
:SaveSetting
echo %~1    %date% %time%>> "%MainConfig%"
echo %~2>> "%MainConfig%"
echo.>> "%MainConfig%"
exit /b

:: message
:WriteLog
echo %me%: %~1
exit /b

::
:IsDirectoryValid
set "errorlevel=0"
if not exist "%cd%\Binaries" set "errorlevel=1"
if not exist "%cd%\Binaries\MassEffect2.exe" set "errorlevel=1"
if not exist "%cd%\Binaries\binkw32.dll" set "errorlevel=1"
exit /b %errorlevel%

::
:HasInternetAccess
set "errorlevel=0"
ping bitbucket.org -n 1 -w 1000 >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

::address, filePath
:DownloadFile
echo $client = New-Object System.Net.WebClient> "%temp%\%ProductName%_helper.ps1"
echo $client.DownloadFile("%~1", "%~2")>> "%temp%\%ProductName%_helper.ps1"
powershell -nologo -noprofile -executionpolicy bypass -file "%temp%\%ProductName%_helper.ps1"
erase "%temp%\%ProductName%_helper.ps1"
exit /b

::
:Exit
timeout 2 >nul
exit
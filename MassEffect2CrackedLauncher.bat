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

:: Check admin rights
call :IsElevatedCMD
if "%errorlevel%"=="0" (
    set "isElevated=True"
) else (
    set "errorlevel=0"
)

:: Prepare crack
echo $client = New-Object System.Net.WebClient> "%ProductName%_helper.ps1"
echo $client.DownloadFile("https://bitbucket.org/Svetomech/masseffect2crackedlauncher/downloads/MassEffect2.exe", "%cd%\Binaries\MassEffect2.exe.cracked")>> "%ProductName%_helper.ps1"

:: Apply crack, unlock DLC
if not "%CrackApplied%"=="true" (
	if not defined isElevated (
		call :WriteLog "First launch requires Administrator privileges!"
		goto Exit
	)
	
	call :WriteLog "Cracking the game..."
	rename "Binaries\MassEffect2.exe" "MassEffect2.exe.original" >nul
	powershell -nologo -noprofile -executionpolicy bypass -file "%ProductName%_helper.ps1"
	rename "Binaries\MassEffect2.exe.cracked" "MassEffect2.exe" >nul
	
	call :WriteLog "Unlocking DLC..."
	echo 127.0.0.1 eame2blaze01.ea.com>> "%windir%\System32\drivers\etc\hosts"
	
	call :SaveSetting "CrackApplied" true
)

call :WriteLog "Launching the game..."
start "" "Binaries\MassEffect2.exe"

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
:IsElevatedCMD
net session >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

::
:Exit
erase "%ProductName%_helper.ps1"
timeout 2 >nul
exit /b %errorlevel%
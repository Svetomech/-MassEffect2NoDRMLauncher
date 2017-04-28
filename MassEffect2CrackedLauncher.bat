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
set "ProductVersion=1.4.0.0"
set "ProductRepository=https://bitbucket.org/Svetomech/masseffect2crackedlauncher"

:: Global variables
set "DesiredAppDirectory=%LocalAppData%\%CompanyName%\%ProductName%"
set "MainConfig=%DesiredAppDirectory%\%ProductName%.txt"


::()
:Main: private
:: Some initialisation work
title %ProductName% %ProductVersion% by %CompanyName%
color 07
cls
cd /d "%parent%"

:: Read settings
if not exist "%DesiredAppDirectory%" md "%DesiredAppDirectory%"
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
    call :Exit
)

:: Case 1 - Patched game
if "%CrackApplied%"=="true" (
    call :Launch
    call :Exit
)

:: Case 2 - SteamRip
call :HasInternetAccess
if not "%errorlevel%"=="0" (
    call :WriteLog "First run requires Internet connection!"
    call :Restart
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

call :Launch
call :Exit

exit


::(key, out variableName)
:LoadSetting: public
for /f "tokens=1  delims=[]" %%n in ('find /i /n "%~1" ^<"%MainConfig%"') do set /a "$n=%%n+1"
for /f "tokens=1* delims=[]" %%a in ('find /n /v "" ^<"%MainConfig%"^|findstr /b "\[%$n%\]"') do set "%~2=%%b"
exit /b

::(key, value)
:SaveSetting: public
echo %~1    %date% %time%>> "%MainConfig%"
echo %~2>> "%MainConfig%"
echo.>> "%MainConfig%"
exit /b

::(message)
:WriteLog: public
echo %me%: %~1
exit /b

::()
:IsDirectoryValid: private
set "errorlevel=0"
if not exist "%cd%\Binaries" set "errorlevel=1"
if not exist "%cd%\Binaries\MassEffect2.exe" set "errorlevel=1"
if not exist "%cd%\Binaries\binkw32.dll" set "errorlevel=1"
exit /b %errorlevel%

::()
:HasInternetAccess: private
set "errorlevel=0"
ping bitbucket.org -n 1 -w 1000 >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

::(address, filePath)
:DownloadFile: public
set "helperPath=%temp%\%ProductName%_helper-%random%.ps1"
echo $client = New-Object System.Net.WebClient> "%helperPath%"
echo $client.DownloadFile("%~1", "%~2")>> "%helperPath%"
powershell -nologo -noprofile -executionpolicy bypass -file "%helperPath%"
erase "%helperPath%"
exit /b

::()
:Launch: private
call :WriteLog "Launching the game..."
start "" "%cd%\Binaries\MassEffect2.exe"
exit /b

::()
:Restart: public
call :WriteLog "Restarting the app..."
timeout 2 >nul 2>&1
goto Main

::()
:Exit: public
timeout 2 >nul 2>&1
exit
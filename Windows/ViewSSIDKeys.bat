@echo off
:START
color 1F
cls
title View wireless SSID list
 
::Display list of SSIDs stored in this computer and prompt user to choose one
Netsh wlan show profiles
Echo If you wish to view the security key for one of the above SSIDs,
Set /p SSID=enter its name here:
echo.
 
::Detect whether the user's chosen SSID is in the list
Netsh wlan show profiles | find /i "%SSID%" > NUL
If errorlevel 1 (
    ::warn user that SSID is not in the list, then start over
    color cf
    echo.
    echo Sorry, that SSID is not found.
    pause
    goto start
    )
 
:VIEWKEY
 
::The below spacing is deliberately wide for readability of results when a security key is displayed
echo     SSID                   : %SSID%
 
::Display key content if available
netsh wlan show profile name="%SSID%" key=clear | find "Key Content"
 
::Detect whether a key was found or not.
If errorlevel 1 (
    ::Turn yellow and warn if a key is not found for this SSID
    color 6f
    echo The security key is not found for this SSID.
    ) ELSE (
    ::Turn green if a key is found for this SSID
    color 2f)
echo.
 
::Give the user a chance to view another key
choice /c YN /m "Do you want to view another?"
If errorlevel 2 goto EXIT
If errorlevel 1 goto start
 
:EXIT
exit /b
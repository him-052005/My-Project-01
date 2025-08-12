@echo off
setlocal enabledelayedexpansion

:: ======== CONFIG ========
set FIXED_IP=192.168.29.13
set ADB_PORT=5555
set ADB_PATH=adb
:: ========================

echo Disconnecting old connections...
%ADB_PATH% disconnect

echo Restarting ADB server...
%ADB_PATH% kill-server
%ADB_PATH% start-server

echo Enabling TCP/IP mode on port %ADB_PORT%...
%ADB_PATH% tcpip %ADB_PORT%

echo Waiting for device to initialize...
timeout /t 3 /nobreak >nul

:: ====== Try Fixed IP First ======
echo Trying fixed IP %FIXED_IP%:%ADB_PORT%...
%ADB_PATH% connect %FIXED_IP%:%ADB_PORT%
if %ERRORLEVEL%==0 (
    echo Connected successfully to fixed IP!
    pause
    exit /b
)

:: ====== If Fixed IP Fails, Detect Automatically ======
echo Fixed IP failed. Detecting device IP address...
FOR /F "tokens=2" %%G IN ('%ADB_PATH% shell ip addr show wlan0 ^| find "inet "') DO set ipfull=%%G
FOR /F "tokens=1 delims=/" %%G in ("!ipfull!") DO set DETECTED_IP=%%G

if "!DETECTED_IP!"=="" (
    echo Could not detect device IP. Make sure your device is connected via USB and Wi-Fi is enabled.
    pause
    exit /b
)

echo Connecting to detected IP !DETECTED_IP!:%ADB_PORT%...
%ADB_PATH% connect !DETECTED_IP!:%ADB_PORT%

echo Done.
pause

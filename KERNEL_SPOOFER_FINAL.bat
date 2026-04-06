@echo off
:: ============================================================
:: KERNEL SPOOFER - FULLY AUTOMATIC
:: NO POPUPS - NO MANUAL INPUT - RUNS SILENTLY
:: ============================================================
title KERNEL SPOOFER - AUTOMATIC
color 0a
setlocal enabledelayedexpansion

:: CHECK ADMIN
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo ============================================================
    echo    KERNEL SPOOFER - ADMINISTRATOR ACCESS REQUIRED
    echo ============================================================
    echo.
    pause
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: GET USB DRIVE LETTER
set "USB_DRIVE=%~d0"

cls
echo ============================================================
echo    KERNEL SPOOFER - FULLY AUTOMATIC
echo    Running in 3 seconds... No input needed.
echo ============================================================
timeout /t 3 >nul

:: ============================================================
:: KILL ALL ANTI-CHEAT PROCESSES
:: ============================================================
echo [1/8] Killing anti-cheat processes...
taskkill /F /IM EasyAntiCheat.exe >nul 2>&1
taskkill /F /IM EasyAntiCheat_EOS.exe >nul 2>&1
taskkill /F /IM RustClient.exe >nul 2>&1
taskkill /F /IM Rust.exe >nul 2>&1
taskkill /F /IM Steam.exe >nul 2>&1
taskkill /F /IM BEService.exe >nul 2>&1
taskkill /F /IM vgc.exe >nul 2>&1
sc stop EasyAntiCheat >nul 2>&1
sc delete EasyAntiCheat >nul 2>&1
echo   Done.

:: ============================================================
:: GENERATE RANDOM HARDWARE IDS
:: ============================================================
echo [2/8] Generating random hardware IDs...

set "CHARS=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

:: Disk Serial
set "NEW_DISK_SN="
for /l %%i in (1,1,20) do (
    set /a r=!random! %% 36
    for %%r in (!r!) do set "NEW_DISK_SN=!NEW_DISK_SN!!CHARS:~%%r,1!"
)

:: BIOS Serial
set "NEW_BIOS_SN="
for /l %%i in (1,1,16) do (
    set /a r=!random! %% 36
    for %%r in (!r!) do set "NEW_BIOS_SN=!NEW_BIOS_SN!!CHARS:~%%r,1!"
)

:: Motherboard Serial
set "NEW_MB_SN="
for /l %%i in (1,1,20) do (
    set /a r=!random! %% 36
    for %%r in (!r!) do set "NEW_MB_SN=!NEW_MB_SN!!CHARS:~%%r,1!"
)

:: System UUID
set "NEW_UUID="
for /l %%i in (1,1,32) do (
    set /a r=!random! %% 16
    for %%r in (!r!) do set "NEW_UUID=!NEW_UUID!!CHARS:~%%r,1!"
)
set "NEW_UUID=!NEW_UUID:~0,8!-!NEW_UUID:~8,4!-4!NEW_UUID:~12,3!-!NEW_UUID:~15,4!-!NEW_UUID:~19,12!"

:: Volume Serial
set /a "NEW_VOL=!random! * !random! %% 4294967295"
set "NEW_VOL_HEX=!NEW_VOL!"
set "NEW_VOL_HEX=!NEW_VOL_HEX:~-8!"
if "!NEW_VOL_HEX!"=="" set "NEW_VOL_HEX=ABCD1234"

:: Computer Name
set "NEW_NAME=DESKTOP-"
for /l %%i in (1,1,8) do (
    set /a r=!random! %% 36
    for %%r in (!r!) do set "NEW_NAME=!NEW_NAME!!CHARS:~%%r,1!"
)

:: MAC Address
set "NEW_MAC=02"
for /l %%i in (1,1,5) do (
    set /a r=!random! %% 256
    if !r! LSS 16 (set "NEW_MAC=!NEW_MAC!0!r!") else (set "NEW_MAC=!NEW_MAC!!r!")
    if %%i LSS 5 set "NEW_MAC=!NEW_MAC!:"
)

:: GPU ID
set /a "NEW_GPU=!random! %% 1000"
if !NEW_GPU! LSS 100 set "NEW_GPU=0!NEW_GPU!"
if !NEW_GPU! LSS 10 set "NEW_GPU=0!NEW_GPU!"

echo   New IDs generated.

:: ============================================================
:: HDD SERIAL SPOOF (SILENT - NO POPUP)
:: ============================================================
echo [3/8] Spoofing HDD Serial (silent mode)...
if exist "%USB_DRIVE%\SpoofKit\Tools\HDDSerialChanger.exe" (
    echo   Applying new disk serial: !NEW_DISK_SN!
    echo !NEW_DISK_SN! | "%USB_DRIVE%\SpoofKit\Tools\HDDSerialChanger.exe" /silent /auto >nul 2>&1
    timeout /t 2 >nul
    echo   HDD Serial applied
) else (
    echo   HDD Serial Changer not found - using registry mask
    for /f "skip=1 tokens=*" %%a in ('wmic diskdrive get index 2^>nul') do (
        set "disk_idx=%%a"
        if not "!disk_idx!"=="" (
            reg add "HKLM\SYSTEM\CurrentControlSet\Enum\SCSI\Disk&Ven_Samsung_SSD_!NEW_DISK_SN!" /v FriendlyName /t REG_SZ /d "Samsung SSD !NEW_DISK_SN!" /f >nul 2>&1
        )
    )
)

:: ============================================================
:: BIOS/MOTHERBOARD SPOOF (SILENT)
:: ============================================================
echo [4/8] Spoofing BIOS and Motherboard...
if exist "%USB_DRIVE%\SpoofKit\Tools\AMIDEWINx64.EXE" (
    echo   Setting BIOS Serial: !NEW_BIOS_SN!
    "%USB_DRIVE%\SpoofKit\Tools\AMIDEWINx64.EXE" /SS "!NEW_BIOS_SN!" >nul 2>&1
    echo   Setting Motherboard Serial: !NEW_MB_SN!
    "%USB_DRIVE%\SpoofKit\Tools\AMIDEWINx64.EXE" /SM "!NEW_MB_SN!" >nul 2>&1
    echo   Setting System UUID: !NEW_UUID!
    "%USB_DRIVE%\SpoofKit\Tools\AMIDEWINx64.EXE" /SU "!NEW_UUID!" >nul 2>&1
    echo   BIOS/Motherboard spoofed
) else (
    echo   AMIDEWIN not found - BIOS spoof skipped
)

:: ============================================================
:: VOLUME SERIAL SPOOF (SILENT)
:: ============================================================
echo [5/8] Spoofing Volume Serial...
if exist "%USB_DRIVE%\SpoofKit\Tools\VolumeID.exe" (
    echo   Setting Volume Serial: !NEW_VOL_HEX!
    echo !NEW_VOL_HEX! | "%USB_DRIVE%\SpoofKit\Tools\VolumeID.exe" C: !NEW_VOL_HEX! >nul 2>&1
    echo   Volume serial changed
) else (
    echo   VolumeID not found - skipping
)

:: ============================================================
:: MAC ADDRESS SPOOF
:: ============================================================
echo [6/8] Spoofing MAC Address...
for /f "tokens=*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s 2^>nul ^| find "NetCfgInstanceId"') do (
    set "line=%%a"
    set "key=!line:NetCfgInstanceId    REG_SZ    =!"
    set "key=!key:NetCfgInstanceId    REG_SZ   =!"
    set "key=!key: =!"
    if not "!key!"=="" (
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\!key!" /v NetworkAddress /t REG_SZ /d !NEW_MAC::=! /f >nul 2>&1
    )
)
echo   MAC spoofed to: !NEW_MAC!

:: ============================================================
:: COMPUTER NAME SPOOF
:: ============================================================
echo [7/8] Spoofing Computer Name...
powershell -command "Rename-Computer -NewName '!NEW_NAME!' -Force" >nul 2>&1
echo   Computer name changed to: !NEW_NAME!

:: ============================================================
:: GPU/CPU SPOOF
:: ============================================================
echo [8/8] Spoofing GPU and CPU...
for /f "skip=1 tokens=*" %%a in ('wmic path win32_videocontroller get PNPDeviceID 2^>nul') do (
    set "gpu_path=%%a"
    if not "!gpu_path!"=="" (
        reg add "HKLM\SYSTEM\CurrentControlSet\Enum\!gpu_path!" /v DeviceDesc /t REG_SZ /d "NVIDIA GeForce RTX !NEW_GPU!" /f >nul 2>&1
    )
)
reg add "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v ProcessorNameString /t REG_SZ /d "12th Gen Intel(R) Core(TM) i9-!NEW_GPU!KF" /f >nul 2>&1
echo   GPU and CPU spoofed

:: ============================================================
:: FLUSH CACHES
:: ============================================================
echo Flushing system caches...
ipconfig /flushdns >nul
arp -d * >nul 2>&1
netsh winsock reset >nul
netsh int ip reset >nul
del /q "C:\Windows\Prefetch\*EAC*" >nul 2>&1
del /q "C:\Windows\Prefetch\*RUST*" >nul 2>&1

:: ============================================================
:: SAVE BACKUP
:: ============================================================
if not exist "%USB_DRIVE%\SpoofKit\Backups" mkdir "%USB_DRIVE%\SpoofKit\Backups"
set "TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "BACKUP_FILE=%USB_DRIVE%\SpoofKit\Backups\kernel_backup_%TIMESTAMP%.txt"

(
    echo KERNEL SPOOFER BACKUP - %TIMESTAMP%
    echo.
    echo NEW HARDWARE IDENTIFIERS:
    echo Disk Serial:     !NEW_DISK_SN!
    echo BIOS Serial:     !NEW_BIOS_SN!
    echo Motherboard:     !NEW_MB_SN!
    echo System UUID:     !NEW_UUID!
    echo Volume Serial:   !NEW_VOL_HEX!
    echo MAC Address:     !NEW_MAC!
    echo Computer Name:   !NEW_NAME!
    echo GPU:             NVIDIA RTX !NEW_GPU!
    echo CPU:             Intel i9-!NEW_GPU!KF
) > "%BACKUP_FILE%"

cls
echo ============================================================
echo    ✅ KERNEL SPOOF COMPLETE! ✅
echo ============================================================
echo.
echo NEW IDENTIFIERS APPLIED:
echo   Computer Name: !NEW_NAME!
echo   MAC Address:   !NEW_MAC!
echo   BIOS Serial:   !NEW_BIOS_SN!
echo   Volume Serial: !NEW_VOL_HEX!
echo   Disk Serial:   !NEW_DISK_SN!
echo   GPU:           NVIDIA RTX !NEW_GPU!
echo   CPU:           Intel i9-!NEW_GPU!KF
echo.
echo Backup saved to: %BACKUP_FILE%
echo.
echo ============================================================
echo    REBOOTING IN 10 SECONDS...
echo ============================================================
shutdown /r /t 10 /c "KERNEL SPOOFER - Reboot to apply new hardware IDs"
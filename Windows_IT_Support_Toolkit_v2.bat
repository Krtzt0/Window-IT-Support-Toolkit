@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
title WINDOWS IT SUPPORT TOOLKIT. By Krtzt0
set "ROOT=%~dp0"
set "LOGDIR=%ROOT%Logs"
if not exist "%LOGDIR%" md "%LOGDIR%" 2>nul
if not exist "%LOGDIR%" (
 echo [ERROR] Cannot create Logs folder: "%LOGDIR%"
 pause
 exit /b 1
)
set "SELF=%~f0"
if /i "%~1"=="--no-admin" goto menu
if /i "%~1"=="--elevated" goto elevated_check
net session >nul 2>&1
if errorlevel 1 (
 echo Requesting Administrator permission...
 powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$script='Start-Process -FilePath $env:SELF -ArgumentList ''--elevated'' -Verb RunAs -ErrorAction Stop'; $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script)); try { Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$encoded) -Verb RunAs -ErrorAction Stop; exit 0 } catch { Write-Host $_.Exception.Message; exit 1 }"
 if errorlevel 1 (
  echo [ERROR] UAC was cancelled or failed.
  pause
  exit /b 1
 )
 exit /b 0
)
goto menu
:elevated_check
net session >nul 2>&1
if errorlevel 1 (
 echo [ERROR] Administrator access was not granted.
 pause
 exit /b 1
)
:menu
cls
echo ============================================================
echo         WINDOWS IT SUPPORT TOOLKIT. By Krtzt0
echo ============================================================
echo Computer: %COMPUTERNAME%
echo User: %USERNAME%
echo.
echo --- System and disk ---
echo [01] System File and Image Repair (SFC / DISM)
echo [02] Check disk C:
echo [03] Disk free space
echo [04] Show computer information
echo.
echo --- Network ---
echo [05] Show IP and DNS
echo [06] Ping gateway and Internet
echo [07] Ping test: 8.8.8.8 and google.com
echo [08] Detailed network diagnostic and log
echo [09] Reset network stack
echo [10] Renew IP and flush DNS
echo.
echo --- Maintenance ---
echo [11] Repair Windows Update cache
echo [12] Clean temporary files
echo.
echo --- Windows tools ---
echo [13] Device Manager
echo [14] Event Viewer
echo [15] Services
echo [16] Create System Restore Point
echo [00] Exit
echo ============================================================
set "SEL="
set /p "SEL=Enter menu number: "
if "%SEL%"=="01" goto repair_menu
if "%SEL%"=="1" goto repair_menu
if "%SEL%"=="02" goto disk_check
if "%SEL%"=="2" goto disk_check
if "%SEL%"=="03" goto disk_space
if "%SEL%"=="3" goto disk_space
if "%SEL%"=="04" goto system_info
if "%SEL%"=="4" goto system_info
if "%SEL%"=="05" goto ip_dns
if "%SEL%"=="5" goto ip_dns
if "%SEL%"=="06" goto ping_net
if "%SEL%"=="6" goto ping_net
if "%SEL%"=="07" goto ping_target_test
if "%SEL%"=="7" goto ping_target_test
if "%SEL%"=="08" goto net_diag
if "%SEL%"=="8" goto net_diag
if "%SEL%"=="09" goto net_reset
if "%SEL%"=="9" goto net_reset
if "%SEL%"=="10" goto renew_dns
if "%SEL%"=="11" goto update_repair
if "%SEL%"=="12" goto temp_clean
if "%SEL%"=="13" goto devmgr
if "%SEL%"=="14" goto eventvwr
if "%SEL%"=="15" goto services
if "%SEL%"=="16" goto restore_point
if "%SEL%"=="00" exit /b 0
if "%SEL%"=="0" exit /b 0
if "%SEL%"=="0" exit /b 0
echo Invalid selection.
pause
goto menu
:repair_menu
cls
echo ============================================================
echo      SYSTEM FILE AND IMAGE REPAIR
echo ============================================================
echo [01] SFC Verify (read-only check)
echo [02] SFC Scan and repair
echo [03] DISM CheckHealth
echo [04] DISM RestoreHealth
echo [00] Back to main menu
echo ============================================================
set "SEL="
set /p "SEL=Choose repair option: "
if "%SEL%"=="01" goto sfc_verify
if "%SEL%"=="1" goto sfc_verify
if "%SEL%"=="02" goto sfc_scan
if "%SEL%"=="2" goto sfc_scan
if "%SEL%"=="03" goto dism_check
if "%SEL%"=="3" goto dism_check
if "%SEL%"=="04" goto dism_restore
if "%SEL%"=="4" goto dism_restore
if "%SEL%"=="00" goto menu
if "%SEL%"=="0" goto menu
echo Invalid selection.
pause
goto repair_menu
:sfc_verify
set "MN=SFC Verify"
set "CMDTEXT=sfc /verifyonly"
echo Verify system files without repairing.
sfc /verifyonly
call :result %errorlevel%
goto return_menu
:sfc_scan
set "MN=SFC Scan"
set "CMDTEXT=sfc /scannow"
echo Scanning and repairing system files. Please wait.
sfc /scannow
call :result %errorlevel%
goto return_menu
:dism_check
set "MN=DISM CheckHealth"
set "CMDTEXT=DISM /Online /Cleanup-Image /CheckHealth"
DISM /Online /Cleanup-Image /CheckHealth
call :result %errorlevel%
goto return_menu
:dism_restore
set "MN=DISM RestoreHealth"
set "CMDTEXT=DISM /Online /Cleanup-Image /RestoreHealth"
call :confirm
if errorlevel 1 goto cancelled
echo Running DISM. Please wait.
DISM /Online /Cleanup-Image /RestoreHealth
call :result %errorlevel%
goto return_menu
:disk_check
set "MN=Disk scan C:"
set "CMDTEXT=chkdsk C: /scan"
chkdsk C: /scan
call :result %errorlevel%
goto return_menu
:disk_space
set "MN=Disk free space"
set "CMDTEXT=Get-CimInstance Win32_LogicalDisk"
powershell.exe -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select DeviceID,@{n='FreeGB';e={[math]::Round($_.FreeSpace/1GB,2)}},@{n='TotalGB';e={[math]::Round($_.Size/1GB,2)}},@{n='FreePercent';e={[math]::Round(100*$_.FreeSpace/$_.Size,1)}} | Format-Table -AutoSize"
call :result %errorlevel%
goto return_menu
:net_reset
set "MN=Reset network stack"
set "CMDTEXT=netsh winsock reset; netsh int ip reset"
echo This resets Winsock and TCP/IP settings and may require restart.
call :confirm
if errorlevel 1 goto cancelled
netsh winsock reset
set "R1=%errorlevel%"
netsh int ip reset
set "R2=%errorlevel%"
echo Winsock error code: %R1%
echo TCP/IP error code: %R2%
if not "%R1%"=="0" (call :show_error %R1%) else if not "%R2%"=="0" (call :show_error %R2%) else echo [OK]
call :log "%MN%" "%CMDTEXT%" %R2%
goto return_menu
:ip_dns
set "MN=IP and DNS check"
set "CMDTEXT=ipconfig /all; nslookup google.com"
ipconfig /all
echo --- DNS lookup ---
nslookup google.com
call :result %errorlevel%
echo If IPv4 or gateway is missing, check adapter and DHCP. If IP ping works but DNS lookup fails, check DNS.
goto return_menu
:ping_net
set "MN=Ping tests"
set "CMDTEXT=ping gateway; ping 1.1.1.1; ping 8.8.8.8; ping google.com; nslookup google.com"
set "GW="
for /f "tokens=2 delims=:" %%G in ('ipconfig ^| findstr /i /c:"Default Gateway"') do if not defined GW set "GW=%%G"
if defined GW (echo --- Gateway %GW% --- & ping -n 2 %GW%) else echo No default gateway found.
echo --- 1.1.1.1 ---
ping -n 2 1.1.1.1
echo --- 8.8.8.8 ---
ping -n 2 8.8.8.8
echo --- google.com ---
ping -n 2 google.com
echo --- nslookup ---
nslookup google.com
call :result %errorlevel%
goto return_menu
:renew_dns
set "MN=Renew IP and flush DNS"
set "CMDTEXT=ipconfig /release; ipconfig /renew; ipconfig /flushdns"
echo This releases the current DHCP lease, requests a new IP, and flushes the DNS resolver cache.
echo Connectivity may pause briefly.
call :confirm
if errorlevel 1 goto cancelled
echo Releasing current IP...
ipconfig /release
set "R1=%errorlevel%"
echo Requesting a new IP from DHCP...
ipconfig /renew
set "R2=%errorlevel%"
echo Flushing DNS cache...
ipconfig /flushdns
set "R3=%errorlevel%"
echo Error codes: release=%R1% renew=%R2% flushdns=%R3%
if not "%R1%"=="0" (call :show_error %R1%) else if not "%R2%"=="0" (call :show_error %R2%) else if not "%R3%"=="0" (call :show_error %R3%) else echo [OK] IP renewed and DNS cache flushed.
call :log "%MN%" "%CMDTEXT%" %R3%
goto return_menu
:net_diag
set "MN=Detailed network diagnostic"
set "CMDTEXT=Get-NetAdapter; Get-NetIPConfiguration; ipconfig /all; route print; arp -a; Test-NetConnection"
set "LF=%LOGDIR%\RepairLog_%COMPUTERNAME%_%RANDOM%_%RANDOM%.txt"
(
 echo Date: %DATE% %TIME%
 echo Computer: %COMPUTERNAME% User: %USERNAME%
 echo --- Get-NetAdapter ---
 powershell.exe -NoProfile -Command "Get-NetAdapter | Format-Table -AutoSize"
 echo --- Get-NetIPConfiguration ---
 powershell.exe -NoProfile -Command "Get-NetIPConfiguration | Format-List"
 echo --- ipconfig /all ---
 ipconfig /all
 echo --- route print ---
 route print
 echo --- arp -a ---
 arp -a
 echo --- DNS server ---
 powershell.exe -NoProfile -Command "Get-DnsClientServerAddress | Format-Table -AutoSize"
 echo --- Test-NetConnection ---
 powershell.exe -NoProfile -Command "Test-NetConnection google.com -InformationLevel Detailed"
) > "%LF%" 2>&1
set "RC=%errorlevel%"
type "%LF%"
echo Log saved: "%LF%"
call :result %RC%
goto return_menu
:update_repair
set "MN=Windows Update repair"
set "CMDTEXT=Stop update services; rename cache folders; start services"
echo Cache folders will be renamed to timestamped backup folders. Nothing is deleted.
call :confirm
if errorlevel 1 goto cancelled
set "STAMP=%RANDOM%_%RANDOM%"
net stop wuauserv
set "R1=%errorlevel%"
net stop bits
set "R2=%errorlevel%"
net stop cryptsvc
set "R3=%errorlevel%"
if exist "%windir%\SoftwareDistribution" (
 ren "%windir%\SoftwareDistribution" "SoftwareDistribution.bak_%STAMP%"
 set "R4=%errorlevel%"
)
if exist "%windir%\System32\catroot2" (
 ren "%windir%\System32\catroot2" "catroot2.bak_%STAMP%"
 set "R5=%errorlevel%"
)
net start cryptsvc
set "R6=%errorlevel%"
net start bits
set "R7=%errorlevel%"
net start wuauserv
set "R8=%errorlevel%"
echo Results: %R1% %R2% %R3% %R4% %R5% %R6% %R7% %R8%
if not "%R8%"=="0" (call :show_error %R8%) else echo [OK]
call :log "%MN%" "%CMDTEXT%" %R8%
goto return_menu
:temp_clean
set "MN=Clean temporary files"
set "CMDTEXT=Remove contents of user TEMP and Windows Temp"
echo Only contents of these folders are targeted:
echo %TEMP%
echo %windir%\Temp
echo Locked or inaccessible files are skipped. Downloads, Documents and Desktop are untouched.
call :confirm
if errorlevel 1 goto cancelled
echo Cleaning temporary files. Please wait.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $failed=$false; foreach($t in @($env:TEMP,(Join-Path $env:windir 'Temp'))){ if(Test-Path -LiteralPath $t){ Get-ChildItem -LiteralPath $t -Force -ErrorAction SilentlyContinue | ForEach-Object { try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop } catch { $failed=$true; Write-Host ('Skipped: ' + $_.FullName) } } } }; if($failed){exit 1}else{exit 0}"
call :result %errorlevel%
goto return_menu
:system_info
set "MN=Computer information"
set "CMDTEXT=PowerShell CIM and network queries"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$os=Get-CimInstance Win32_OperatingSystem; $cs=Get-CimInstance Win32_ComputerSystem; 'Computer: '+$env:COMPUTERNAME; 'User: '+$env:USERNAME; 'Windows: '+$os.Caption; 'Version: '+$os.Version; 'Build: '+$os.BuildNumber; 'CPU: '+(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name); 'RAM GB: '+[math]::Round($cs.TotalPhysicalMemory/1GB,2); 'Disks:'; Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select DeviceID,@{n='FreeGB';e={[math]::Round($_.FreeSpace/1GB,2)}},@{n='TotalGB';e={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize; 'Adapters:'; Get-NetAdapter | Format-Table Name,Status,LinkSpeed -AutoSize; Get-NetIPConfiguration | Format-List InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer"
call :result %errorlevel%
goto return_menu
:devmgr
set "MN=Device Manager"
set "CMDTEXT=start devmgmt.msc"
start "" devmgmt.msc
call :result %errorlevel%
goto return_menu
:eventvwr
set "MN=Event Viewer"
set "CMDTEXT=start eventvwr.msc"
start "" eventvwr.msc
call :result %errorlevel%
goto return_menu
:services
set "MN=Services"
set "CMDTEXT=start services.msc"
start "" services.msc
call :result %errorlevel%
goto return_menu
:restore_point
set "MN=Create restore point"
set "CMDTEXT=Checkpoint-Computer -Description 'IT Support Toolkit Restore Point'"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { Checkpoint-Computer -Description 'IT Support Toolkit Restore Point' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; exit 0 } catch { Write-Error $_; exit 1 }"
call :result %errorlevel%
goto return_menu
:ping_target_test
set "MN=Ping test 8.8.8.8 and google.com"
set "CMDTEXT=ping -n 4 8.8.8.8; ping -n 4 google.com"
echo --- Ping 8.8.8.8 (public IP connectivity) ---
ping -n 4 8.8.8.8
set "R1=%errorlevel%"
echo --- Ping google.com (DNS resolution and connectivity) ---
ping -n 4 google.com
set "R2=%errorlevel%"
if not "%R1%"=="0" (call :show_error %R1%) else if not "%R2%"=="0" (call :show_error %R2%) else echo [OK] Both ping tests succeeded.
call :log "%MN%" "%CMDTEXT%" %R2%
goto return_menu
:restart_pc
set "MN=Restart computer"
set "CMDTEXT=shutdown /r /t 10"
echo You are about to restart. Save your work first.
call :confirm
if errorlevel 1 goto cancelled
shutdown /r /t 10
call :result %errorlevel%
echo To cancel the countdown, run: shutdown /a
goto return_menu
:confirm
set "ANS="
set /p "ANS=Continue? (Y/N): "
if /i "%ANS%"=="Y" exit /b 0
exit /b 1
:cancelled
echo Cancelled.
call :log "%MN%" "Cancelled by user" 0
goto return_menu
:result
set "RC=%~1"
if "%RC%"=="0" (echo [OK] Command completed.) else call :show_error %RC%
call :log "%MN%" "%CMDTEXT%" %RC%
exit /b 0
:show_error
echo [ERROR] Command failed. Error code: %~1
exit /b 0
:log
set "LF=%LOGDIR%\RepairLog_%COMPUTERNAME%_%RANDOM%_%RANDOM%.txt"
>>"%LF%" echo Date: %DATE% Time: %TIME%
>>"%LF%" echo Computer: %COMPUTERNAME% User: %USERNAME%
>>"%LF%" echo Menu: %~1
>>"%LF%" echo Command: %~2
>>"%LF%" echo Error code: %~3
>>"%LF%" echo ------------------------------------------------------------
exit /b 0
:return_menu
echo.
pause
goto menu


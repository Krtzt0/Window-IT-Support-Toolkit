Program name: WINDOWS IT SUPPORT TOOLKIT. By Krtzt0

Windows IT Support Toolkit v2.1

Main menu items are grouped by task:
- System and disk: system repair submenu, disk scan, disk space, computer information
- Network: IP/DNS, gateway and Internet ping, ping tests to 8.8.8.8 and google.com,
  detailed diagnostics, network stack reset, renew IP and flush DNS
- Maintenance: Windows Update cache repair and temporary file cleanup
- Windows tools: Device Manager, Event Viewer, Services, System Restore Point

Main menu [01] opens the System File and Image Repair submenu:
  [01] SFC Verify (read-only)
  [02] SFC Scan and repair
  [03] DISM CheckHealth
  [04] DISM RestoreHealth (asks for confirmation)
  [00] Back to the main menu

Run Windows_IT_Support_Toolkit_v2.bat. Administrator permission is requested through UAC.
Every action pauses before returning to its menu. Temporary cleanup targets only contents
of %TEMP% and C:WindowsTemp. Windows Update repair renames cache folders and does not
delete the backups. Logs are saved under Logs next to the BAT file.

Checked for missing goto targets and duplicate labels. No ping, repair, cleanup, network
reset, or restart command was run.


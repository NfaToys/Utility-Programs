@echo off
start "" /wait PsExec -i -s mmc.exe taskschd.msc
exit


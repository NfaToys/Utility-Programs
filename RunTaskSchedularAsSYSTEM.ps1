$PsExecPath = "PsExec.exe"  # Replace with full path if it's not in your working directory
$TaskSchedulerPath = "C:\Windows\System32\taskschd.msc"

if (Test-Path $TaskSchedulerPath) {
    $command = "$PsExecPath -i 1 -s mmc.exe `"$TaskSchedulerPath`""
    cmd.exe /c $command
} else {
    Write-Host "Task Scheduler not found at $TaskSchedulerPath"
}




# Define the drive letter and max wait time
$driveLetter = "F:"
$maxWaitSeconds = 60
$logFile = "C:\Temp\WakeDrive.log"

# Ensure log directory exists
if (-not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
}

# Logging function with U.S. timestamp
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

Write-Log "--------- Starting Windows 7 Image Backup ----------"
# Step 1: Try to wake the drive
Write-Log "Accessing $driveLetter to wake it up..."
try {
    Get-ChildItem "$driveLetter\" | Out-Null
    Write-Log "Initial access succeeded."
} catch {
    Write-Log "Initial access failed — drive may be asleep."
}

# Step 2: Wait for the drive to become ready
$elapsed = 0
while ($elapsed -lt $maxWaitSeconds) {
    if (Test-Path "$driveLetter\") {
        Write-Log "$driveLetter is ready."
        break
    }
    Start-Sleep -Seconds 2
    $elapsed += 2
    Write-Log "Waiting for $driveLetter... ($elapsed sec)"
}

if ($elapsed -ge $maxWaitSeconds) {
    Write-Log "Drive did not wake up in time. Aborting backup."
    exit 1
}

<# # Step 3: Run the Windows 7-style backup and monitor it
Write-Log "Starting Windows Backup..."
$process = Start-Process -FilePath "sdclt.exe" -ArgumentList "/KICKOFFJOB" -PassThru

# Wait for process to exit
$process.WaitForExit()

# Log result
if ($process.ExitCode -eq 0) {
    Write-Log "Backup completed successfully."
} else {
    Write-Log "Backup process exited with code $($process.ExitCode). Possible failure."
} #>

Write-Log "Starting Windows Backup..."
Start-Process -FilePath "sdclt.exe" -ArgumentList "/KICKOFFJOB"

# Wait for wbengine.exe to appear and then exit
Write-Log "Waiting for wbengine.exe to start..."
while (-not (Get-Process -Name "wbengine" -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 2
}

Write-Log "Backup process started. Monitoring until it exits..."
while (Get-Process -Name "wbengine" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 60
}

Write-Log "Backup process completed."

Write-Log "----------------------------------------------------"


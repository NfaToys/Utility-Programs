 
$DriveLetters = @('E:', 'L:')
$MaxAttempts = 20
$DelaySeconds = 10
$LogPath = "C:\temp\WakeDrive.log"
$sourcePath = "C:\temp\dummy.txt"

Function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "MM/dd/yyyy hh:mm tt"
    Add-Content -Path $LogPath -Value "$timestamp - $Message"
}

Function TestDrive {
    param([string]$DriveLetter)

    $destinationPath = "$DriveLetter\dummy.txt"

    try {
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force
        if (Test-Path $destinationPath) {
            Log "[$DriveLetter] Test file copied successfully to $destinationPath"

            Remove-Item -Path $destinationPath -Force
            if (-not (Test-Path $destinationPath)) {
                Log "[$DriveLetter] Test file deleted from $destinationPath"
            } else {
                Log "[$DriveLetter] Failed to delete test file at $destinationPath"
            }
        } else {
            Log "[$DriveLetter] File copy failed: $destinationPath not found"
        }
    } catch {
        Log "[$DriveLetter] Error during file copy or deletion: $_"
    }
}

Function WakeDrive {
    param([string]$DriveLetter)

    Log "---- Starting wake-up attempt for $DriveLetter ----"

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        if (Test-Path "$DriveLetter\") {
            Log "[$DriveLetter] Drive is online (attempt $i)"
            TestDrive -DriveLetter $DriveLetter
            return
        } else {
            Log "[$DriveLetter] Drive not found (attempt $i), retrying in $DelaySeconds seconds..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    Log "[$DriveLetter] Failed to come online after $MaxAttempts attempts"
}

Log "----------------------------------------------------"
# Run wake-up test for each drive
foreach ($Drive in $DriveLetters) {
    WakeDrive -DriveLetter $Drive
}

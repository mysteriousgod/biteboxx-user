# ================= CONFIGURATION =================
 $ftpHost = "ftp://82.112.229.194"
 $username = "u976419005.BiteBoxx08"
 $password = "@BiteBoxx08" # <--- PASTE YOUR PASSWORD HERE
 $remotePath = "/public_html/test_firebase.php" # Where to put the file
# =================================================

# 1. Create the file
 $localFile = "$PSScriptRoot\test_firebase.php"
 $apiKeyToTest = "AIzaSyCeM4Ys7Galsz6-FrMTgPAqIyap6-smIDM"

 $phpContent = @"
<?php
`$apiKey = '$apiKeyToTest'; 
`$url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=' . `$apiKey;
`$data = ['sessionInfo' => 'test', 'phoneNumber' => '+911234567890', 'code' => '123456'];
`$ch = curl_init();
curl_setopt(`$ch, CURLOPT_URL, `$url);
curl_setopt(`$ch, CURLOPT_POST, 1);
curl_setopt(`$ch, CURLOPT_POSTFIELDS, json_encode(`$data));
curl_setopt(`$ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt(`$ch, CURLOPT_RETURNTRANSFER, true);
`$response = curl_exec(`$ch);
`$httpCode = curl_getinfo(`$ch, CURLINFO_HTTP_CODE);
curl_close(`$ch);
echo "<h1>HTTP Status: `$httpCode</h1>";
echo "<pre>" . print_r(json_decode(`$response, true), true) . "</pre>";
?>
"@

Write-Host "Creating local test file..."
Set-Content -Path $localFile -Value $phpContent -Encoding UTF8

# 2. Upload Function
function Upload-FtpFile {
    param($localPath, $remoteUri, $user, $pass)
    
    try {
        $request = [System.Net.FtpWebRequest]::Create($remoteUri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $request.Credentials = New-Object System.Net.NetworkCredential($user, $pass)
        $request.UsePassive = $true
        $request.EnableSsl = $false
        $request.UseBinary = $true
        $request.KeepAlive = $false # <--- FIXED SYNTAX HERE
        
        $fileStream = [System.IO.File]::OpenRead($localPath)
        $requestStream = $request.GetRequestStream()
        $fileStream.CopyTo($requestStream)
        
        $requestStream.Close()
        $fileStream.Close()
        
        $response = $request.GetResponse()
        Write-Host "UPLOAD SUCCESS!" -ForegroundColor Green
        $response.Close()
        return $true
    }
    catch {
        Write-Host "UPLOAD FAILED: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 3. Execute
Write-Host "Uploading to server..."
Upload-FtpFile -localPath $localFile -remoteUri "$ftpHost$remotePath" -user $username -pass $password
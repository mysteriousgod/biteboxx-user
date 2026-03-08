
import ftplib
import os

FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"
FTP_PORT = 21

def download_file(ftp, remote_path, local_path):
    print(f"--- Downloading {remote_path} to {local_path} ---")
    try:
        with open(local_path, 'wb') as f:
            ftp.retrbinary('RETR ' + remote_path, f.write)
        print("Download successful")
    except Exception as e:
        print(f"Error downloading {remote_path}: {e}")

try:
    ftp = ftplib.FTP()
    ftp.connect(FTP_HOST, FTP_PORT)
    ftp.login(FTP_USER, FTP_PASS)
    
    download_file(ftp, "config/cors.php", "cors.php")
    
    ftp.quit()
except Exception as e:
    print(f"FTP Error: {e}")

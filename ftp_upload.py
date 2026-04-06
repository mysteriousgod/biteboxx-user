import ftplib
import os

FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"
FTP_PORT = 21

def upload_file(ftp, local_path, remote_path):
    print(f"--- Uploading {local_path} to {remote_path} ---")
    try:
        with open(local_path, 'rb') as f:
            ftp.storbinary('STOR ' + remote_path, f)
        print("✅ Upload successful")
    except Exception as e:
        print(f"❌ Error uploading {local_path}: {e}")

try:
    ftp = ftplib.FTP()
    ftp.connect(FTP_HOST, FTP_PORT)
    ftp.login(FTP_USER, FTP_PASS)
    ftp.set_pasv(False)  # Required for this server
    print("✅ Connected to FTP server successfully!")
    print(f"📁 Current directory: {ftp.pwd()}")
    
    # Upload helpers.php to the correct location
    local_file = r"..\biteboxx-adminPanel\app\CentralLogics\helpers.php"
    remote_file = "app/CentralLogics/helpers.php"
    
    upload_file(ftp, local_file, remote_file)
    
    ftp.quit()
    print("\n✅ FTP connection closed.")
except Exception as e:
    print(f"❌ FTP Error: {e}")

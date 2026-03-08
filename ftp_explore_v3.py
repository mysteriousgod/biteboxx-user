
import ftplib
import os

FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"
FTP_PORT = 21

def list_files(ftp, path="."):
    print(f"--- Listing {path} ---")
    try:
        ftp.cwd(path)
        ftp.retrlines('LIST')
    except Exception as e:
        print(f"Error listing {path}: {e}")

try:
    ftp = ftplib.FTP()
    ftp.connect(FTP_HOST, FTP_PORT)
    ftp.login(FTP_USER, FTP_PASS)
    
    # Try Active mode to avoid passive mode NAT issues
    ftp.set_pasv(False)
    
    print("Connected to FTP (Active Mode)")
    
    # List root
    list_files(ftp, "/")
    
    ftp.quit()
except Exception as e:
    print(f"FTP Error: {e}")

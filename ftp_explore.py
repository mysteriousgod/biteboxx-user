
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
    
    print("Connected to FTP")
    
    # List root
    list_files(ftp, "/")
    
    # Try to find web root usually domains or public_html or similar
    # Based on the output I will adjust, but for now let's just look at root.
    
    ftp.quit()
except Exception as e:
    print(f"FTP Error: {e}")


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
    
    # List config directory to find cors.php
    list_files(ftp, "/config")
    
    # List root again to look for public or public_html clearly
    print("\n--- Root Revisited ---")
    ftp.cwd("/")
    ftp.retrlines('LIST')

    # Start looking for public folder
    try:
        if "public_html" in ftp.nlst():
            list_files(ftp, "/public_html")
        elif "public" in ftp.nlst():
            list_files(ftp, "/public")
    except:
        pass

    ftp.quit()
except Exception as e:
    print(f"FTP Error: {e}")

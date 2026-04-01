import ftplib
import os

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

# Local file path
local_file = "../biteboxx-adminPanel/download.html"

def upload_to_ftp():
    """Upload download.html to FTP server"""
    
    if not os.path.exists(local_file):
        print(f"Error: Local file '{local_file}' not found!")
        return False
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        # Connect to FTP server
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        print("Connected successfully")
        
        # Login
        ftp.login(ftp_user, ftp_pass)
        print("Logged in successfully")
        
        # Get current directory
        print(f"Current directory: {ftp.pwd()}")
        
        # List files in current directory
        print("\nFiles in web root:")
        ftp.retrlines('LIST')
        
        # Upload to web root
        print(f"\nUploading {local_file} to download.html in web root...")
        with open(local_file, 'rb') as file:
            ftp.storbinary('STOR download.html', file)
        print("Upload to web root successful!")
        
        # Also upload to /app folder if it exists
        print(f"\nUploading to /app/download.html...")
        try:
            with open(local_file, 'rb') as file:
                ftp.storbinary('STOR app/download.html', file)
            print("Upload to /app folder successful!")
        except Exception as e:
            print(f"Could not upload to /app: {e}")
        
        # Verify
        print("\nVerifying upload in web root:")
        ftp.retrlines('LIST')
        
        ftp.quit()
        print("\nDone! File uploaded to:")
        print("  - https://biteboxx.com/download.html")
        print("  - https://biteboxx.com/download (via .htaccess)")
        print("  - https://biteboxx.com/app/download.html")
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - FTP Upload Script")
    print("=" * 50)
    upload_to_ftp()

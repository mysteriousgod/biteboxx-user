import ftplib
import os

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

# Get the base directory (c:\Users\user\Desktop\flutter)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_upload():
    """Upload download.html and .htaccess to correct location"""
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        print("Connected and logged in successfully")
        
        # We're already in /public_html
        print(f"Current directory: {ftp.pwd()}")
        
        # List files
        print("\nFiles in current directory:")
        ftp.retrlines('LIST')
        
        # Delete the nested public_html directory with the file
        print("\nRemoving nested public_html directory...")
        try:
            ftp.cwd('public_html')
            ftp.delete('download.html')
            ftp.cwd('..')
            ftp.rmd('public_html')
            print("Removed nested directory")
        except Exception as e:
            print(f"Note: {e}")
        
        # Upload download.html to correct location (root of public_html)
        print("\nUploading download.html to correct location...")
        download_path = os.path.join(BASE_DIR, "biteboxx-adminPanel", "download.html")
        print(f"Source file: {download_path}")
        with open(download_path, 'rb') as file:
            ftp.storbinary('STOR download.html', file)
        print("download.html uploaded successfully!")
        
        # Upload .htaccess file
        print("\nUploading .htaccess for server-side redirects...")
        htaccess_path = os.path.join(BASE_DIR, "biteboxx-user", "htaccess_download.txt")
        print(f"Source file: {htaccess_path}")
        with open(htaccess_path, 'rb') as file:
            ftp.storbinary('STOR .htaccess', file)
        print(".htaccess uploaded successfully!")
        
        # Verify
        print("\nVerifying upload:")
        ftp.retrlines('LIST')
        
        ftp.quit()
        print("\n" + "=" * 50)
        print("SUCCESS! Files uploaded to biteboxx.com")
        print("=" * 50)
        print("\nAccess URLs:")
        print("  - https://biteboxx.com/download  (server redirect)")
        print("  - https://biteboxx.com/download.html (direct access)")
        print("\nRedirect behavior:")
        print("  - Android devices → Google Play Store")
        print("  - iOS devices → Apple App Store")
        print("  - Desktop/Other → download.html page")
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - Fix Upload Location")
    print("=" * 50)
    fix_upload()
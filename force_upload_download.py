import ftplib
import os
import time

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

# Get the base directory
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def force_upload():
    """Force delete and re-upload files"""
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        print("Connected and logged in successfully")
        
        print(f"Current directory: {ftp.pwd()}")
        
        # List files before
        print("\n=== Files BEFORE upload ===")
        ftp.retrlines('LIST')
        
        # Explicitly delete old files first
        print("\nDeleting old files...")
        try:
            ftp.delete('download.html')
            print("Deleted old download.html")
        except Exception as e:
            print(f"Note deleting download.html: {e}")
        
        try:
            ftp.delete('.htaccess')
            print("Deleted old .htaccess")
        except Exception as e:
            print(f"Note deleting .htaccess: {e}")
        
        # Small delay to ensure deletion completes
        time.sleep(1)
        
        # Upload download.html
        print("\nUploading download.html...")
        download_path = os.path.join(BASE_DIR, "biteboxx-adminPanel", "download.html")
        print(f"Source: {download_path}")
        
        # Verify source file exists
        if not os.path.exists(download_path):
            print(f"ERROR: Source file not found: {download_path}")
            return False
        
        # Read and show first few lines to verify correct file
        with open(download_path, 'r') as f:
            content = f.read()
            print(f"File size: {len(content)} bytes")
            print(f"Contains 'META REFRESH': {'META REFRESH' in content}")
            print(f"Contains Android redirect: {'play.google.com' in content}")
        
        with open(download_path, 'rb') as file:
            ftp.storbinary('STOR download.html', file)
        print("download.html uploaded!")
        
        # Upload .htaccess
        print("\nUploading .htaccess...")
        htaccess_path = os.path.join(BASE_DIR, "biteboxx-user", "htaccess_download.txt")
        print(f"Source: {htaccess_path}")
        
        if not os.path.exists(htaccess_path):
            print(f"ERROR: Source file not found: {htaccess_path}")
            return False
        
        with open(htaccess_path, 'r') as f:
            content = f.read()
            print(f"File size: {len(content)} bytes")
            print(f"Contains RewriteEngine: {'RewriteEngine' in content}")
            print(f"Contains Android rule: {'Android' in content}")
        
        with open(htaccess_path, 'rb') as file:
            ftp.storbinary('STOR .htaccess', file)
        print(".htaccess uploaded!")
        
        time.sleep(1)
        
        # Verify upload
        print("\n=== Files AFTER upload ===")
        ftp.retrlines('LIST')
        
        # Download and verify the uploaded file
        print("\nVerifying uploaded download.html...")
        downloaded_content = []
        ftp.retrbinary('RETR download.html', downloaded_content.append)
        downloaded_text = b''.join(downloaded_content).decode('utf-8')
        
        print(f"Downloaded size: {len(downloaded_text)} bytes")
        print(f"Contains 'META REFRESH': {'META REFRESH' in downloaded_text}")
        print(f"Contains Android redirect: {'play.google.com' in downloaded_text}")
        
        ftp.quit()
        
        print("\n" + "=" * 50)
        print("UPLOAD COMPLETE!")
        print("=" * 50)
        print("\nTest URLs:")
        print("  - https://biteboxx.com/download")
        print("  - https://biteboxx.com/download.html")
        print("\nIf still showing old content:")
        print("  - Clear browser cache (Ctrl+Shift+Delete)")
        print("  - Try incognito/private browsing mode")
        print("  - Wait 1-2 minutes for CDN/cache to refresh")
        
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - Force Upload Files")
    print("=" * 50)
    force_upload()
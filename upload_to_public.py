import ftplib

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

def upload_to_public():
    """Upload download.html to /public directory (Laravel document root)"""
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        print("Connected and logged in successfully")
        
        # Go to root
        ftp.cwd('/')
        print(f"Current directory: {ftp.pwd()}")
        
        # Check /public directory
        try:
            ftp.cwd('public')
            print(f"\n=== Files in /public ({ftp.pwd()}) ===")
            ftp.retrlines('LIST -la')
            ftp.cwd('..')
        except Exception as e:
            print(f"Cannot access /public: {e}")
        
        # Upload download.html to /public
        print("\n=== Uploading download.html to /public ===")
        ftp.cwd('public')
        with open("biteboxx-adminPanel/download.html", 'rb') as file:
            ftp.storbinary('STOR download.html', file)
        print("download.html uploaded to /public!")
        
        # Also upload to /public_html as backup
        print("\n=== Uploading download.html to /public_html ===")
        ftp.cwd('..')
        ftp.cwd('public_html')
        with open("biteboxx-adminPanel/download.html", 'rb') as file:
            ftp.storbinary('STOR download.html', file)
        print("download.html uploaded to /public_html!")
        
        # Verify
        print("\n=== Files in /public ===")
        ftp.cwd('..')
        ftp.cwd('public')
        ftp.retrlines('LIST')
        
        ftp.quit()
        print("\nDone! Try accessing:")
        print("  - https://biteboxx.com/download.html")
        print("  - https://biteboxx.com/download")
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - Upload to /public (Laravel root)")
    print("=" * 50)
    upload_to_public()

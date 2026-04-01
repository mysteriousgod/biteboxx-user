import ftplib

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

def upload_htaccess_to_public():
    """Upload .htaccess with download redirect to /public directory"""
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        print("Connected and logged in successfully")
        
        # Go to /public
        ftp.cwd('/public')
        print(f"Current directory: {ftp.pwd()}")
        
        # Upload .htaccess with download redirect
        print("\nUploading .htaccess with /download redirect...")
        with open("biteboxx-user/htaccess_public.txt", 'rb') as file:
            ftp.storbinary('STOR .htaccess', file)
        print(".htaccess uploaded!")
        
        # Verify
        print("\nDone! Try accessing:")
        print("  - https://biteboxx.com/download")
        print("  - https://biteboxx.com/download.html")
        
        ftp.quit()
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - Upload .htaccess to /public")
    print("=" * 50)
    upload_htaccess_to_public()

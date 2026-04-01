import ftplib

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

def upload_files():
    """Upload download.html and updated .htaccess"""
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        print("Connected and logged in successfully")
        
        print(f"Current directory: {ftp.pwd()}")
        
        # Upload download.html
        print("\nUploading download.html...")
        with open("biteboxx-adminPanel/download.html", 'rb') as file:
            ftp.storbinary('STOR download.html', file)
        print("download.html uploaded!")
        
        # Upload updated .htaccess
        print("\nUploading .htaccess...")
        with open("biteboxx-adminPanel/.htaccess", 'rb') as file:
            ftp.storbinary('STOR .htaccess', file)
        print(".htaccess uploaded!")
        
        # Verify
        print("\nFiles in public_html:")
        ftp.retrlines('LIST')
        
        ftp.quit()
        print("\nDone!")
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - Upload Files")
    print("=" * 50)
    upload_files()

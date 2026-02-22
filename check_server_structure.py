import ftplib

def check_server_structure():
    # FTP server details
    ftp_host = "82.112.229.194"
    ftp_user = "u976419005.BiteBoxx08"
    ftp_pass = "@BiteBoxx08"
    ftp_port = 21
    
    try:
        # Connect to FTP server
        print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        
        print("Connected successfully!")
        
        # List root directory
        print("\n=== Root Directory ===")
        ftp.cwd('/')
        files = ftp.nlst()
        for f in files:
            print(f"  {f}")
        
        # Check admin folder structure
        print("\n=== admin/app/Http/Controllers/Api/V1/Auth ===")
        try:
            ftp.cwd('admin/app/Http/Controllers/Api/V1/Auth')
            files = ftp.nlst()
            for f in files:
                print(f"  {f}")
        except Exception as e:
            print(f"  Error: {e}")
        
        # Check if there's an old_version folder
        print("\n=== Checking for old_version ===")
        try:
            ftp.cwd('/')
            ftp.cwd('admin/old_version/app/Http/Controllers/Api/V1/Auth')
            files = ftp.nlst()
            print("  old_version folder exists!")
            for f in files:
                print(f"  {f}")
        except Exception as e:
            print(f"  No old_version folder or error: {e}")
        
        # Check app folder structure (might be another location)
        print("\n=== app/Http/Controllers/Api/V1/Auth ===")
        try:
            ftp.cwd('/')
            ftp.cwd('app/Http/Controllers/Api/V1/Auth')
            files = ftp.nlst()
            for f in files:
                print(f"  {f}")
        except Exception as e:
            print(f"  Error: {e}")
        
        # Close the connection
        ftp.quit()
        print("\n\nFTP connection closed.")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    check_server_structure()

import ftplib

# FTP credentials
ftp_host = "82.112.229.194"
ftp_user = "u976419005.BiteBoxx08"
ftp_pass = "@BiteBoxx08"
ftp_port = 21

def explore_ftp():
    """Explore FTP structure to find document root"""
    
    print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
    
    try:
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        print("Connected and logged in successfully")
        
        # Start from root
        print(f"\nStarting directory: {ftp.pwd()}")
        
        # List all files in current directory
        print("\n=== All files in current directory ===")
        ftp.retrlines('LIST -la')
        
        # Check if we can go up
        try:
            ftp.cwd('..')
            print(f"\n=== Parent directory: {ftp.pwd()} ===")
            ftp.retrlines('LIST -la')
            ftp.cwd('public_html')
        except Exception as e:
            print(f"Cannot go up: {e}")
        
        # List files in public_html
        print(f"\n=== Files in public_html ({ftp.pwd()}) ===")
        ftp.retrlines('LIST -la')
        
        # Check if download.html exists
        try:
            ftp.cwd('download.html')
            print("download.html is a directory!")
            ftp.cwd('..')
        except:
            print("\ndownload.html is not a directory (good)")
        
        ftp.quit()
        return True
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("BiteBoxx - Explore FTP Structure")
    print("=" * 50)
    explore_ftp()

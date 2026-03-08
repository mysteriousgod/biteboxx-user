import ftplib
import os

def verify_upload():
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
        
        # Check if the file exists on the server
        remote_path = "admin/app/Http/Controllers/Api/V1/Auth"
        print(f"\nChecking directory: {remote_path}")
        
        try:
            ftp.cwd(remote_path)
            files = ftp.nlst()
            print(f"Files in directory: {files}")
            
            # Check CustomerAuthController.php
            if 'CustomerAuthController.php' in files:
                print("\n✓ CustomerAuthController.php exists on server")
                # Get file size
                size = ftp.size('CustomerAuthController.php')
                print(f"  File size: {size} bytes")
            else:
                print("\n✗ CustomerAuthController.php NOT found on server")
            
            # Check PasswordResetController.php
            if 'PasswordResetController.php' in files:
                print("\n✓ PasswordResetController.php exists on server")
                size = ftp.size('PasswordResetController.php')
                print(f"  File size: {size} bytes")
            else:
                print("\n✗ PasswordResetController.php NOT found on server")
                
        except Exception as e:
            print(f"Error checking directory: {e}")
        
        # Close the connection
        ftp.quit()
        print("\nFTP connection closed.")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    verify_upload()

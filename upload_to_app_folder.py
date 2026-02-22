import ftplib
import os

def upload_to_app_folder():
    # FTP server details
    ftp_host = "82.112.229.194"
    ftp_user = "u976419005.BiteBoxx08"
    ftp_pass = "@BiteBoxx08"
    ftp_port = 21
    
    # Local file paths
    local_customer_auth = "biteboxx-backend/admin/app/Http/Controllers/Api/V1/Auth/CustomerAuthController.php"
    local_password_reset = "biteboxx-backend/admin/app/Http/Controllers/Api/V1/Auth/PasswordResetController.php"
    
    # Remote file paths (app folder - the one being used by Laravel)
    remote_customer_auth = "app/Http/Controllers/Api/V1/Auth/CustomerAuthController.php"
    remote_password_reset = "app/Http/Controllers/Api/V1/Auth/PasswordResetController.php"
    
    try:
        # Connect to FTP server
        print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        
        print("Connected successfully!")
        
        # Upload CustomerAuthController.php to app folder
        print(f"\nUploading CustomerAuthController.php to app/Http/Controllers/Api/V1/Auth/")
        ftp.cwd('/')
        ftp.cwd('app/Http/Controllers/Api/V1/Auth')
        
        with open(local_customer_auth, 'rb') as file:
            ftp.storbinary('STOR CustomerAuthController.php', file)
        
        print("✓ CustomerAuthController.php uploaded to app folder!")
        
        # Upload PasswordResetController.php to app folder
        print(f"\nUploading PasswordResetController.php to app/Http/Controllers/Api/V1/Auth/")
        ftp.cwd('/')
        ftp.cwd('app/Http/Controllers/Api/V1/Auth')
        
        with open(local_password_reset, 'rb') as file:
            ftp.storbinary('STOR PasswordResetController.php', file)
        
        print("✓ PasswordResetController.php uploaded to app folder!")
        
        # Close the connection
        ftp.quit()
        print("\nFTP connection closed.")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    upload_to_app_folder()

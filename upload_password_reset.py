import ftplib
import os

def upload_file():
    # FTP server details
    ftp_host = "82.112.229.194"
    ftp_user = "u976419005.BiteBoxx08"
    ftp_pass = "@BiteBoxx08"
    ftp_port = 21
    
    # Local file path
    local_file_path = "biteboxx-backend/admin/app/Http/Controllers/Api/V1/Auth/PasswordResetController.php"
    
    # Remote file path (relative to FTP root)
    remote_file_path = "admin/app/Http/Controllers/Api/V1/Auth/PasswordResetController.php"
    
    try:
        # Connect to FTP server
        print(f"Connecting to FTP server: {ftp_host}:{ftp_port}")
        ftp = ftplib.FTP()
        ftp.connect(ftp_host, ftp_port)
        ftp.login(ftp_user, ftp_pass)
        
        print("Connected successfully!")
        
        # Change to the correct directory
        remote_dir = os.path.dirname(remote_file_path)
        print(f"Changing to directory: {remote_dir}")
        
        # Create directories if they don't exist
        dirs = remote_dir.split('/')
        current_dir = ''
        for directory in dirs:
            if directory:
                current_dir += '/' + directory
                try:
                    ftp.cwd(current_dir)
                except ftplib.error_perm:
                    print(f"Creating directory: {current_dir}")
                    ftp.mkd(current_dir)
                    ftp.cwd(current_dir)
        
        # Upload the file
        print(f"Uploading file: {local_file_path}")
        print(f"To remote location: {remote_file_path}")
        
        with open(local_file_path, 'rb') as file:
            ftp.storbinary(f'STOR {os.path.basename(remote_file_path)}', file)
        
        print("File uploaded successfully!")
        
        # Close the connection
        ftp.quit()
        print("FTP connection closed.")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    upload_file()

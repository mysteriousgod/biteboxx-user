import ftplib

def verify_app_folder():
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
        
        # Download CustomerAuthController.php from app folder
        remote_path = "app/Http/Controllers/Api/V1/Auth/CustomerAuthController.php"
        local_path = "downloaded_app_CustomerAuthController.php"
        
        print(f"\nDownloading {remote_path}...")
        
        with open(local_path, 'wb') as file:
            ftp.retrbinary(f'RETR {remote_path}', file.write)
        
        print(f"Downloaded to {local_path}")
        
        # Read and show the firebase_auth_verify method
        with open(local_path, 'r') as file:
            content = file.read()
            
        # Find the firebase_auth_verify method
        start = content.find('public function firebase_auth_verify')
        if start != -1:
            # Show first 1000 chars of the method
            end = start + 1000
            print("\n=== firebase_auth_verify method from app/ folder ===")
            print(content[start:end])
        else:
            print("\nMethod not found in file!")
        
        # Close the connection
        ftp.quit()
        print("\n\nFTP connection closed.")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    verify_app_folder()

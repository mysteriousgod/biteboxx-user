#!/usr/bin/env python3
"""
Script to check public directory and storage symlink on the server via FTP
"""

from ftplib import FTP

# FTP Configuration
FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"

def check_public():
    try:
        print(f"Connecting to FTP server: {FTP_HOST}")
        ftp = FTP()
        ftp.connect(FTP_HOST, 21)
        ftp.login(FTP_USER, FTP_PASS)
        print("Connected successfully!")
        
        # Check public directory
        print("\n=== Public Directory ===")
        try:
            public_files = ftp.nlst('/public')
            for f in public_files:
                print(f"  {f}")
        except Exception as e:
            print(f"  Error: {e}")
        
        # Check if storage symlink exists in public
        print("\n=== Checking for storage symlink in public ===")
        try:
            public_storage = ftp.nlst('/public/storage')
            print(f"Found /public/storage:")
            for f in public_storage[:10]:
                print(f"  {f}")
        except Exception as e:
            print(f"  /public/storage not found: {e}")
            print("  This is likely the problem - storage symlink is missing!")
        
        # Check .htaccess in public
        print("\n=== Checking /public/.htaccess ===")
        try:
            contents = []
            ftp.retrlines('RETR /public/.htaccess', contents.append)
            print("Contents:")
            for line in contents:
                print(f"  {line}")
        except Exception as e:
            print(f"  Could not read: {e}")
        
        # Check the actual image file
        print("\n=== Checking specific image file ===")
        test_file = '/storage/app/public/category/2025-09-28-68d9573f089ea.png'
        try:
            size = ftp.size(test_file)
            print(f"  File: {test_file}")
            print(f"  Size: {size} bytes")
            
            # Try to download first few bytes
            buffer = []
            def collect_data(data):
                buffer.append(data)
            
            # Use RETR command to check if file is readable
            ftp.voidcmd('TYPE I')  # Binary mode
            conn = ftp.transfercmd(f'RETR {test_file}', rest=None)
            data = conn.recv(1024)
            conn.close()
            ftp.voidresp()
            print(f"  First 100 bytes: {data[:100]}")
            print(f"  File appears to be valid binary data: {len(data)} bytes read")
        except Exception as e:
            print(f"  Error checking file: {e}")
        
        # Check main directory (might be where the site is served from)
        print("\n=== Checking /main directory ===")
        try:
            main_files = ftp.nlst('/main')
            for f in main_files[:20]:
                print(f"  {f}")
        except Exception as e:
            print(f"  Error: {e}")
        
        # Check /new directory
        print("\n=== Checking /new directory ===")
        try:
            new_files = ftp.nlst('/new')
            for f in new_files[:20]:
                print(f"  {f}")
        except Exception as e:
            print(f"  Error: {e}")
        
        ftp.quit()
        print("\n=== FTP connection closed ===")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_public()
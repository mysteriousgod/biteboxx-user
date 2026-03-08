#!/usr/bin/env python3
"""
Script to check storage files on the server via FTP
"""

from ftplib import FTP
import io

# FTP Configuration
FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"

def check_storage():
    try:
        print(f"Connecting to FTP server: {FTP_HOST}")
        ftp = FTP()
        ftp.connect(FTP_HOST, 21)
        ftp.login(FTP_USER, FTP_PASS)
        print("Connected successfully!")
        
        # List root directory
        print("\n=== Root Directory ===")
        root_files = ftp.nlst()
        for f in root_files:
            print(f"  {f}")
        
        # Check for storage directory
        possible_paths = [
            '/storage',
            '/public_html/storage',
            '/public_html/biteboxx.com/storage',
            '/domains/biteboxx.com/public_html/storage',
            '/app/storage',
            '/storage/app',
            '/storage/app/public',
        ]
        
        for path in possible_paths:
            try:
                print(f"\n=== Checking path: {path} ===")
                files = ftp.nlst(path)
                print(f"Found {len(files)} items:")
                for f in files[:10]:  # Show first 10
                    print(f"  {f}")
                if len(files) > 10:
                    print(f"  ... and {len(files) - 10} more")
            except Exception as e:
                print(f"  Path not accessible: {e}")
        
        # Try to find category images
        category_paths = [
            '/storage/app/public/category',
            '/public_html/storage/app/public/category',
            '/domains/biteboxx.com/public_html/storage/app/public/category',
        ]
        
        for path in category_paths:
            try:
                print(f"\n=== Checking category images: {path} ===")
                files = ftp.nlst(path)
                print(f"Found {len(files)} category images:")
                for f in files[:5]:
                    print(f"  {f}")
                    # Try to get file size
                    try:
                        size = ftp.size(f)
                        print(f"    Size: {size} bytes")
                    except:
                        pass
            except Exception as e:
                print(f"  Path not accessible: {e}")
        
        # Check .htaccess in storage
        htaccess_paths = [
            '/storage/app/public/.htaccess',
            '/public_html/storage/app/public/.htaccess',
        ]
        
        for path in htaccess_paths:
            try:
                print(f"\n=== Checking .htaccess: {path} ===")
                contents = []
                ftp.retrlines(f'RETR {path}', contents.append)
                print("Contents:")
                for line in contents:
                    print(f"  {line}")
            except Exception as e:
                print(f"  Could not read .htaccess: {e}")
        
        ftp.quit()
        print("\n=== FTP connection closed ===")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_storage()
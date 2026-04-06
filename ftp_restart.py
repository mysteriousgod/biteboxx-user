import ftplib
import os
import time

FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"
FTP_PORT = 21

def upload_file(ftp, local_path, remote_path):
    print(f"--- Uploading {local_path} to {remote_path} ---")
    try:
        with open(local_path, 'rb') as f:
            ftp.storbinary('STOR ' + remote_path, f)
        print("✅ Upload successful")
        return True
    except Exception as e:
        print(f"❌ Error uploading: {e}")
        return False

def delete_file(ftp, remote_path):
    try:
        ftp.delete(remote_path)
        print(f"✅ Deleted: {remote_path}")
        return True
    except Exception as e:
        print(f"❌ Error deleting {remote_path}: {e}")
        return False

# Create cache clear PHP script
cache_clear_script = '''<?php
// Cache clearing script
exec('php artisan cache:clear');
exec('php artisan config:clear');
exec('php artisan route:clear');
exec('php artisan view:clear');
exec('php artisan optimize:clear');

// Also manually delete cache files
$cache_dirs = [
    'bootstrap/cache/',
    'storage/framework/cache/',
    'storage/framework/views/'
];

foreach($cache_dirs as $dir) {
    if(is_dir($dir)) {
        $files = glob($dir . '*');
        foreach($files as $file) {
            if(is_file($file) && basename($file) != '.gitignore') {
                unlink($file);
            }
        }
    }
}

echo "Cache cleared successfully!";
?>
'''

try:
    ftp = ftplib.FTP()
    ftp.connect(FTP_HOST, FTP_PORT)
    ftp.login(FTP_USER, FTP_PASS)
    ftp.set_pasv(False)
    print("✅ Connected to FTP server")
    
    # Upload cache clearing script
    script_path = 'clear_cache_temp.php'
    with open('clear_cache_temp.php', 'w') as f:
        f.write(cache_clear_script)
    
    print("\n📤 Uploading cache clear script...")
    if upload_file(ftp, 'clear_cache_temp.php', script_path):
        print("\n✅ Now access https://biteboxx.com/clear_cache_temp.php in your browser")
        print("   OR via Hostinger File Manager to execute the cache clearing")
        print("\n⚠️  IMPORTANT: Delete this file after running for security!")
    
    # Clean up local temp file
    if os.path.exists('clear_cache_temp.php'):
        os.remove('clear_cache_temp.php')
    
    # Alternative: Touch the helpers.php file to ensure it's recognized
    print("\n🔄 Alternative: Verifying helpers.php upload...")
    ftp.cwd('app/CentralLogics')
    files = []
    ftp.retrlines('LIST', files.append)
    for file_info in files:
        if 'helpers.php' in file_info:
            print(f"✅ helpers.php found on server: {file_info}")
            break
    
    ftp.quit()
    print("\n✅ Server refresh complete!")
    
except Exception as e:
    print(f"❌ Error: {e}")

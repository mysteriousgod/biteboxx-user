#!/usr/bin/env python3
"""
Script to create storage symlink on the server via FTP
Since FTP doesn't support symlinks directly, we'll create a PHP script to do it
"""

from ftplib import FTP
import io

# FTP Configuration
FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"

# PHP script to create symlink
PHP_SCRIPT = '''<?php
// Storage symlink fixer
$target = __DIR__ . '/../storage/app/public';
$link = __DIR__ . '/storage';

echo "Target: $target\\n";
echo "Link: $link\\n";

// Check if target exists
if (!is_dir($target)) {
    die("ERROR: Target directory does not exist: $target\\n");
}

// Remove existing link or directory
if (is_link($link) || file_exists($link)) {
    if (is_link($link)) {
        unlink($link);
        echo "Removed existing symlink\\n";
    } elseif (is_dir($link)) {
        // It's a directory, not a symlink - need to handle differently
        echo "WARNING: $link is a directory, not a symlink\\n";
        // Try to remove it
        rmdir($link);
        echo "Removed directory\\n";
    }
}

// Create symlink
if (symlink($target, $link)) {
    echo "SUCCESS: Symlink created!\\n";
    
    // Verify
    if (is_link($link)) {
        echo "Verified: $link is now a symlink\\n";
        echo "Points to: " . readlink($link) . "\\n";
    }
} else {
    echo "ERROR: Failed to create symlink\\n";
    echo "Trying alternative method...\\n";
    
    // Alternative: Create .htaccess rewrite
    $htaccess = '
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^storage/(.*)$ ../storage/app/public/$1 [L]
</IfModule>
';
    file_put_contents(__DIR__ . '/.htaccess', file_get_contents(__DIR__ . '/.htaccess') . $htaccess);
    echo "Added rewrite rule to .htaccess\\n";
}
?>
'''

def fix_symlink():
    try:
        print(f"Connecting to FTP server: {FTP_HOST}")
        ftp = FTP()
        ftp.connect(FTP_HOST, 21)
        ftp.login(FTP_USER, FTP_PASS)
        print("Connected successfully!")
        
        # Upload the PHP script
        print("\n=== Uploading fix_storage_symlink.php ===")
        php_content = PHP_SCRIPT.encode('utf-8')
        ftp.storbinary('STOR /public/fix_storage_symlink.php', io.BytesIO(php_content))
        print("Uploaded fix_storage_symlink.php")
        
        # Also create a simple PHP info file to check server config
        php_info = '<?php phpinfo(); ?>'
        ftp.storbinary('STOR /public/phpinfo_check.php', io.BytesIO(php_info.encode('utf-8')))
        print("Uploaded phpinfo_check.php")
        
        ftp.quit()
        print("\n=== FTP connection closed ===")
        
        print("\n" + "="*60)
        print("NEXT STEPS:")
        print("="*60)
        print("1. Open this URL in your browser:")
        print("   https://biteboxx.com/fix_storage_symlink.php")
        print("")
        print("2. The script will create the storage symlink")
        print("")
        print("3. After running, delete the script for security:")
        print("   - Delete /public/fix_storage_symlink.php")
        print("   - Delete /public/phpinfo_check.php")
        print("="*60)
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    fix_symlink()
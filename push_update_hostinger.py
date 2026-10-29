import ftplib
import os
import re
import sys
import urllib.request
import json

FTP_HOST = "82.112.229.194"
FTP_USER = "u976419005.BiteBoxx08"
FTP_PASS = "@BiteBoxx08"
FTP_PORT = 21

BASE_LOCAL = r"C:\Users\user\Desktop\flutter\biteboxx-adminPanel"

FILES_TO_UPLOAD = [
    r"app\Http\Controllers\Api\V1\CustomerController.php",
    r"app\Http\Controllers\Api\V1\Auth\CustomerAuthController.php",
    r"app\Models\User.php",
    r"routes\api\v1\api.php",
    r"app\Console\Kernel.php",
    r"app\Console\Commands\PurgeScheduledAccounts.php",
    r"database\migrations\2026_10_25_000000_add_deletion_scheduled_at_to_users_table.php",
]

def custom_makepasv(ftp_obj):
    resp = ftp_obj.sendcmd('PASV')
    if resp.startswith('229'):
        m = re.search(r'\(\|\|\|(\d+)\|\)', resp)
        if m:
            return ftp_obj.host, int(m.group(1))
    return ftplib.parse227(resp)

def ensure_remote_dir(ftp, remote_dir):
    parts = remote_dir.replace('\\', '/').strip('/').split('/')
    current = "/public_html"
    for part in parts:
        if not part:
            continue
        current += "/" + part
        try:
            ftp.cwd(current)
        except ftplib.error_perm:
            try:
                print(f"Creating remote dir: {current}")
                ftp.mkd(current)
                ftp.cwd(current)
            except Exception as e:
                print(f"Directory create warning {current}: {e}")

def deploy():
    print(f"Connecting to Hostinger FTP: {FTP_HOST}:{FTP_PORT}...")
    ftp = ftplib.FTP()
    ftp.connect(FTP_HOST, FTP_PORT, timeout=30)
    ftp.login(FTP_USER, FTP_PASS)
    ftp.makepasv = lambda: custom_makepasv(ftp)
    print("Logged in successfully to Hostinger FTP!")

    # 1. Upload Backend application files
    for rel_path in FILES_TO_UPLOAD:
        local_path = os.path.join(BASE_LOCAL, rel_path)
        if not os.path.exists(local_path):
            print(f"ERROR: Local file not found: {local_path}")
            continue

        remote_rel = rel_path.replace('\\', '/')
        remote_dir = os.path.dirname(remote_rel)
        filename = os.path.basename(remote_rel)

        ftp.cwd("/public_html")
        ensure_remote_dir(ftp, remote_dir)

        print(f"Uploading: {rel_path} -> /public_html/{remote_rel}")
        with open(local_path, "rb") as f:
            ftp.storbinary(f"STOR {filename}", f)
        print(f"  OK: {filename}")

    # 2. Update run_db_migration.php to apply database changes for deletion_scheduled_at
    migration_php = """<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\\Contracts\\Console\\Kernel::class);
$kernel->bootstrap();

use Illuminate\\Support\\Facades\\Schema;
use Illuminate\\Database\\Schema\\Blueprint;

$response = [];

try {
    if (!Schema::hasColumn('users', 'deletion_scheduled_at')) {
        Schema::table('users', function (Blueprint $table) {
            $table->timestamp('deletion_scheduled_at')->nullable()->after('status');
        });
        $response['users_deletion_scheduled_at'] = 'Added successfully';
    } else {
        $response['users_deletion_scheduled_at'] = 'Already exists';
    }

    if (!Schema::hasColumn('users', 'deletion_reason')) {
        Schema::table('users', function (Blueprint $table) {
            $table->string('deletion_reason')->nullable()->after('deletion_scheduled_at');
        });
        $response['users_deletion_reason'] = 'Added successfully';
    } else {
        $response['users_deletion_reason'] = 'Already exists';
    }
} catch (\\Throwable $e) {
    $response['error'] = $e->getMessage();
}

header('Content-Type: application/json');
echo json_encode($response, JSON_PRETTY_PRINT);
"""
    local_migration_file = "run_db_migration_update.php"
    with open(local_migration_file, "w", encoding="utf-8") as f:
        f.write(migration_php)

    ftp.cwd("/public_html")
    print("Uploading updated run_db_migration.php...")
    with open(local_migration_file, "rb") as f:
        ftp.storbinary("STOR run_db_migration.php", f)
    print("  OK: run_db_migration.php uploaded.")

    ftp.quit()
    print("\nFTP Uploads Completed!")

    # 3. Trigger run_db_migration.php over HTTPS to execute database changes
    print("\nTriggering DB migration via HTTPS (https://biteboxx.com/run_db_migration.php)...")
    req = urllib.request.Request(
        "https://biteboxx.com/run_db_migration.php",
        headers={"User-Agent": "Mozilla/5.0"}
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            content = resp.read().decode('utf-8')
            print(f"Migration response HTTP {resp.status}:\n{content}")
    except Exception as e:
        print(f"Migration trigger error: {e}")

if __name__ == "__main__":
    deploy()

import ftplib
import re

def custom_makepasv(ftp_obj):
    resp = ftp_obj.sendcmd('PASV')
    if resp.startswith('229'):
        m = re.search(r'\(\|\|\|(\d+)\|\)', resp)
        if m:
            return ftp_obj.host, int(m.group(1))
    return ftplib.parse227(resp)

ftp = ftplib.FTP()
ftp.connect("82.112.229.194", 21)
ftp.login("u976419005.BiteBoxx08", "@BiteBoxx08")
ftp.makepasv = lambda: custom_makepasv(ftp)

ftp.cwd("/")
with open("downloaded_root_htaccess.txt", "wb") as f:
    ftp.retrbinary("RETR .htaccess", f.write)

with open("downloaded_root_index.php", "wb") as f:
    ftp.retrbinary("RETR index.php", f.write)

ftp.quit()

print("Root .htaccess:")
with open("downloaded_root_htaccess.txt", "r") as f:
    print(f.read())

print("\nRoot index.php:")
with open("downloaded_root_index.php", "r") as f:
    print(f.read())

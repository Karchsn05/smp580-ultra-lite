#!/usr/bin/env python3
import sys
import os
import requests

if len(sys.argv) < 3:
    print("Kullanim: download_rom.py <ROM_URL> <OUTPUT_FILE>")
    sys.exit(1)

target_url = sys.argv[1]
output_file = sys.argv[2]

mirrors = [
    target_url,
    "https://phoenixnap.dl.sourceforge.net/project/eosbuildsronnz98/SamsungSmartphones/e-3.1.1-s-20250831-UNOFFICIAL-gtanotexlwifi.zip",
    "https://altushost-swe.dl.sourceforge.net/project/eosbuildsronnz98/SamsungSmartphones/e-3.1.1-s-20250831-UNOFFICIAL-gtanotexlwifi.zip",
    "https://deac-riga.dl.sourceforge.net/project/eosbuildsronnz98/SamsungSmartphones/e-3.1.1-s-20250831-UNOFFICIAL-gtanotexlwifi.zip"
]

# Ensure output directory exists
os.makedirs(os.path.dirname(os.path.abspath(output_file)), exist_ok=True)

success = False
for idx, url in enumerate(mirrors):
    print(f"[*] [{idx+1}/{len(mirrors)}] Mirror deneniyor: {url}")
    try:
        session = requests.Session()
        session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
        })
        
        with session.get(url, stream=True, timeout=90, allow_redirects=True) as response:
            content_length = int(response.headers.get("Content-Length", 0))
            content_type = response.headers.get("Content-Type", "")
            
            # ROM dosyalari genellikle > 300MB ve binary olmalidir
            if response.status_code == 200 and content_length > 50000000:
                print(f"[+] Baglanti basarili! Dosya Boyutu: {content_length / (1024*1024):.2f} MB")
                print(f"[+] Indiriliyor: {output_file} ...")
                
                downloaded = 0
                with open(output_file, "wb") as f:
                    for chunk in response.iter_content(chunk_size=2*1024*1024):
                        if chunk:
                            f.write(chunk)
                            downloaded += len(chunk)
                            if downloaded % (50*1024*1024) == 0:
                                print(f"  -> {downloaded / (1024*1024):.1f} MB indirildi...")
                
                if os.path.getsize(output_file) == content_length or content_length == 0:
                    print(f"[✓] Indirme basariyla tamamlandi: {output_file} ({os.path.getsize(output_file) / (1024*1024):.2f} MB)")
                    success = True
                    break
            else:
                print(f"[-] Mirror gecersiz yanit verdi: Status {response.status_code}, Boyut: {content_length} bytes, Tip: {content_type}")
    except Exception as err:
        print(f"[-] Mirror baglanti hatasi: {err}")

if not success:
    print("[!] Tum mirrorlar basarisiz oldu!")
    sys.exit(1)

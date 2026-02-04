#!/bin/bash

# Membuat folder permanen
mkdir -p "$HOME/LKS/tool"

# Menyalin file ke folder permanen agar path di helios.sh tidak patah
cp helios.sh helios.txt "$HOME/LKS/tool/"

# Memberi izin eksekusi
chmod +x "$HOME/LKS/tool/helios.sh"

# Membuat shortcut global (Symbolic Link)
echo "[!] Mendaftarkan perintah helios ke sistem..."
sudo ln -sf "$HOME/LKS/tool/helios.sh" /usr/local/bin/helios

echo "[+] Setup Selesai! Silakan ketik 'helios' untuk mencoba."

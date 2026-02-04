#!/bin/bash

# 1. Pastikan folder tujuan ada
mkdir -p "$HOME/LKS/tool"

# 2. Copy file ke folder tujuan
cp helios.sh "$HOME/LKS/tool/helios.sh"
cp helios.txt "$HOME/LKS/tool/helios.txt"
chmod +x "$HOME/LKS/tool/helios.sh"

# 3. Bikin supaya bisa dipanggil dengan ketik 'helios' saja
# Kita buat link di /usr/local/bin (butuh sudo)
echo "[!] Menyiapkan akses perintah 'helios'..."
sudo ln -sf "$HOME/LKS/tool/helios.sh" /usr/local/bin/helios

echo "[+] Selesai! Sekarang kamu bisa ketik 'helios' di mana saja."

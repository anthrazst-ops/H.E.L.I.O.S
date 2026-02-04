#!/bin/bash

# Konfigurasi Wordlist Global
WORDLIST="$HOME/LKS/tool/helios.txt"

# Variabel Warna (Bold Edition)
BLU='\033[1;34m'   # EXTREME
GRA='\033[1;32m'   # FAST
YEL='\033[1;33m'   # MED
RED='\033[1;31m'   # SLOW / ERROR
SUN_ORA='\033[1;38;5;208m' # Oranye Bold
CYA='\033[1;36m'   # Path Bold
NC='\033[0m'

show_banner() {
    # ASCII Art & Nama Helios dibuat Bold
    echo -e "${SUN_ORA}"
    echo -e "        \033[1m  \\ | /"
    echo -e "        '-.ooo.-'"
    echo -e "        --ooooooo--"
    echo -e "        .-'ooo'-."
    echo -e "          / | \\"
    echo -e "      [ H.E.L.I.O.S ]${NC}"
    # Deskripsi & Team dibuat Bold
    echo -e "${SUN_ORA}\033[1mCustom Directory Brute-Force Tool${NC}"
    echo -e "${RED}\033[1mMade by: Alphabet Offensive Team (SMK YAPALIS KRIAN)${NC}"
}

print_header() {
    echo -e "${SUN_ORA}---------------------------------------------------------------------------${NC}"
    printf "${YEL}%-12s | %-12s | %-s${NC}\n" "STATUS" "SIZE/INFO" "PATH / FINDING"
    echo -e "${SUN_ORA}---------------------------------------------------------------------------${NC}"
}

# Fungsi Progress Dinamis
run_progress() {
    local COLOR=$1
    echo -ne "${YEL}[!] Warming up engine...${NC}\r"
    for i in {0..100..25}; do 
        echo -ne "Progress: [${COLOR}$(printf '%*s' $((i/10)) | tr ' ' '#')${NC}$(printf '%*s' $((10-i/10)) | tr ' ' '.') ] ($i%)\r"
        sleep 0.1
    done
    tput el
}

check_cmd() {
    if ! command -v "$1" &> /dev/null; then
        printf "${RED}%-12s${NC} | %-12s | ${RED}Error: Tool '%s' Not Found!${NC}\n" "[ERROR]" "MISSING" "$1"
        return 1
    fi
    return 0
}

show_usage() {
    show_banner
    echo -e "${SUN_ORA}---------------------------------------------------------------------------${NC}"
    # DITAMBAHKAN OPSI -i DISINI
    echo -e "${YEL}\033[1mUsage:${NC} helios -u <URL> | -i <IP> [-t <TOOL>] [-p <PROXY>]"
    echo -e "${SUN_ORA}---------------------------------------------------------------------------${NC}"
    echo -e "${YEL}\033[1mSelect Tool (-t):${NC}"
    echo -e "  1. helios    ${BLU}[EXTREME]${NC} : Custom HELIOS Engine"
    echo -e "  2. gobuster  ${GRA}[FAST]   ${NC} : Go-based brute forcer"
    echo -e "  3. dirb      ${YEL}[MED]    ${NC} : Classic scanner"
    echo -e "  4. nikto     ${RED}[SLOW]   ${NC} : Vulnerability scan"
    echo -e "${SUN_ORA}---------------------------------------------------------------------------${NC}"
}

# --- TOOLS ENGINES ---

run_nikto() {
    check_cmd "nikto" || return
    run_progress "$RED"
    echo -e "${RED}[+] Mode: Nikto${NC}"
    print_header
    PROXY_CMD=""
    if [ ! -z "$PROXY" ]; then PROXY_CMD="-useproxy $PROXY"; fi
    nikto -h "$TARGET" $PROXY_CMD -nointeractive -maxtime 300s 2>/dev/null | stdbuf -oL grep "^+" | while read -r line; do
        clean_info=$(echo "$line" | sed 's/^+ //g')
        printf "${RED}%-12s${NC} | %-12s | ${CYA}%s${NC}\n" "VULN" "NIKTO_SCAN" "$clean_info"
    done
}

run_gobuster() {
    check_cmd "gobuster" || return
    run_progress "$GRA"
    echo -e "${GRA}[+] Mode: Gobuster${NC}"
    print_header
    PROXY_CMD=""
    if [ ! -z "$PROXY" ]; then PROXY_CMD="--proxy $PROXY"; fi
    gobuster dir -u "$TARGET" -w "$WORDLIST" $PROXY_CMD -t 50 --no-error -q | while read -r line; do
        path=$(echo "$line" | awk '{print $1}')
        status=$(echo "$line" | grep -oP 'Status: \K\d+')
        size=$(echo "$line" | grep -oP 'Size: \K\d+')
        if [ -z "$status" ]; then continue; fi
        [[ $status == 200* ]] && COL=$GRA || COL=$RED
        [[ $status == 30* ]] && COL=$YEL
        printf "${COL}%-12s${NC} | %-12s | ${CYA}%s${NC}\n" "[$status]" "$size" "$path"
    done
}

run_dirb() {
    check_cmd "dirb" || return
    run_progress "$YEL"
    echo -e "${YEL}[+] Mode: Dirb${NC}"
    print_header
    if [ ! -z "$PROXY" ]; then export http_proxy="$PROXY"; export https_proxy="$PROXY"; fi
    dirb "$TARGET" "$WORDLIST" -r -S | stdbuf -oL grep "(CODE:" | while read -r line; do
        path=$(echo "$line" | awk '{print $2}')
        status=$(echo "$line" | grep -oP 'CODE:\K\d+')
        size=$(echo "$line" | grep -oP 'SIZE:\K\d+')
        [[ $status == 200* ]] && COL=$GRA || COL=$RED
        printf "${COL}%-12s${NC} | %-12s | ${CYA}%s${NC}\n" "[$status]" "$size" "$path"
    done
}

run_helios_engine() {
    check_cmd "ffuf" || return
    run_progress "$BLU"
    echo -e "${BLU}[+] Mode: Helios Engine${NC}"
    print_header
    PROXY_CMD=""
    if [ ! -z "$PROXY" ]; then PROXY_CMD="-x $PROXY"; fi
    ffuf -u "$TARGET/FUZZ" -w "$WORDLIST" $PROXY_CMD -mc 200,204,301,302,307,401,403 -ic -t 50 -s -json | while read -r line; do
        status=$(echo "$line" | grep -oP '"status":\K\d+')
        size=$(echo "$line" | grep -oP '"length":\K\d+')
        raw_endpoint=$(echo "$line" | sed 's/.*"FUZZ":"\([^"]*\)".*/\1/')
        if [[ "$raw_endpoint" =~ ^[A-Za-z0-9+/]+={0,2}$ ]]; then
            endpoint=$(echo "$raw_endpoint" | base64 -d 2>/dev/null || echo "$raw_endpoint")
        else endpoint="$raw_endpoint"; fi
        if [ ! -z "$status" ]; then
            [[ $status == 200* ]] && COL=$GRA || COL=$RED
            [[ $status == 30* ]] && COL=$YEL
            printf "${COL}%-12s${NC} | %-12s | ${CYA}/%s${NC}\n" "[$status]" "$size" "$endpoint"
        fi
    done
}

# --- MAIN ---
if [ $# -eq 0 ]; then show_usage; exit 0; fi
TARGET=""; TOOL="helios"; PROXY=""
# Nambah i: di getopts
while getopts "u:i:t:p:h" opt; do
  case $opt in
    u) TARGET="$OPTARG" ;;
    i) TARGET="http://$OPTARG" ;; # Logic IP otomatis tambah http
    t) TOOL="$OPTARG" ;;
    p) PROXY="$OPTARG" ;;
    h) show_usage; exit 0 ;;
    *) show_usage; exit 1 ;;
  esac
done

if [ -z "$TARGET" ]; then echo -e "${RED}[!] Error: Target (-u atau -i) Required!${NC}"; exit 1; fi

# Tambahkan http:// jika input lewat -u lupa protokol
if [[ ! $TARGET =~ ^https?:// ]]; then
    TARGET="http://$TARGET"
fi
TARGET="${TARGET%/}"

clear; show_banner
echo -e "Target: ${YEL}\033[1m$TARGET${NC}"

case $TOOL in
    helios)    run_helios_engine ;;
    nikto)     run_nikto ;;
    gobuster)  run_gobuster ;;
    dirb)      run_dirb ;;
    *) echo -e "${RED}[!] Tool '$TOOL' Not Found.${NC}"; exit 1 ;;
esac

echo -e "${SUN_ORA}---------------------------------------------------------------------------${NC}"
echo -e "${YEL}\033[1m[*] [H.E.L.I.O.S]: DONE.${NC}"

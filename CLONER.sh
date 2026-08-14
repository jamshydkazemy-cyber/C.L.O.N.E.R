#!/bin/bash

echo "enter the main domain :"
read domain


directory=${domain}_recon
echo "creating directory $directory"
mkdir $directory
cd "$directory" || exit

amass_scan()
{
    mkdir -p amass
    echo "[*] Running Amass Passive..."
    amass enum -passive -d $domain > amass/amass.txt 
    sleep 0.25
    echo "[*] Running Amass active..."
    amass enum -active -d $domain > amass/amass-active.txt 
    sort -u amass/amass.txt amass/amass-active.txt -o amass/amass-unique.txt 
    echo "The results of amass scan are stored in $directory/amass/."
}

subfinder_scan()
{
    mkdir -p subfinder
    echo "[*] Running subfinder active ..."
    subfinder -d $domain -o subfinder/subfinder.txt
    echo "The results of subfinder parsing is stored in $directory/subfinder."
    sleep 0.25
}

crt_scan()
{
    mkdir -p crt
    echo "[*] Running crt.sh Passive..."
    curl "https://crt.sh/?q=$domain&output=json" | jq -r '.[].name_value' > crt/ctr.txt
    echo "The results of cert parsing is stored in $directory/crt."
    sleep 0.25
}

waybackurls_scan()
{
    mkdir -p waybackurls
    echo "[*] Running waybackurls passive ..."
    waybackurls $domain | sort -u > waybackurls/wayback.txt 
    cat wayback.txt | grep '?' | grep '=' | sort -u > waybackurls/params.txt
    echo "The results of waybackurls parsing is stored in $directory/waybackurls."
    sleep 0.25
}

whois_scan()
{
    mkdir -p whois
    echo "[*] Running WHOIS..."
    whois $domain > whois/whois.txt 2>&1
    echo "[+] WHOIS results stored in $directory/whois/"
}

amass_scan
subfinder_scan
crt_scan
waybackurls_scan
whois_scan

echo
echo "✅ All scans completed successfully!"
echo "Results are in: $(pwd)"
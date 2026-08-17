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

extract_and_nmap_scan() {
    mkdir -p external_domains
    mkdir -p nmap_results

    echo "[*] Extracting unique root domains from previous scans..."

    cat subfinder/subfinder.txt crt/ctr.txt waybackurls/wayback.txt 2>/dev/null | \
    grep -oE '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' | \
    awk -F. '{if (NF>1) print $(NF-1)"."$NF}' | \
    sort -u > external_domains/unique_domains.txt

    echo "[+] Found unique domains:"
    cat external_domains/unique_domains.txt

    echo "[*] Starting Nmap scan on each unique domain..."


    while read -r ext_domain; do
        if [ -n "$ext_domain" ]; then
            echo "[*] Running Nmap on: $ext_domain"
            nmap -sV -F "$ext_domain" -oN "nmap_results/nmap_${ext_domain}.txt"
        fi
    done < external_domains/unique_domains.txt

    echo "[+] All Nmap scans completed. Results stored in $directory/nmap_results/"
    sleep 0.25
}

amass_scan
subfinder_scan
crt_scan
waybackurls_scan
whois_scan
extract_and_nmap_scan

echo
echo "✅ All scans completed successfully!"
echo "Results are in: $(pwd)"
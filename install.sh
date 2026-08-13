#!/bin/bash

# ساخت یک فایل موقت برای ذخیره خطاهایی که در طول اجرای اسکریپت رخ می‌دهند
ERROR_LOG=$(mktemp)
FAILED_TOOLS=()
SUCCESS_TOOLS=()

# تابعی برای نصب ابزارها و بررسی وضعیت نصب
install_tool() {
    local tool_name=$1
    echo "----------------------------------------"
    echo "📦 Installing $tool_name...."
    echo "----------------------------------------"
    
    # اجرای دستور نصب و هدایت خطاهای احتمالی به فایل لوگ
    if sudo apt install -y "$tool_name" 2>> "$ERROR_LOG"; then
        echo "✅ $tool_name installed successfully."
        SUCCESS_TOOLS+=("$tool_name")
    else
        echo "❌ Failed to install $tool_name!"
        FAILED_TOOLS+=("$tool_name")
    fi
    echo ""
}

echo "🚀 Starting the installation process..."
echo ""

# لیست ابزارهای شما برای نصب
TOOLS=("amass" "subfinder" "whois" "nmap" "gobuster" "ffuf" "nuclei")

# حلقه برای نصب تک‌تک ابزارها
for tool in "${TOOLS[@]}"; do
    install_tool "$tool"
done


echo "========================================"
echo "📊 INSTALLATION SUMMARY"
echo "========================================"

# اگر ابزاری با موفقیت نصب شده بود
if [ ${#SUCCESS_TOOLS[@]} -gt 0 ]; then
    echo "✅ Successfully installed tools (${#SUCCESS_TOOLS[@]}):"
    for tool in "${SUCCESS_TOOLS[@]}"; do
        echo "   - $tool"
    done
    echo ""
fi

# اگر خطایی در طول نصب وجود داشت
if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    echo "❌ Failed tools (${#FAILED_TOOLS[@]}):"
    for tool in "${FAILED_TOOLS[@]}"; do
        echo "   - $tool"
    done
    echo ""
    echo "⚠️ Detailed Error Logs:"
    echo "----------------------------------------"
    cat "$ERROR_LOG"
    echo "----------------------------------------"
else
    echo "🎉 All tools have been successfully installed without any errors!"
fi


rm -f "$ERROR_LOG"
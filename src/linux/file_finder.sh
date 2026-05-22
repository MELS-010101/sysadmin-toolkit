# Module: File Finder
VERSION="1.0.0"

OS_TYPE="$(uname)"
search_dir="${1:-.}"
min_size="${2:-100}"

echo "--- Files larger than ${min_size}MB in ${search_dir} ---"

if [ "$OS_TYPE" = "MINGW"* ] || [ "$OS_TYPE" = "MSYS"* ]; then
    # Windows - use dir or powershell
    echo "Note: On Windows, using PowerShell for search..."
    powershell -Command "Get-ChildItem -Path '$search_dir' -Recurse -File -ErrorAction SilentlyContinue | Where-Object { `$_.Length -gt ${min_size}MB } | Sort-Object Length -Descending | Select-Object -First 20 FullName, @{Name='Size(MB)';Expression={[math]::Round(`$_.Length/1MB,2)}}"
else
    # Linux/macOS - use find
    find "$search_dir" -type f -size +${min_size}M -exec ls -lh {} \; 2>/dev/null | \
        awk '{print $5, $9}' | sort -rh | head -n 20
fi

echo ""
echo "Search completed."
# Module: File Finder
VERSION="1.0.0"

search_dir="${1:-.}"
min_size="${2:-100}"

echo "--- Files larger than ${min_size}MB in ${search_dir} ---"

# Simple find command
if command -v find >/dev/null 2>&1; then
    find "$search_dir" -type f -size +${min_size}M 2>/dev/null | head -n 20 | while read file; do
        if [ -f "$file" ]; then
            size=$(ls -lh "$file" 2>/dev/null | awk '{print $5}')
            echo "$size  $file"
        fi
    done
else
    echo "find command not available"
fi

echo ""
echo "Search completed."
# Module: File Finder
VERSION="1.0.0"
search_dir="${1:-.}"
min_size="${2:-100}"

echo "--- Files larger than ${min_size}MB in ${search_dir} ---"
find "$search_dir" -type f -size +${min_size}M -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -rh | head -n 20
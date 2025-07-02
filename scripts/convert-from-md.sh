#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Takes in a markdown file with Mermaid code blocks and converts it to"
    echo " a [output_format] file with embedded images of the Mermaid diagram."
    echo ""
    echo "Usage: npm run convert-from-md -- <input_file> [output_format]"
    echo "Native Usage: $0 <input_file> [output_format]"
    echo "output_format: docx (default) or pdf"
    exit 1
fi

input_file=$(realpath "$1")
output_format="${2:-docx}"  # Default to docx if no second argument is provided
bin_dir="bin"
temp_file="$(basename "${input_file%.md}.temp.md")"
output_file="$(basename "${input_file%.md}.${output_format}")"

# Create bin directory if it doesn't exist
mkdir -p "$bin_dir"
pushd $bin_dir

# Convert Mermaid code blocks to images and save the modified Markdown to a temp file
npx mmdc --input "$input_file" --outputFormat png --output $temp_file

cp -r ../notes/assets .
# Modify image links to be relative to the bin directory
sed -i "s|!\[\(.*\)\](\(/assets/.*\))|!\[\1\](\.\2)|g" "$temp_file"

# Convert Markdown to DOCX "DejaVu Sans" supports glyphs use `fc-match -s "😙"` to find more
if [ "$output_format" = "pdf" ]; then
    pandoc --from=markdown --to=$output_format -V mainfont="DejaVu Sans" --pdf-engine=xelatex --o "$output_file" "$temp_file"
else
    pandoc --from=markdown --to=$output_format -V mainfont="DejaVu Sans" -o "$output_file" "$temp_file"
fi

popd

echo "../$bin_dir/$output_file created."
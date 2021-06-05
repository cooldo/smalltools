#!/bin/bash
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

show_usage() {
    echo "add debug information to all functions"
    echo "Usage: $0 <file>"
    echo "For all files: ls *.c | xargs -I {} $0 {}"
    exit 1
}

if [[ $# -ne 1 ]];then
    show_usage
fi

input_file="$1"
tag_file=${input_file%.*}.tags
rm -f "$tag_file"
touch "$tag_file"

#echo $tag_file
ctags --sort=no -f "$tag_file" "$input_file"

"$SHELL_FOLDER"/add_debug_new.py "$tag_file" "$input_file"

rm -f "$tag_file"

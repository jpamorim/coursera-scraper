#!/bin/bash

read -p "Enter course-id: " course_id

target_dir="downloads/${course_id}"

if [ ! -d "$target_dir" ]; then
    echo "Directory '$target_dir' does not exist."
    exit 1
fi

find "$target_dir" -type f -name "*.mp4" | while read -r mp4file; do
    parent_dir="$(dirname "$mp4file")"
    vttfile=$(find "$parent_dir" -maxdepth 1 -type f -name "*.vtt" | head -n 1)
    if [ -f "$vttfile" ]; then
        ffmpeg -i "$mp4file" -vf subtitles="$vttfile" "${mp4file%.mp4}_hard.mp4"
    else
        echo "Warning: VTT file not found for $mp4file"
    fi
    hidden_file="$(dirname "$mp4file")/.$(basename "$mp4file")"
    mv "$mp4file" "$hidden_file"
    if [ -f "$vttfile" ]; then
        hidden_vtt="$(dirname "$vttfile")/.$(basename "$vttfile")"
        mv "$vttfile" "$hidden_vtt"
    fi
done
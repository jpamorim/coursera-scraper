#!/bin/bash

read -p "Enter course-id: " course_id

target_dir="downloads/${course_id}"

if [ ! -d "$target_dir" ]; then
    echo "Directory '$target_dir' does not exist."
    exit 1
fi

find "$target_dir" -type f -name "*.mp4" | while read -r mp4file; do
    echo "--------------------------------------------------------------"
    echo "Processing file: $mp4file"
    echo "--------------------------------------------------------------"
    
    # Skip files that already have "_hard" in their name
    if [[ "$mp4file" == *"_hard"* ]]; then
        echo "Skipping already hardsubbed file: $mp4file"
        continue
    fi

    parent_dir="$(dirname "$mp4file")"
    vttfile=$(find "$parent_dir" -maxdepth 1 -type f -name "*.vtt" | head -n 1)
    newfile="${mp4file%.mp4}_hard.mp4"
    echo "newfile=$newfile"

    if [ -f "$newfile" ]; then
        echo "File $newfile already exists. Skipping."
        continue
    fi

    if [ -f "$vttfile" ]; then
        ffmpeg -loglevel error -i "$mp4file" -vf subtitles="$vttfile" "$newfile"
    else
        echo "Warning: VTT file not found for $mp4file"
    fi

    rm "$mp4file"
    rm "$vttfile"

done
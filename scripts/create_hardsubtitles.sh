#!/bin/bash

read -p "Enter course-id: " course_id

target_dir="downloads/${course_id}/"

if [ ! -d "$target_dir" ]; then 
    echo "Directory '$target_dir' does not exist."
    exit 1
fi

find "$target_dir" -type f -name "*.mp4" -exec dirname {} \; | sort -u | while read -r dir; do
    mp4file=$(find "$dir" -maxdepth 1 -type f -name "*.mp4" | head -n 1)
    vttfile=$(find "$dir" -maxdepth 1 -type f -name "*.vtt" | head -n 1)

    if [[ "$mp4file" == *"_hard"* ]]; then
        echo "Skipping already hardsubbed file: $mp4file"
        continue
    fi

    newfile="${mp4file%.mp4}_hard.mp4"

    
    if [ -f "$vttfile" ]; then
        ffmpeg -loglevel error -i "$mp4file" -vf subtitles="$vttfile" "$newfile"
    else
        echo "Warning: VTT file not found for $mp4file"
        continue
    fi

    if [ -f "$newfile" ]; then
        echo "Succeess: File $newfile was created successfully. Removing video and subtitles."
        rm "$mp4file"
        rm "$vttfile"
    else
        echo "Warning: Hardsubtitles were not created for $mp4file"
    fi

done
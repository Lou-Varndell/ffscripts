#!/usr/bin/env bash

set -e

find . -type f \( \
-iname "*.mkv" -o \
-iname "*.webm" -o \
-iname "*.mp4" -o \
-iname "*.mov" \) | while read -r file
do
    echo
    echo "Checking: $file"

    container=$(ffprobe -v error -show_entries format=format_name -of csv=p=0 "$file")
    vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$file")
    pixfmt=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 "$file")

    acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$file" | head -n1)

    echo "Container: $container"
    echo "Video: $vcodec ($pixfmt)"
    echo "Audio: $acodec"

    compatible_container=false
    compatible_video=false
    compatible_audio=false

    [[ "$container" == *mp4* || "$container" == *mov* ]] && compatible_container=true
    [[ "$vcodec" == "h264" || "$vcodec" == "hevc" ]] && compatible_video=true
    [[ "$acodec" == "aac" || "$acodec" == "ac3" || "$acodec" == "eac3" ]] && compatible_audio=true

    if $compatible_container && $compatible_video && $compatible_audio && [[ "$pixfmt" == "yuv420p" ]]; then
        echo "✔ Already compatible — skipping"
        continue
    fi

    outfile="${file%.*}.mp4"

    if [[ -f "$outfile" ]]; then
        echo "Output exists — skipping"
        continue
    fi

    echo "⚙ Converting -> $outfile"

    ffmpeg -hide_banner -loglevel warning \
        -i "$file" \
        -map 0 \
        -c:v libx264 -preset slow -crf 19 -pix_fmt yuv420p \
        -c:a aac -b:a 192k \
        -c:s mov_text \
        -movflags +faststart \
        "$outfile"

done
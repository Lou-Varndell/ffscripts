#!/usr/bin/env bash

shopt -s nullglob

# find . -type f \( -iname "*.mkv" -o -iname "*.webm" -o -iname "*.mp4" -o -iname "*.mov" \) | while read -r f; do
for f in *.mkv *.webm *.mp4 *.mov; do
    echo "Checking: $f"

    container=$(ffprobe -v error -show_entries format=format_name -of default=nw=1:nk=1 "$f")
    vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f")
    acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f")

    if [[ "$container" == *mp4* && "$vcodec" == "h264" && "$acodec" == "aac" ]]; then
        echo "✔ Already compatible — skipping"
        echo
        continue
    fi

    outfile="${f%.*}.mp4"

    echo "⚙ Converting -> $outfile"

    ffmpeg -i "$f" \
        -map 0:v:0 -map 0:a:0 \
        -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p \
        -c:a aac -b:a 160k \
        -movflags +faststart \
        "$outfile"

    echo
done
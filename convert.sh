#!/usr/bin/env bash


input="$1"
output="${input%.*}.mp4"

container=$(ffprobe -v error -show_entries format=format_name -of default=nw=1:nk=1 "${input}")
acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "${input}")
vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "${input}")

echo "Container: $container"
echo "Audio Codec: $acodec"
echo "Video Codec: $vcodec"

ffmpeg -i "${input}" -map 0:v:0 -map 0:a:0 -c:v h264_videotoolbox -b:v 6M -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart "${output}"
# ffmpeg -i "${input}" -map 0:v:0 -map 0:a:0 -c:v libx264 -preset slow -crf 20 -maxrate 10M -bufsize 20M -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart "${output}"

container=$(ffprobe -v error -show_entries format=format_name -of default=nw=1:nk=1 "${output}")
acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "${output}")
vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "${output}")

echo "Container: $container"
echo "Audio Codec: $acodec"
echo "Video Codec: $vcodec"


# find . -type f \( -iname "*.webm" -o -iname "*.mkv" -o -iname "*.mp4" \) -print0 | while IFS= read -r -d '' f; do
#   echo
#   echo "Inspecting: $f"
#   container=$(ffprobe -v error -show_entries format=format_name -of default=nw=1:nk=1 "$f")
#   vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f")
#   acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f")

#   if [[ "$container" == *mp4* && "$vcodec" == "h264" && "$acodec" == "aac" ]]; then
#     echo "✔ Already compatible — skipping: $f"
#     continue
#   fi

#   out="${f%.*}.mp4"
#   echo "⚙ Converting -> $out"
# done

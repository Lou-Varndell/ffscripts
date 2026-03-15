#!/usr/bin/env bash

THREADS=$(sysctl -n hw.ncpu)
JOBS=$((THREADS / 2))   # number of parallel encodes

encode_file() {

  input="$1"
  base="${input%.*}"
  output="${base}.mp4"

  echo "Processing: $input"

  vcodec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$input")
  acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$input")

  # Decide video handling
  if [[ "$vcodec" == "h264" ]]; then
    vopts="-c:v copy"
  else
    vopts="-c:v libx264 -preset slow -crf 21 -pix_fmt yuv420p"
  fi

  # Decide audio handling
  if [[ "$acodec" == "aac" ]]; then
    aopts="-c:a copy"
  else
    aopts="-c:a aac -b:a 160k"
  fi

  ffmpeg -y -i "$input" -map 0:v:0 -map 0:a:0 $vopts $aopts -movflags +faststart "$output"

}

export -f encode_file

find . -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.webm" \) \
| xargs -I{} -P $JOBS bash -c 'encode_file "$@"' _ {}
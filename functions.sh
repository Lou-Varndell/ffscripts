#!/usr/bin/env bash

# Download + normalize to Jellyfin-safe MP4. Handles Shorts -> 16:9 padding.
ytdlp() {
  yt-dlp --verbose --js-runtimes node \
    -f 'bv*+ba/b' \
    --merge-output-format mp4 \
    --postprocessor-args "ffmpeg:-loglevel warning -map 0 \
      -c:v libx264 -profile:v main -level 3.1 -pix_fmt yuv420p \
      -r 20 -crf 21 \
      -vf scale='if(gt(iw/ih,1280/720),1280,-2)':'if(gt(iw/ih,1280/720),-2,720)',pad=1280:720:(ow-iw)/2:(oh-ih)/2 \
      -c:a aac -b:a 128k \
      -movflags +faststart" \
    --restrict-filenames \
    -o '%(upload_date)s_%(title)s#%(id)s.%(ext)s' "$@"
}

# Download a YouTube Short and convert to a universally compatible MP4
ytshort() {

  if [ -z "$1" ]; then
    echo "Usage: ytshort <youtube-url>"
    return 1
  fi

  yt-dlp \
    --js-runtimes node \
    --verbose \
    -f "bv*+ba/b" \
    --merge-output-format mp4 \
    --postprocessor-args "ffmpeg:-loglevel warning -map 0 \
      -c:v libx264 -profile:v main -level 3.1 -pix_fmt yuv420p \
      -r 30 -crf 22 \
      -vf scale='if(gt(iw/ih,1280/720),1280,-2)':'if(gt(iw/ih,1280/720),-2,720)',pad=1280:720:(ow-iw)/2:(oh-ih)/2 \
      -c:a aac -b:a 128k \
      -movflags +faststart" \
    --restrict-filenames \
    -o "%(upload_date)s_%(title)s#%(id)s.%(ext)s" \
    "$@"
}

# Here is a more advanced bash function that does what you described:
# Detects YouTube Shorts vs normal videos
# Produces MP4 (H.264 + AAC) compatible with
# QuickTime Player, Plex Media Server, and Jellyfin
# Pads Shorts to 1280×720
# Avoids re-encoding if the video is already compatible
# It uses yt-dlp and FFmpeg.

ytvid () {

  if [ -z "$1" ]; then
    echo "Usage: ytvid <youtube-url>"
    return 1
  fi

  URL="$1"

  # detect if this is a YouTube Short
  if [[ "$URL" == *"/shorts/"* ]]; then
    SHORTS=1
  else
    SHORTS=0
  fi

  if [ "$SHORTS" -eq 1 ]; then
    echo "Detected: YouTube Short"

    yt-dlp \
      --js-runtimes node \
      --verbose \
      -f "bv*+ba/b" \
      --merge-output-format mp4 \
      --postprocessor-args "ffmpeg:-loglevel warning -map 0 \
        -c:v libx264 -profile:v main -level 3.1 -pix_fmt yuv420p \
        -crf 22 \
        -vf scale='if(gt(iw/ih,1280/720),1280,-2)':'if(gt(iw/ih,1280/720),-2,720)',pad=1280:720:(ow-iw)/2:(oh-ih)/2 \
        -c:a aac -b:a 128k \
        -movflags +faststart" \
      --restrict-filenames \
      -o "%(upload_date)s_%(title)s#%(id)s.%(ext)s" \
      "$URL"

  else
    echo "Detected: Normal YouTube video"

    yt-dlp \
      --js-runtimes node \
      --verbose \
      -f "bv*[height<=720]+ba/b[height<=720]" \
      --merge-output-format mp4 \
      --remux-video mp4 \
      --restrict-filenames \
      -o "%(upload_date)s_%(title)s#%(id)s.%(ext)s" \
      "$URL"

  fi
}

#!/usr/bin/env bash


jq '{
  format: {
    filename: .format.filename,
    duration: .format.duration,
    bitrate: .format.bit_rate,
    tags: .format.tags
  },
  video: (
    .streams[] | select(.codec_type=="video") | {
      codec: .codec_name,
      profile: .profile,
      pix_fmt: .pix_fmt,
      resolution: "\(.width)x\(.height)",
      display_aspect_ratio: .display_aspect_ratio,
      frame_rate: .r_frame_rate,
      bit_rate: (.bit_rate // .tags.BPS),
      color_space: .color_space,
      color_transfer: .color_transfer,
      color_primaries: .color_primaries
    }
  ),
  audio: (
    .streams[] | select(.codec_type=="audio") | {
      codec: .codec_name,
      channels: .channels,
      sample_rate: .sample_rate,
      bit_rate: .bit_rate,
      language: .tags.language
    }
  ),
  # subtitles: (
  #   .streams[] | select(.codec_type=="subtitle") | {
  #     codec: .codec_name,
  #     language: .tags.language
  #   }
  # )
}'

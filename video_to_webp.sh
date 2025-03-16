#!/bin/bash

# Check if correct number of arguments is provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <video_file> <start_time_in_seconds> <duration_in_seconds>"
    echo "Example: $0 input.mp4 10 6"
    exit 1
fi

# Input video file
INPUT="/var/www/videos/$1"
START_TIME="$2"
DURATION="$3"

# Check if the input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: File '$INPUT' not found!"
    exit 1
fi

# Validate start time is a number
if ! [[ "$START_TIME" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Start time '$START_TIME' must be a number (e.g., 5 or 5.5)!"
    exit 1
fi

# Validate duration is a number
if ! [[ "$DURATION" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Duration '$DURATION' must be a number (e.g., 4 or 4.5)!"
    exit 1
fi

# Output file (input filename with .webp extension)
OUTPUT="/var/www/videos/thumbnails/${1%.*}.webp"

# Parameters
WIDTH=480         # Resize to 480px width (adjust as needed)
QUALITY=75        # Quality (0-100, higher = better)

# Generate the WebP preview
ffmpeg -i "$INPUT" \
    -ss "$START_TIME" \
    -t "$DURATION" \
    -vf "scale=$WIDTH:-1:flags=lanczos" \
    -c:v libwebp \
    -lossless 0 \
    -q:v "$QUALITY" \
    -loop 0 \
    "$OUTPUT" -y

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Success! Generated ${DURATION}s WebP preview: $OUTPUT"
    echo "File size: $(du -h "$OUTPUT" | cut -f1)"
else
    echo "Error: Conversion failed!"
    exit 1
fi

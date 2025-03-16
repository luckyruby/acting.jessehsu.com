#!/bin/bash

# Directory containing video files (default: current directory)
INPUT_DIR="${1:-.}"

# Output directory for GIFs (default: ./thumbnails)
OUTPUT_DIR="${2:-./thumbnails}"

# Duration of GIF in seconds
DURATION=3

# Start time for preview (seconds into video)
START_TIME=8

# GIF width (height scales automatically)
WIDTH=320

# Frames per second for GIF
FPS=10

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it with 'sudo apt install ffmpeg'."
    exit 1
fi

# Process all MP4 and MOV files in the input directory
for video in "$INPUT_DIR"/*.{mp4,mov}; do
    # Skip if no matching files found
    [[ -e "$video" ]] || continue

    # Get the base filename without path and extension
    filename=$(basename "$video")
    name="${filename%.*}"

    # Output GIF path
    gif_output="$OUTPUT_DIR/${name}.gif"

    echo "Processing: $filename -> $gif_output"

    # Create GIF using ffmpeg
    ffmpeg -i "$video" \
           -ss "$START_TIME" \
           -t "$DURATION" \
           -vf "fps=$FPS,scale=$WIDTH:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
           -loop 0 \
           -y \
           "$gif_output" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Created: $gif_output"
    else
        echo "Error creating GIF for $filename"
    fi
done

echo "Done processing all videos!"

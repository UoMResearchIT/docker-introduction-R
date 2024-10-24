#!/bin/bash

# Default delay between frames (in centiseconds, 1s = 100cs)
DEFAULT_DELAY=100

# Function to display usage
usage() {
    echo "Usage: $0 [-d delay] [-i input_folder] [-o output_file]"
    echo "  -d delay         Delay between frames in centiseconds (default: $DEFAULT_DELAY)"
    echo "  -i input_folder  Folder containing images to create GIF from"
    echo "  -o output_file   Output GIF file"
    exit 1
}

# Parse command-line arguments
while getopts "d:i:o:" opt; do
    case $opt in
        d) DELAY=$OPTARG ;;
        i) INPUT_FOLDER=$OPTARG ;;
        o) OUTPUT_FILE=$OPTARG ;;
        *) usage ;;
    esac
done

# Set default values if not provided
DELAY=${DELAY:-$DEFAULT_DELAY}

# Function to create GIF from images in a folder
create_gif() {
    local folder=$1
    local output=$2
    local delay=$3

    echo "Creating GIF from images in folder '$folder' with delay $delay centiseconds..."
    convert -delay $delay -loop 0 "$folder"/*.png "$output"
    echo "GIF saved to '$output'"
}

# If input folder and output file are provided, create a single GIF
if [[ -n "$INPUT_FOLDER" && -n "$OUTPUT_FILE" ]]; then
    create_gif "$INPUT_FOLDER" "$OUTPUT_FILE" "$DELAY"
else
    # Create GIFs for each folder in the current directory
    for folder in */; do
        folder_name=$(basename "$folder")
        output_file="${folder_name%/}.gif"
        create_gif "$folder" "$output_file" "$DELAY"
    done
fi
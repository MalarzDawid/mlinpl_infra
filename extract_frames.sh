FFMPEG_PATH="ffmpeg"

for video_file in preprocess/*.mp4; do
    echo $video_file
    if [ -f "$video_file" ]; then
        # Get the base name of the file without path and extension
        video_name=$(basename "$video_file" | cut -f 1 -d '.')

        # Define the new .mp4 file path
        output_dir="data/${video_name}/input"
        mkdir -p "$output_dir"

        # Convert .mov or .MOV to .mp4
        $FFMPEG_PATH -i "$video_file" -qscale:v 1 -qmin 1 -vf fps=2 "$output_dir/%04d.jpg"
        
        echo "Frames for $video_name saved in $output_dir"
    fi
done
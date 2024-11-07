FFMPEG_PATH=ffmpeg
for video_file in videos/*.{mov,MOV}; do
    echo $video_file
    if [ -f "$video_file" ]; then
        # Get the base name of the file without path and extension
        video_name=$(basename "$video_file" | cut -f 1 -d '.')

        # Define the new .mp4 file path
        mp4_file="videos/${video_name}.mp4"

        # Convert .mov or .MOV to .mp4
        $FFMPEG_PATH -i "$video_file" -qscale:v 1 "$mp4_file"
        
        echo "Converted $video_file to $mp4_file"
    fi
done

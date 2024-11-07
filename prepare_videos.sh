rm -r preprocess
mkdir preprocess

for video_file in videos/*.mp4; do
    echo $video_file
    if [ -f "$video_file" ]; then
        # Get the base name of the file without path and extension
        video_name=$(basename "$video_file" | cut -f 1 -d '.')

        # Define the new .mp4 file path
        mp4_file="videos/${video_name}.mp4"

        # Convert .mov or .MOV to .mp4
        cp "$video_file" "preprocess/${video_name}.mp4"
        
        echo "Converted $video_file to $mp4_file"
    fi
done
for dir in data/*; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        bash colmap_run.sh --source_path "$dir"
    fi
done

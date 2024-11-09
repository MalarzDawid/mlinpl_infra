#!/bin/bash

# Wczytaj zmienne z pliku .env
export $(grep -v '^#' .env | xargs)

# Upewnij się, że folder MP4_DIR istnieje
mkdir -p "$MP4_DIR"
mkdir -p "$ZIP_DIR"

# Ścieżka do pliku wejściowego
#file="videos/Marta_Neumann.mov"
if [[ -z "$1" ]]; then
    exit 1
fi

# Ścieżka do pliku wejściowego
file="$1"

filename=$(basename "${file%.*}")

if [[ -f "$file" ]]; then
    # Pobierz rozszerzenie pliku
    extension="${file##*.}"
    # Pobierz tylko nazwę pliku (bez ścieżki i rozszerzenia)
    
    if [[ "$file" == *"."* ]]; then
        if [[ "$extension" == "mov" || "$extension" == "MOV" ]]; then
            # Konwertuj plik MOV na MP4 i zapisz do folderu wyjściowego
            $FFMPEG_PATH -i "$file" -qscale:v 1 "$MP4_DIR/$filename.mp4"
            echo "Skonwertowano $file do MP4 i skopiowano do $MP4_DIR"
        
        elif [[ "$extension" == "mp4" ]]; then
            # Skopiuj plik MP4 do folderu wyjściowego
            cp "$file" "$MP4_DIR/"
            echo "Skopiowano $file do $MP4_DIR"
        
        else
            # Wypisz typ pliku, jeśli nie jest MOV ani MP4
            echo "Nieobsługiwany typ pliku: $file ($extension)"
        fi
    else
        # Wypisz komunikat, jeśli plik nie ma rozszerzenia
        echo "Plik $file nie ma rozszerzenia"
    fi
else
    echo "$file nie jest plikiem lub nie istnieje."
fi

mp4filename="$MP4_DIR/$filename.mp4"

if [ -f "$mp4filename" ]; then
    # Get the base name of the file without path and extension
    video_name=$(basename "$mp4filename" | cut -f 1 -d '.')

    # Define the new .mp4 file path
    output_dir="$FINAL_DIR/${video_name}/input"
    mkdir -p "$output_dir"

    # Convert .mov or .MOV to .mp4
    $FFMPEG_PATH -i "$mp4filename" -qscale:v 1 -qmin 1 -vf fps=2 "$output_dir/%04d.jpg"
    
    echo "Frames for $video_name saved in $output_dir"
fi

# COLMAP HERE
colmap_input="$FINAL_DIR/${video_name}"
bash colmap_run.sh -s $colmap_input

# ZIP HERE
if [ -d "$FINAL_DIR/${filename}" ]; then
    zip_input="$FINAL_DIR/${video_name}"
    zip_output="$ZIP_DIR/$filename.zip"
    zip -r "$zip_output" "$zip_input"
    
    echo "Compressed $zip_input -> $zip_output"
fi

# UPLOAD HERE
python upload.py --filename $zip_output
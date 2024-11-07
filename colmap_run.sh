#!/bin/bash

# Default settings
NO_GPU=0
SKIP_MATCHING=0
CAMERA="OPENCV"
COLMAP_EXECUTABLE="colmap"
MAGICK_EXECUTABLE="magick"
RESIZE=1

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no_gpu) NO_GPU=1 ;;
        --skip_matching) SKIP_MATCHING=1 ;;
        --source_path|-s) SOURCE_PATH="$2"; shift ;;
        --camera) CAMERA="$2"; shift ;;
        --colmap_executable) COLMAP_EXECUTABLE="$2"; shift ;;
        --magick_executable) MAGICK_EXECUTABLE="$2"; shift ;;
        --resize) RESIZE=1 ;;
    esac
    shift
done

# Set paths and GPU usage
USE_GPU=$((1 - NO_GPU))
COLMAP_COMMAND="${COLMAP_EXECUTABLE:-colmap}"
MAGICK_COMMAND="${MAGICK_EXECUTABLE:-magick}"

if [ "$SKIP_MATCHING" -eq 0 ]; then
    mkdir -p "$SOURCE_PATH/distorted/sparse"

    # Feature extraction
    feat_extracton_cmd="$COLMAP_COMMAND feature_extractor \
        --database_path $SOURCE_PATH/distorted/database.db \
        --image_path $SOURCE_PATH/input \
        --ImageReader.single_camera 1 \
        --ImageReader.camera_model $CAMERA \
        --SiftExtraction.use_gpu $USE_GPU"
    eval $feat_extracton_cmd
    if [ $? -ne 0 ]; then
        echo "Feature extraction failed. Exiting."
        exit 1
    fi

    # Feature matching
    feat_matching_cmd="$COLMAP_COMMAND exhaustive_matcher \
        --database_path $SOURCE_PATH/distorted/database.db \
        --SiftMatching.use_gpu $USE_GPU"
    eval $feat_matching_cmd
    if [ $? -ne 0 ]; then
        echo "Feature matching failed. Exiting."
        exit 1
    fi

    # Bundle adjustment
    mapper_cmd="$COLMAP_COMMAND mapper \
        --database_path $SOURCE_PATH/distorted/database.db \
        --image_path $SOURCE_PATH/input \
        --output_path $SOURCE_PATH/distorted/sparse \
        --Mapper.ba_global_function_tolerance=0.000001"
    eval $mapper_cmd
    if [ $? -ne 0 ]; then
        echo "Mapper failed. Exiting."
        exit 1
    fi
fi

# Image undistortion
img_undist_cmd="$COLMAP_COMMAND image_undistorter \
    --image_path $SOURCE_PATH/input \
    --input_path $SOURCE_PATH/distorted/sparse/0 \
    --output_path $SOURCE_PATH \
    --output_type COLMAP"
eval $img_undist_cmd
if [ $? -ne 0 ]; then
    echo "Image undistortion failed. Exiting."
    exit 1
fi

# Organize sparse files
mkdir -p "$SOURCE_PATH/sparse/0"
for file in "$SOURCE_PATH/sparse"/*; do
    if [ "$(basename $file)" != "0" ]; then
        mv "$file" "$SOURCE_PATH/sparse/0/"
    fi
done

# Resize images if needed
if [ "$RESIZE" -eq 1 ]; then
    echo "Copying and resizing..."
    mkdir -p "$SOURCE_PATH/images_2" "$SOURCE_PATH/images_4" "$SOURCE_PATH/images_8"
    for file in "$SOURCE_PATH/images"/*; do
        cp "$file" "$SOURCE_PATH/images_2/"
        eval "$MAGICK_COMMAND mogrify -resize 50% $SOURCE_PATH/images_2/$(basename "$file")"
        if [ $? -ne 0 ]; then
            echo "50% resize failed. Exiting."
            exit 1
        fi

        cp "$file" "$SOURCE_PATH/images_4/"
        eval "$MAGICK_COMMAND mogrify -resize 25% $SOURCE_PATH/images_4/$(basename "$file")"
        if [ $? -ne 0 ]; then
            echo "25% resize failed. Exiting."
            exit 1
        fi

        cp "$file" "$SOURCE_PATH/images_8/"
        eval "$MAGICK_COMMAND mogrify -resize 12.5% $SOURCE_PATH/images_8/$(basename "$file")"
        if [ $? -ne 0 ]; then
            echo "12.5% resize failed. Exiting."
            exit 1
        fi
    done
fi

echo "Done."
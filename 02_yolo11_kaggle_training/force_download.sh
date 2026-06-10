#!/bin/bash
# Force Download Output dari Kaggle (tidak perlu tunggu COMPLETE status)
# Usage: sh force_download.sh

KERNEL_ID="teukuradja/yolo11-tea-disease-training"
KAGGLE_BIN="../venv/bin/kaggle"
OUTPUT_DIR="../04_outputs/yolo11_downloaded_output"
SAVED_DIR="../04_outputs/yolo11_latest"

# Use kaggle from venv or system
if [ ! -f "$KAGGLE_BIN" ]; then
    KAGGLE_BIN="kaggle"
fi

echo ""
echo "=========================================="
echo "Force Download Output dari Kaggle"
echo "=========================================="
echo ""

# Create directories
mkdir -p "$OUTPUT_DIR" "$SAVED_DIR"

echo "Downloading from Kaggle..."
echo "Kernel: $KERNEL_ID"
echo ""

# Download
"$KAGGLE_BIN" kernels output "$KERNEL_ID" -p "$OUTPUT_DIR" --quiet

echo ""
echo "Download complete! Organizing files..."
echo ""

# Copy important files
echo "Copying .pt files (models)..."
find "$OUTPUT_DIR" -name "*.pt" -type f 2>/dev/null | while read f; do
    cp "$f" "$SAVED_DIR/$(basename "$f")" && echo "  ✓ $(basename "$f")"
done

echo ""
echo "Copying .csv files (metrics)..."
find "$OUTPUT_DIR" -name "*.csv" -type f 2>/dev/null | while read f; do
    cp "$f" "$SAVED_DIR/$(basename "$f")" && echo "  ✓ $(basename "$f")"
done

echo ""
echo "Copying .txt files (reports)..."
find "$OUTPUT_DIR" -name "*.txt" -type f 2>/dev/null | while read f; do
    cp "$f" "$SAVED_DIR/$(basename "$f")" && echo "  ✓ $(basename "$f")"
done

echo ""
echo "Copying .png files (charts)..."
find "$OUTPUT_DIR" -name "*.png" -type f 2>/dev/null | while read f; do
    cp "$f" "$SAVED_DIR/$(basename "$f")" && echo "  ✓ $(basename "$f")"
done

echo ""
echo "=========================================="
echo "Done! All files copied to:"
echo "  $SAVED_DIR/"
echo "=========================================="
echo ""
echo "Files downloaded:"
ls -lh "$SAVED_DIR/"
echo ""

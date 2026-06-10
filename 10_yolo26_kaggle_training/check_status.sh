#!/bin/bash
# Check Kaggle Kernel Status dan Download Output untuk YOLO26
# Usage:
#   sh check_status.sh status      # Cek status saja
#   sh check_status.sh download    # Download hasil
#   sh check_status.sh all         # Cek status + download

set +e  # Don't exit on error

KERNEL_ID="teukuradja/yolo26-tea-disease-training"
KAGGLE_BIN="../venv/bin/kaggle"
OUTPUT_DIR="../04_outputs/yolo26_downloaded_output"
SAVED_DIR="../04_outputs/yolo26_latest"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Validate kaggle binary
if [ ! -f "$KAGGLE_BIN" ]; then
    KAGGLE_BIN="kaggle"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  YOLO26 Training Status & Download Checker"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check Status
cmd_status() {
    echo "📊 Cek Status Training YOLO26..."
    echo ""

    status_output=$("$KAGGLE_BIN" kernels status "$KERNEL_ID" 2>&1)
    echo "$status_output"

    echo ""

    # Analyze status
    if echo "$status_output" | grep -q "COMPLETE"; then
        echo "✅ Training SELESAI!"
        echo "   Kernel ID: $KERNEL_ID"
        echo ""
        return 0
    elif echo "$status_output" | grep -q "RUNNING"; then
        echo "⏳ Training masih RUNNING..."
        echo ""
        return 1
    elif echo "$status_output" | grep -q "ERROR"; then
        echo "❌ Ada ERROR dalam training"
        echo ""
        return 2
    else
        echo "❓ Status tidak jelas (lihat output di atas)"
        echo ""
        return 1
    fi
}

# Download Results
cmd_download() {
    echo "📥 Download Output YOLO26 dari Kaggle..."
    echo ""

    mkdir -p "$OUTPUT_DIR" "$SAVED_DIR"

    # Download all outputs
    echo "Downloading to: $OUTPUT_DIR"
    if "$KAGGLE_BIN" kernels output "$KERNEL_ID" -p "$OUTPUT_DIR" --quiet 2>&1; then
        echo "✅ Download completed!"
    else
        echo "⚠️  Download might be incomplete, continuing..."
    fi

    echo ""
    echo "💾 Copying important files to $SAVED_DIR/..."

    # Copy important files
    count=0
    find "$OUTPUT_DIR" -type f \( -name "*.pt" -o -name "*.csv" -o -name "*.txt" -o -name "*.png" \) -maxdepth 4 2>/dev/null | while read f; do
        cp "$f" "$SAVED_DIR/$(basename "$f")" 2>/dev/null && echo "✅ $(basename "$f")" || echo "⚠️  Skipped: $(basename "$f")"
    done

    echo ""
    echo "🎯 Important files location:"
    echo "   $SAVED_DIR/"
    echo ""
    echo "📋 Files:"
    ls -lh "$SAVED_DIR" 2>/dev/null || echo "No files yet"
    echo ""
}

# Main
case "${1:-status}" in
    status)
        cmd_status
        ;;
    download)
        cmd_download
        ;;
    all)
        cmd_status
        status_code=$?
        if [ $status_code -eq 0 ]; then
            echo ""
            echo "Auto-downloading results..."
            cmd_download
        else
            echo "⚠️  Training belum COMPLETE, skip download"
        fi
        ;;
    *)
        echo "Usage:"
        echo "  sh check_status.sh status   # Cek status training YOLO26"
        echo "  sh check_status.sh download # Download hasil"
        echo "  sh check_status.sh all      # Cek status + auto download"
        echo ""
        ;;
esac

echo "═══════════════════════════════════════════════════════════════"
echo ""

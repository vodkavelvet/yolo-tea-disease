#!/bin/bash
# Helper script untuk push dan pantau notebook YOLO26 Training di Kaggle
# Usage:
#   sh run.sh push
#   sh run.sh status
#   sh run.sh watch
#   sh run.sh download
#   sh run.sh logs
#   sh run.sh all

set -e

KERNEL_ID="teukuradja/yolo26-tea-disease-training"
KAGGLE_BIN="../venv/bin/kaggle"
OUTPUT_DIR="../04_outputs/yolo26_downloaded_output"
SAVED_DIR="../04_outputs/yolo26_latest"
POLL_INTERVAL=60

if [ ! -f "$KAGGLE_BIN" ]; then
    KAGGLE_BIN="kaggle"
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

cmd_push() {
    echo -e "${BLUE}📤 Pushing notebook YOLO26 ke Kaggle...${NC}"
    "$KAGGLE_BIN" kernels push -p .
    echo -e "${GREEN}✅ Push berhasil!${NC}"
    echo -e "${YELLOW}🔗 Pantau di: https://www.kaggle.com/code/$KERNEL_ID${NC}"
}

cmd_status() {
    "$KAGGLE_BIN" kernels status "$KERNEL_ID"
}

cmd_watch() {
    echo -e "${BLUE}👀 Memantau YOLO26 training...${NC}"
    echo -e "${YELLOW}Cek setiap $POLL_INTERVAL detik. Ctrl+C untuk berhenti.${NC}"
    echo -e "${YELLOW}🔗 Live: https://www.kaggle.com/code/$KERNEL_ID${NC}"

    while true; do
        status_output=$("$KAGGLE_BIN" kernels status "$KERNEL_ID" 2>&1 | tr -d '\n')
        timestamp=$(date '+%H:%M:%S')
        echo -e "[$timestamp] $status_output"

        if echo "$status_output" | grep -q "COMPLETE"; then
            echo -e "${GREEN}🎉 YOLO26 TRAINING SELESAI!${NC}"
            cmd_download
            return 0
        elif echo "$status_output" | grep -q "ERROR"; then
            echo -e "${RED}❌ Training ERROR. Jalankan: sh run.sh logs${NC}"
            return 1
        elif echo "$status_output" | grep -q "CANCEL"; then
            echo -e "${YELLOW}⚠️ Training dibatalkan${NC}"
            return 1
        fi

        sleep $POLL_INTERVAL
    done
}

cmd_download() {
    mkdir -p "$OUTPUT_DIR" "$SAVED_DIR"
    echo -e "${BLUE}📥 Download output Kaggle ke $OUTPUT_DIR/...${NC}"
    "$KAGGLE_BIN" kernels output "$KERNEL_ID" -p "$OUTPUT_DIR" --quiet 2>&1 | tail -5

    echo -e "${BLUE}💾 Menyalin file penting ke $SAVED_DIR/...${NC}"
    find "$OUTPUT_DIR" -type f \( -name "*.pt" -o -name "*.csv" -o -name "*.txt" -o -name "*.png" \) -maxdepth 6 2>/dev/null | while read f; do
        cp "$f" "$SAVED_DIR/$(basename "$f")"
        echo -e "${GREEN}✅ $(basename "$f")${NC}"
    done

    echo -e "${GREEN}🎯 File penting ada di: $SAVED_DIR/${NC}"
    ls -lh "$SAVED_DIR" 2>/dev/null || true
}

cmd_logs() {
    rm -rf ./_kaggle_log_tmp
    mkdir -p ./_kaggle_log_tmp
    echo -e "${BLUE}📜 Mengambil output/log dari Kaggle...${NC}"
    "$KAGGLE_BIN" kernels output "$KERNEL_ID" -p ./_kaggle_log_tmp --quiet > /dev/null 2>&1 || true
    find ./_kaggle_log_tmp -type f | head -20
    rm -rf ./_kaggle_log_tmp
}

cmd_all() {
    cmd_push
    echo -e "${YELLOW}⏳ Menunggu 30 detik agar Kaggle mulai memproses...${NC}"
    sleep 30
    cmd_watch
}

case "${1:-help}" in
    push) cmd_push ;;
    status) cmd_status ;;
    watch) cmd_watch ;;
    download) cmd_download ;;
    logs) cmd_logs ;;
    all) cmd_all ;;
    *)
        echo "YOLO26 Kaggle Helper"
        echo "Usage: sh run.sh push | status | watch | download | logs | all"
        ;;
esac

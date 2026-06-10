#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# Helper script untuk YOLOv8 Training di Kaggle
# Usage:
#   ./run.sh push      → upload notebook ke Kaggle & jalankan
#   ./run.sh status    → cek status sekali
#   ./run.sh watch     → pantau otomatis, auto-download saat selesai
#   ./run.sh download  → download hasil training (best.pt, video, dll)
#   ./run.sh logs      → lihat log error terakhir
#   ./run.sh all       → push + watch + download (one-shot)
# ─────────────────────────────────────────────────────────────────────

set -e

# Konfigurasi
KERNEL_ID="teukuradja/yolov8-training"
KAGGLE_BIN="../venv/bin/kaggle"
OUTPUT_DIR="../04_outputs/yolo8_downloaded_output"
SAVED_DIR="../04_outputs/yolo8_latest"
POLL_INTERVAL=60   # cek status setiap 60 detik

# Warna untuk output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cek apakah kaggle CLI ada
if [ ! -f "$KAGGLE_BIN" ]; then
    echo -e "${RED}❌ Kaggle CLI tidak ditemukan di $KAGGLE_BIN${NC}"
    echo "   Install dulu dari root project: ./venv/bin/pip install kaggle"
    exit 1
fi

# ─── FUNCTIONS ────────────────────────────────────────────────────────

cmd_push() {
    echo -e "${BLUE}📤 Pushing notebook ke Kaggle...${NC}"
    "$KAGGLE_BIN" kernels push -p .
    echo -e "${GREEN}✅ Push berhasil!${NC}"
    echo -e "${YELLOW}🔗 Pantau di: https://www.kaggle.com/code/$KERNEL_ID${NC}"
}

cmd_status() {
    "$KAGGLE_BIN" kernels status "$KERNEL_ID"
}

cmd_watch() {
    echo -e "${BLUE}👀 Memantau training...${NC}"
    echo -e "${YELLOW}   (cek setiap $POLL_INTERVAL detik, tekan Ctrl+C untuk berhenti)${NC}"
    echo -e "${YELLOW}🔗 Lihat live: https://www.kaggle.com/code/$KERNEL_ID${NC}"
    echo ""

    local start_time=$(date +%s)
    local check_count=0

    while true; do
        check_count=$((check_count + 1))
        local now=$(date +%s)
        local elapsed=$((now - start_time))
        local elapsed_min=$((elapsed / 60))

        local status_output=$("$KAGGLE_BIN" kernels status "$KERNEL_ID" 2>&1 | tr -d '\n')
        local timestamp=$(date '+%H:%M:%S')

        echo -e "[$timestamp] Check #$check_count (${elapsed_min}m): $status_output"

        if echo "$status_output" | grep -q "COMPLETE"; then
            echo ""
            echo -e "${GREEN}🎉 TRAINING SELESAI!${NC}"
            echo -e "${BLUE}📥 Auto-download hasil...${NC}"
            cmd_download
            cmd_save_important
            return 0
        elif echo "$status_output" | grep -q "ERROR"; then
            echo ""
            echo -e "${RED}❌ Training ERROR!${NC}"
            echo -e "${YELLOW}   Jalankan: ./run.sh logs untuk lihat penyebab${NC}"
            return 1
        elif echo "$status_output" | grep -q "CANCEL"; then
            echo ""
            echo -e "${YELLOW}⚠️  Training dibatalkan${NC}"
            return 1
        fi

        sleep $POLL_INTERVAL
    done
}

cmd_download() {
    mkdir -p "$OUTPUT_DIR"
    echo -e "${BLUE}📥 Downloading semua output ke $OUTPUT_DIR/...${NC}"
    "$KAGGLE_BIN" kernels output "$KERNEL_ID" -p "$OUTPUT_DIR" --quiet 2>&1 | tail -5
    echo -e "${GREEN}✅ Download selesai!${NC}"
}

cmd_save_important() {
    # Cari file penting (model + video) dan salin ke folder ringkas
    mkdir -p "$SAVED_DIR"
    echo -e "${BLUE}💾 Menyimpan file penting ke $SAVED_DIR/...${NC}"

    # best.pt (model hasil training)
    local best_pt=$(find "$OUTPUT_DIR" -name "best.pt" 2>/dev/null | head -1)
    if [ -n "$best_pt" ]; then
        cp "$best_pt" "$SAVED_DIR/best.pt"
        local size=$(du -h "$best_pt" | cut -f1)
        echo -e "   ${GREEN}✅ best.pt        ($size)${NC}"
    fi

    # last.pt
    local last_pt=$(find "$OUTPUT_DIR" -name "last.pt" 2>/dev/null | head -1)
    if [ -n "$last_pt" ]; then
        cp "$last_pt" "$SAVED_DIR/last.pt"
        echo -e "   ${GREEN}✅ last.pt${NC}"
    fi

    # Video hasil deteksi
    local result_video=$(find "$OUTPUT_DIR" -name "detection_result.mp4" 2>/dev/null | head -1)
    if [ -n "$result_video" ]; then
        cp "$result_video" "$SAVED_DIR/detection_result.mp4"
        echo -e "   ${GREEN}✅ detection_result.mp4${NC}"
    fi

    # Hasil grafik training (results.png, confusion_matrix, dll)
    find "$OUTPUT_DIR" -type f \( -name "results.png" -o -name "results.csv" \
        -o -name "confusion_matrix*.png" -o -name "P_curve.png" \
        -o -name "R_curve.png" -o -name "PR_curve.png" -o -name "F1_curve.png" \) 2>/dev/null | while read f; do
        cp "$f" "$SAVED_DIR/$(basename "$f")"
        echo -e "   ${GREEN}✅ $(basename "$f")${NC}"
    done

    echo ""
    echo -e "${GREEN}🎯 Semua file penting tersimpan di: $SAVED_DIR/${NC}"
    ls -lh "$SAVED_DIR/" 2>/dev/null
}

cmd_logs() {
    rm -rf ./_kaggle_log_tmp
    mkdir -p ./_kaggle_log_tmp
    echo -e "${BLUE}📜 Mengambil log dari Kaggle...${NC}"
    "$KAGGLE_BIN" kernels output "$KERNEL_ID" -p ./_kaggle_log_tmp --quiet > /dev/null 2>&1 || true

    local log_file=$(find ./_kaggle_log_tmp -name "*.log" 2>/dev/null | head -1)
    if [ -z "$log_file" ]; then
        echo -e "${RED}❌ Log tidak ditemukan${NC}"
        return 1
    fi

    echo -e "${YELLOW}━━━━━ ERROR / STDERR ━━━━━${NC}"
    cat "$log_file" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for d in data:
        if d.get('stream_name') == 'stderr':
            txt = d.get('data', '').rstrip()
            if txt:
                print(txt)
except Exception as e:
    print(f'Error parsing: {e}')
" | tail -50

    echo ""
    echo -e "${YELLOW}━━━━━ STDOUT (terakhir) ━━━━━${NC}"
    cat "$log_file" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for d in data:
        if d.get('stream_name') == 'stdout':
            txt = d.get('data', '').rstrip()
            if txt:
                print(txt)
except Exception as e:
    print(f'Error parsing: {e}')
" | tail -30

    rm -rf ./_kaggle_log_tmp
}

cmd_all() {
    cmd_push
    echo ""
    echo -e "${YELLOW}⏳ Menunggu 30 detik agar Kaggle mulai memproses...${NC}"
    sleep 30
    cmd_watch
}

cmd_help() {
    cat <<EOF

YOLOv8 Training Helper — Kaggle

Penggunaan:
  ./run.sh push      Upload notebook ke Kaggle & jalankan
  ./run.sh status    Cek status training sekali
  ./run.sh watch     Pantau otomatis, auto-download saat selesai
  ./run.sh download  Download hasil training manual
  ./run.sh logs      Lihat log error terakhir
  ./run.sh all       Push + watch + auto-download (full workflow)

Tips:
  Kalau training sudah jalan, cukup pakai: ./run.sh watch
  Untuk monitoring lewat web: https://www.kaggle.com/code/$KERNEL_ID

EOF
}

# ─── ROUTER ───────────────────────────────────────────────────────────

case "${1:-help}" in
    push)     cmd_push ;;
    status)   cmd_status ;;
    watch)    cmd_watch ;;
    download) cmd_download && cmd_save_important ;;
    logs)     cmd_logs ;;
    all)      cmd_all ;;
    help|*)   cmd_help ;;
esac

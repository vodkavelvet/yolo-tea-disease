#!/bin/bash
# Tunggu sampai best.pt selesai download

echo "⏳ Menunggu model best.pt selesai download..."
echo "   (Ini bisa memakan waktu 5-15 menit tergantung koneksi)"
echo ""

while true; do
    if find output -name "best.pt" 2>/dev/null | grep -q "best.pt"; then
        echo ""
        echo "✅ Model best.pt ditemukan!"
        ls -lh output/*/weights/best.pt 2>/dev/null || ls -lh $(find output -name "best.pt" 2>/dev/null | head -1)
        break
    fi
    
    size=$(du -sh output/ 2>/dev/null | cut -f1)
    count=$(find output -type f | wc -l)
    echo "⏳ Download progress: $size ($count files)"
    sleep 10
done

echo ""
echo "🎉 Download selesai!"
echo ""
echo "Langkah selanjutnya:"
echo "  python3 test_local.py --model output/*/weights/best.pt --input your_video.mp4"

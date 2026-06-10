# 🎯 Panduan Testing Model YOLOv8 Lokal

Training sudah **SELESAI** di Kaggle! Sekarang Anda bisa test model dengan video/gambar lokal tanpa perlu upload ke Kaggle lagi.

---

## 📥 STEP 1: Download Model dari Kaggle

```bash
# Dari folder yolo8 with kaggle
bash run.sh download
```

Ini akan:
- Download semua output dari Kaggle
- Simpan file penting ke folder `hasil_training/`
- File penting: `best.pt` (model), `detection_result.mp4` (video hasil), metrics

Cek file:
```bash
ls -lh hasil_training/
```

Harus ada:
- ✅ `best.pt` (model, ~50MB)
- ✅ `detection_result.mp4` (video hasil dari Kaggle)
- ✅ Metrics dan grafik training

---

## 🎬 STEP 2: Test dengan Video Lokal

### Opsi A: Gunakan Script Python (Recommended)

```bash
# Test video lokal
python3 test_local.py \
  --model hasil_training/best.pt \
  --input /path/to/your/video.mp4 \
  --output hasil_testing/output.mp4 \
  --conf 0.45
```

**Contoh:**
```bash
# Test dengan video di Desktop
python3 test_local.py \
  --model hasil_training/best.pt \
  --input ~/Desktop/tea_video.mp4 \
  --output hasil_testing/tea_detected.mp4
```

**Opsi parameter:**
- `--model` (required): Path ke best.pt
- `--input` (required): Path ke video/gambar
- `--output` (optional): Path output (jika tidak ada, hanya tampil hasil)
- `--conf` (optional): Confidence threshold, default 0.45

### Opsi B: Gunakan Python Interaktif (Jupyter/VS Code)

```python
from ultralytics import YOLO
from pathlib import Path

# Load model
model = YOLO('hasil_training/best.pt')

# Test video
results = model.predict(
    source='path/to/video.mp4',
    conf=0.45,
    imgsz=640,
    save=True,  # Simpan hasil
    project='hasil_testing',
    name='run1'
)

# Atau test gambar
results = model.predict(
    source='path/to/image.jpg',
    conf=0.45,
    imgsz=640,
    save=True
)
```

---

## 🖼️ STEP 3: Test dengan Gambar Lokal

```bash
# Test gambar
python3 test_local.py \
  --model hasil_training/best.pt \
  --input ~/Desktop/tea_leaf.jpg \
  --output hasil_testing/tea_leaf_detected.jpg
```

---

## 📊 STEP 4: Lihat Hasil

### Video hasil:
```bash
# Buka video hasil deteksi
open hasil_testing/output.mp4
```

### Gambar hasil:
```bash
# Buka gambar hasil deteksi
open hasil_testing/tea_leaf_detected.jpg
```

### Metrics training:
```bash
# Lihat grafik training
open hasil_training/results.png
```

---

## 🔧 Troubleshooting

### Error: "Model tidak ditemukan"
```bash
# Pastikan sudah download
bash run.sh download

# Cek file ada
ls -lh hasil_training/best.pt
```

### Error: "Video tidak ditemukan"
```bash
# Gunakan path absolut atau relative yang benar
python3 test_local.py \
  --model hasil_training/best.pt \
  --input $(pwd)/video.mp4
```

### Error: "CUDA out of memory"
```bash
# Gunakan CPU (lebih lambat tapi aman)
# Edit test_local.py, tambah di awal:
import os
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'
```

---

## 📝 Catatan Penting

1. **Model sudah trained**: `best.pt` adalah hasil training 100 epoch di Kaggle P100
2. **Tidak perlu upload video ke Kaggle**: Semua testing bisa lokal
3. **Confidence threshold**: Default 0.45, bisa disesuaikan dengan `--conf`
4. **Output video**: Format MP4, bisa dibuka di VLC/QuickTime

---

## 🚀 Next Steps

Setelah test berhasil:

1. **Improve model**: Jika akurasi kurang, bisa:
   - Tambah dataset
   - Adjust hyperparameter
   - Train lebih lama (200+ epochs)

2. **Deploy**: Buat web app dengan FastAPI
   - Upload video/gambar
   - Jalankan deteksi
   - Download hasil

3. **Portfolio**: Push ke GitHub dengan hasil testing

---

## 📚 Referensi

- YOLOv8 Docs: https://docs.ultralytics.com/
- Model classes: `best.pt` detect 8 kelas penyakit teh
- Training metrics: Lihat `hasil_training/results.csv`

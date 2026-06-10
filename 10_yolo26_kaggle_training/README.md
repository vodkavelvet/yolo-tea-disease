# YOLO26 Tea Disease Training

Training YOLO26 (Ultralytics, Januari 2026) untuk deteksi penyakit teh.

## Keunggulan YOLO26

- **NMS-Free**: Inferensi native end-to-end tanpa Non-Maximum Suppression
- **Edge-Optimized**: Hingga 43% lebih cepat pada CPU dibanding YOLO11n
- **Lighter Head**: Menghapus DFL (Distribution Focal Loss) untuk detection head yang efisien
- **Dual-Head Architecture**: Arsitektur fleksibel untuk berbagai tugas visi komputer

## Cara Pakai

### 1. Push ke Kaggle
```bash
cd 10_yolo26_kaggle_training
sh run.sh push
```

### 2. Pantau Training
```bash
sh run.sh watch
```

### 3. Download Hasil
```bash
sh run.sh download
```

### 4. Otomatis (Push → Pantau → Download)
```bash
sh run.sh all
```

## Setting Training

| Parameter | Nilai |
|-----------|-------|
| Model     | yolo26m.pt |
| Epochs    | 100 |
| Image Size| 640 |
| Batch     | 8 |
| Patience  | 20 |
| Optimizer | SGD |
| LR0       | 0.01 |

## Output

Setelah selesai, file penting akan ada di:

```
04_outputs/yolo26_downloaded_output/   # Raw output Kaggle
04_outputs/yolo26_latest/              # File penting (*.pt, *.csv, *.png)
```

## Test Lokal

```bash
python3 07_tools/test_local.py \
  --model 04_outputs/yolo26_latest/best_overall.pt \
  --input 06_input_media/Tehbaru.mp4 \
  --output 04_outputs/yolo26_latest/hasil_yolo26.mp4
```

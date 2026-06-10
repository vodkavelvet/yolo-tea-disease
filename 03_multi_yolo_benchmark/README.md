# Multi-YOLO Tea Disease Benchmark

Folder ini dibuat terpisah agar **tidak mengganti workflow YOLOv8 lama**.

Notebook utama:

```text
Kaggle_Training_Multi_YOLO_Benchmark.ipynb
```

## Setting Training

Setting dibuat sama seperti notebook lama:

| Setting | Nilai |
|---|---:|
| `epochs` | `100` |
| `imgsz` | `640` |
| `batch` | `8` |
| `patience` | `20` |
| `optimizer` | `SGD` |
| `lr0` | `0.01` |
| task | object detection |

## Model Default

Notebook membandingkan varian medium seperti training lama (`yolov8m.pt`):

```text
yolov8m.pt
yolo11m.pt
yolo12m.pt
yolo26m.pt
```

Kalau Kaggle terasa terlalu lama, ubah di cell konfigurasi menjadi varian nano:

```text
yolov8n.pt
yolo11n.pt
yolo12n.pt
yolo26n.pt
```

## Cara Push ke Kaggle

Dari terminal lokal:

```bash
cd "03_multi_yolo_benchmark"
sh run.sh push
```

Pantau:

```bash
sh run.sh watch
```

Download output:

```bash
sh run.sh download
```

## Output Penting

Setelah selesai, Kaggle Output akan berisi:

- `yolo_benchmark_summary.csv`
- `BENCHMARK_RESULT.txt`
- `best_overall.pt`
- `yolov8m_best.pt`
- `yolo11m_best.pt`
- `yolo12m_best.pt`
- `yolo26m_best.pt`

`best_overall.pt` adalah model terbaik berdasarkan `mAP50-95`.

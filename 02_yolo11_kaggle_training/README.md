# YOLO11 Tea Disease Training

Folder ini khusus untuk training **YOLO11** di Kaggle, terpisah dari workflow YOLOv8 lama.

Notebook utama:

```text
Kaggle_Training_Multi_YOLO_Benchmark.ipynb
```

## Setting Training

Setting dibuat sama seperti notebook YOLOv8 lama:

| Setting | Nilai |
|---|---:|
| model | `yolo11m.pt` |
| `epochs` | `100` |
| `imgsz` | `640` |
| `batch` | `8` |
| `patience` | `20` |
| `optimizer` | `SGD` |
| `lr0` | `0.01` |
| task | object detection |

## Cara Push ke Kaggle

```bash
cd "02_yolo11_kaggle_training"
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

- `yolo_benchmark_summary.csv`
- `BENCHMARK_RESULT.txt`
- `best_overall.pt`
- `yolo11m_best.pt`

Test lokal contoh:

```bash
python3 ../07_tools/test_local.py --model hasil_yolo11/best_overall.pt --input ../06_input_media/Tehbaru.mp4 --output ../04_outputs/yolo11_latest/hasil_yolo11.mp4
```

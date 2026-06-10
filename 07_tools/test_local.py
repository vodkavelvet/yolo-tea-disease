#!/usr/bin/env python3
"""
Test YOLOv8 Model Lokal
Gunakan model best.pt yang sudah di-download dari Kaggle
untuk deteksi pada video lokal
"""

import cv2
import argparse
from pathlib import Path
from ultralytics import YOLO
import time

def test_on_video(model_path, video_path, output_path=None, conf=0.45):
    """
    Jalankan deteksi pada video lokal
    
    Args:
        model_path: Path ke best.pt
        video_path: Path ke video input
        output_path: Path untuk video output (opsional)
        conf: Confidence threshold (default 0.45)
    """
    
    # Validasi file
    model_path = Path(model_path)
    video_path = Path(video_path)
    
    if not model_path.exists():
        print(f"❌ Model tidak ditemukan: {model_path}")
        return False
    
    if not video_path.exists():
        print(f"❌ Video tidak ditemukan: {video_path}")
        return False
    
    print(f"✅ Model: {model_path}")
    print(f"✅ Video: {video_path}")
    
    # Load model
    print("\n🚀 Loading model...")
    model = YOLO(str(model_path))
    print(f"✅ Model loaded: {model.names}")
    
    # Buka video
    cap = cv2.VideoCapture(str(video_path))
    fps = cap.get(cv2.CAP_PROP_FPS)
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    print(f"\n📊 Video Properties:")
    print(f"  - FPS         : {fps}")
    print(f"  - Resolution  : {w}x{h}")
    print(f"  - Total frames: {total_frames}")
    print(f"  - Duration    : {total_frames/fps:.1f}s")
    
    # Setup output video jika diminta
    out = None
    if output_path:
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(str(output_path), fourcc, fps, (w, h))
        print(f"\n📹 Output: {output_path}")
    
    # Deteksi
    print(f"\n⚙️  Detection Parameters:")
    print(f"  - Confidence  : {conf}")
    print(f"  - Image Size  : 640")
    print(f"\n🎯 Starting detection...\n")
    
    frame_idx = 0
    total_det = 0
    t0 = time.time()
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_idx += 1
        
        # Deteksi
        results = model(frame, conf=conf, imgsz=640, verbose=False)
        res = results[0]
        annotated = res.plot()
        
        total_det += len(res.boxes)
        
        # Simpan ke output video
        if out:
            out.write(annotated)
        
        # Progress
        if frame_idx % max(1, total_frames // 10) == 0:
            dt = time.time() - t0
            fps_now = frame_idx / dt if dt > 0 else 0
            eta = (total_frames - frame_idx) / fps_now if fps_now > 0 else 0
            pct = 100 * frame_idx / total_frames
            print(
                f"Frame {frame_idx}/{total_frames} ({pct:.1f}%) | "
                f"Detections: {total_det} | "
                f"Speed: {fps_now:.2f} FPS | "
                f"ETA: {eta/60:.1f} min"
            )
    
    cap.release()
    if out:
        out.release()
    
    dt_total = time.time() - t0
    print("\n" + "="*60)
    print("✅ DETECTION COMPLETED")
    print("="*60)
    print(f"📊 Total frames processed : {frame_idx}")
    print(f"📊 Total detections       : {total_det}")
    print(f"⏱️  Total time             : {dt_total/60:.1f} minutes")
    if output_path:
        print(f"📤 Output video           : {output_path}")
    
    return True


def test_on_image(model_path, image_path, output_path=None, conf=0.45):
    """
    Jalankan deteksi pada gambar lokal
    
    Args:
        model_path: Path ke best.pt
        image_path: Path ke gambar input
        output_path: Path untuk gambar output (opsional)
        conf: Confidence threshold (default 0.45)
    """
    
    model_path = Path(model_path)
    image_path = Path(image_path)
    
    if not model_path.exists():
        print(f"❌ Model tidak ditemukan: {model_path}")
        return False
    
    if not image_path.exists():
        print(f"❌ Gambar tidak ditemukan: {image_path}")
        return False
    
    print(f"✅ Model: {model_path}")
    print(f"✅ Image: {image_path}")
    
    # Load model
    print("\n🚀 Loading model...")
    model = YOLO(str(model_path))
    print(f"✅ Model loaded: {model.names}")
    
    # Deteksi
    print(f"\n⚙️  Detection Parameters:")
    print(f"  - Confidence  : {conf}")
    print(f"  - Image Size  : 640")
    print(f"\n🎯 Running detection...\n")
    
    results = model(str(image_path), conf=conf, imgsz=640, verbose=True)
    res = results[0]
    
    print(f"\n✅ Detection Complete!")
    print(f"📊 Detections found: {len(res.boxes)}")
    
    # Simpan hasil
    if output_path:
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        annotated = res.plot()
        cv2.imwrite(str(output_path), annotated)
        print(f"📤 Output image: {output_path}")
    
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Test YOLOv8 model pada video/gambar lokal"
    )
    parser.add_argument(
        "--model", "-m",
        required=True,
        help="Path ke model best.pt"
    )
    parser.add_argument(
        "--input", "-i",
        required=True,
        help="Path ke video atau gambar input"
    )
    parser.add_argument(
        "--output", "-o",
        help="Path untuk output (opsional)"
    )
    parser.add_argument(
        "--conf",
        type=float,
        default=0.45,
        help="Confidence threshold (default: 0.45)"
    )
    
    args = parser.parse_args()
    
    input_path = Path(args.input)
    
    # Tentukan tipe file
    if input_path.suffix.lower() in ['.mp4', '.avi', '.mov', '.mkv']:
        test_on_video(args.model, args.input, args.output, args.conf)
    elif input_path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.bmp']:
        test_on_image(args.model, args.input, args.output, args.conf)
    else:
        print(f"❌ Format file tidak didukung: {input_path.suffix}")

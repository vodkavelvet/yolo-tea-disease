# 📁 Google Drive Integration Setup Guide

**Your Google Drive Folder:** https://drive.google.com/drive/folders/10uAVDrDkX52t8i26uHnCf7FvBt_CLWAO

This guide explains how to integrate your Google Drive folder with this YOLO Tea Disease Detection repository.

---

## 🎯 Overview: Video Workflow

```
Google Drive
    │
    ├─ input/
    │  └─ test_video.mp4          (Video test)
    │
    └─ outputs/
       ├─ yolo8/
       │  └─ yolo8_output.mp4     (YOLOv8 detection results)
       ├─ yolo11/
       │  └─ yolo11_output.mp4    (YOLO11 detection results)
       └─ yolo26/
          └─ yolo26_output.mp4    (YOLO26 detection results)
           ↓ (download)
    Local Machine
       │
       ├─ 06_input_media/videos/input/
       │  └─ test_video.mp4
       │
       └─ 06_input_media/videos/outputs/
          ├─ yolo8/yolo8_output.mp4
          ├─ yolo11/yolo11_output.mp4
          └─ yolo26/yolo26_output.mp4
```

---

## 📥 Step 1: Download Videos from Google Drive

### Prerequisites

Install gdown:
```bash
pip install gdown
```

### Get FILE_IDs from Google Drive

1. Open your Google Drive folder
2. Right-click on file → Share → Copy link
3. Extract FILE_ID from the URL:
   ```
   https://drive.google.com/file/d/FILE_ID/view?usp=sharing
                                   ^^^^^^^^
   ```

### Configure download_videos.py

Edit `06_input_media/download_videos.py`:

```python
VIDEOS_TO_DOWNLOAD = {
    "videos/input/test_video.mp4": "YOUR_TEST_VIDEO_FILE_ID",
    "videos/outputs/yolo8/yolo8_output.mp4": "YOUR_YOLO8_OUTPUT_FILE_ID",
    "videos/outputs/yolo11/yolo11_output.mp4": "YOUR_YOLO11_OUTPUT_FILE_ID",
    "videos/outputs/yolo26/yolo26_output.mp4": "YOUR_YOLO26_OUTPUT_FILE_ID",
}
```

### Run Download

```bash
cd 06_input_media
python3 download_videos.py
```

This will create the folder structure and download all videos:
```
videos/
├── input/
│   └── test_video.mp4
└── outputs/
    ├── yolo8/yolo8_output.mp4
    ├── yolo11/yolo11_output.mp4
    └── yolo26/yolo26_output.mp4
```

---

## 📤 Step 2: Upload Results to Google Drive

### Prerequisites

Install rclone:
```bash
# Linux/Mac
curl https://rclone.org/install.sh | sudo bash

# Windows
# Download from: https://rclone.org/downloads/
```

### Configure rclone with Google Drive

```bash
rclone config

# Follow these steps:
# - Choose: new remote
# - Name: google-drive
# - Type: Google Drive (option 18 or similar)
# - Client ID: Leave blank (use default)
# - Client Secret: Leave blank
# - Scope: drive (full access)
# - Follow OAuth link to authorize
# - Save config
```

### Get FOLDER_IDs

1. Open Google Drive folder
2. Right-click on subfolder → Share → Copy link
3. Extract FOLDER_ID from URL:
   ```
   https://drive.google.com/drive/folders/FOLDER_ID?usp=sharing
                                             ^^^^^^^^^
   ```

### Configure upload_videos.py

Edit `06_input_media/upload_videos.py`:

```python
DRIVE_OUTPUT_FOLDERS = {
    "yolo8": "YOUR_YOLO8_FOLDER_ID",
    "yolo11": "YOUR_YOLO11_FOLDER_ID",
    "yolo26": "YOUR_YOLO26_FOLDER_ID",
}
```

### Run Upload

```bash
cd 06_input_media
python3 upload_videos.py
```

This will upload all inference results with timestamp:
```
Google Drive/outputs/
├── yolo8/
│   └── [20260613_143022] yolo8_output.mp4
├── yolo11/
│   └���─ [20260613_143022] yolo11_output.mp4
└── yolo26/
    └── [20260613_143022] yolo26_output.mp4
```

---

## 🔄 Complete Workflow

### 1. Download Test Video

```bash
cd 06_input_media
python3 download_videos.py
# File: 06_input_media/videos/input/test_video.mp4 ✅
```

### 2. Train Models on Kaggle

```bash
cd 01_yolo8_kaggle_training
./run.sh all
# Output: 04_outputs/yolo8_latest/best.pt

cd ../02_yolo11_kaggle_training
./run.sh all
# Output: 04_outputs/yolo11_latest/best.pt

cd ../10_yolo26_kaggle_training
./run.sh all
# Output: 04_outputs/yolo26_latest/best.pt
```

### 3. Run Inference

```bash
cd 07_tools

python3 test_local.py \
  --model ../04_outputs/yolo8_latest/best.pt \
  --input ../06_input_media/videos/input/test_video.mp4 \
  --output ../06_input_media/videos/outputs/yolo8/yolo8_output.mp4

python3 test_local.py \
  --model ../04_outputs/yolo11_latest/best.pt \
  --input ../06_input_media/videos/input/test_video.mp4 \
  --output ../06_input_media/videos/outputs/yolo11/yolo11_output.mp4

python3 test_local.py \
  --model ../04_outputs/yolo26_latest/best.pt \
  --input ../06_input_media/videos/input/test_video.mp4 \
  --output ../06_input_media/videos/outputs/yolo26/yolo26_output.mp4
```

Or use automation script:
```bash
cd project_root
bash run_all_inference.sh
```

### 4. Upload Results to Google Drive

```bash
cd 06_input_media
python3 upload_videos.py
```

---

## 📋 File ID Collection Template

Copy and fill in your FILE_IDs:

```
Drive Main Folder: 10uAVDrDkX52t8i26uHnCf7FvBt_CLWAO (already provided)

Test Video (input/):
- test_video.mp4 FILE_ID: ___________________________

Output Videos (outputs/):
- yolo8_output.mp4 FILE_ID: ___________________________
- yolo11_output.mp4 FILE_ID: ___________________________
- yolo26_output.mp4 FILE_ID: ___________________________

Output Folders (for upload):
- yolo8/ FOLDER_ID: ___________________________
- yolo11/ FOLDER_ID: ___________________________
- yolo26/ FOLDER_ID: ___________________________
```

---

## 🔒 Security Notes

### File Permissions

Make sure to:
- ✅ Share files/folders with "Viewer" permission only
- ✅ Never commit `.env` files with credentials
- ✅ Use separate Drive folder for testing vs production

### .gitignore

Videos are excluded from Git:
```bash
# 06_input_media/.gitignore
videos/*.mp4
videos/**/*.mp4
.env
```

---

## 🆘 Troubleshooting

### Issue: gdown not found
```bash
pip install --upgrade gdown
```

### Issue: File ID not valid
- Verify link format: `https://drive.google.com/file/d/FILE_ID/view`
- Re-copy from Drive: Right-click → Share → Copy link

### Issue: Permission denied (rclone)
```bash
# Reconfigure rclone
rclone config

# Or reset authorization
rm ~/.config/rclone/rclone.conf
rclone config
```

### Issue: Timeout downloading large file
- Increase timeout in script (default 3600 seconds = 1 hour)
- Or use Drive web interface to download manually
- Then place file manually in `06_input_media/videos/`

### Issue: Upload stuck
```bash
# Check rclone status
rclone size google-drive:FOLDER_ID

# Cancel and retry
# (rclone will resume from where it stopped)
```

---

## 📚 Additional Resources

- **gdown GitHub:** https://github.com/wkentaro/gdown
- **rclone Docs:** https://rclone.org/drive/
- **Google Drive Limits:** https://support.google.com/drive/answer/37603

---

## ✅ Checklist

- [ ] Google Drive folder created with structure
- [ ] Test video uploaded to `input/` folder
- [ ] Output video folders created (`yolo8/`, `yolo11/`, `yolo26/`)
- [ ] FILE_IDs collected and added to `download_videos.py`
- [ ] FOLDER_IDs collected and added to `upload_videos.py`
- [ ] gdown installed: `pip install gdown`
- [ ] rclone installed and configured
- [ ] Test download: `python3 download_videos.py`
- [ ] Test upload: `python3 upload_videos.py`
- [ ] Videos in local machine: `ls 06_input_media/videos/`

---

**Your Drive Folder:** https://drive.google.com/drive/folders/10uAVDrDkX52t8i26uHnCf7FvBt_CLWAO

Happy training! 🚀

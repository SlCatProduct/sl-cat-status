# 🐱 SL CAT: Pure Status & Anti-Blur Optimizer
> **ByeBye Blur Status for WhatsApp, Instagram Stories, and Facebook (iOS & Android)**  
> Brand: **SL CAT**

---

## 🌟 Overview
**SL CAT** is a cross-platform mobile application developed with **Flutter** for **Android & Apple iOS**. It addresses the common problem where WhatsApp, Instagram, and social media platforms aggressively compress and blur user statuses and stories.

---

## 🔬 How the Anti-Blur Algorithm Works
When you upload a high-resolution (1080p/4K) video to WhatsApp:
1. WhatsApp's servers detect unsupported bitrates and large file dimensions.
2. WhatsApp forces a low-quality re-compression pass, leading to pixelation and severe blur.

### The SL CAT Solution:
- **Exact Aspect Ratio:** Scales to 720×1280 or 1080×1920 (9:16 vertical) with smart black padding to eliminate distortion.
- **Fixed GOP (Keyframe Interval):** Forces `-g 30 -keyint_min 30 -sc_threshold 0` (1 keyframe every second). When WhatsApp parses the MP4 stream, it detects a compliant keyframe structure and skips its aggressive blurry compression.
- **Target Bitrate:** 2.8 Mbps to 3.8 Mbps constant bitrate stream, fitting perfectly within WhatsApp's direct-stream threshold.
- **Web-Optimized Faststart:** Injects `-movflags +faststart` at the head of the file so WhatsApp can instantly play without re-muxing.

---

## 🚀 Key Features

| Feature | Description |
| :--- | :--- |
| **Pure HD Video Status** | Pre-compresses video to stop WhatsApp blur with zero quality loss. |
| **30s Smart Status Slicer** | Automatically splits long videos into consecutive 30-second HD clips without audio desync. |
| **Ultra HD Photo Optimizer** | Enhances status photos into lossless 1080×1920 9:16 canvas. |
| **Direct 1-Tap Status Share** | Direct intent to share processed clips straight into WhatsApp "My Status". |
| **Exports Vault** | Automatically saves all optimized clips for easy re-sharing anytime. |

---

## 📁 Project Structure

```
sl_cat_status/
├── lib/
│   ├── main.dart                      # App entry point & SL CAT Dark Neon Theme
│   ├── models/
│   │   ├── compression_preset.dart    # WhatsApp HD, Ultra 1080p, IG Presets
│   │   └── split_segment.dart         # 30-second status segment model
│   ├── services/
│   │   ├── ffmpeg_service.dart        # Core FFmpeg Anti-Blur & Splitting Engine
│   │   ├── share_service.dart         # Direct WhatsApp / Instagram Share logic
│   │   └── storage_service.dart       # Local vault & cache management
│   ├── providers/
│   │   └── status_provider.dart       # State management & live progress (0-100%)
│   ├── widgets/
│   │   ├── sl_cat_brand_header.dart   # SL CAT Neon Brand Logo & Header
│   │   ├── feature_card.dart          # Dashboard feature tiles
│   │   └── stats_badge.dart           # Resolution, duration & size badges
│   └── views/
│       ├── home_screen.dart           # Main dashboard
│       ├── video_compress_screen.dart # Anti-Blur video optimizer with live progress
│       ├── video_splitter_screen.dart # 30s status cutter with sequential sharing
│       ├── photo_optimizer_screen.dart# Lossless photo status tool
│       ├── result_screen.dart         # Before vs After player & direct share
│       └── saved_status_screen.dart   # Processed media vault
├── android/                           # Android native configuration (minSdk 24)
├── ios/                               # Apple iOS native configuration (Info.plist permissions)
└── pubspec.yaml                       # Dependencies & assets
```

---

## 🛠️ How to Build & Run

### 1. Requirements:
- Flutter SDK (3.0.0 or later)
- Android Studio / Xcode (for iOS builds)

### 2. Install Dependencies:
```bash
flutter pub get
```

### 3. Run on Connected Device:
```bash
flutter run
```

### 4. Build Android APK (Play Store):
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 5. Build Apple iOS (App Store):
```bash
flutter build ipa --release
# Open ios/Runner.xcworkspace in Xcode and archive for App Store Connect
```

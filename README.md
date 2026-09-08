# ✨ MaoneArt Studio - AI Photo Editor & Product Studio

<div align="center">

![MaoneArt Studio Banner](https://img.shields.io/badge/MaoneArt-Studio-ea580c?style=for-the-badge&logo=flutter&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-047857?style=for-the-badge)

**Aplikasi AI Photo Editor & Pembuat Foto Produk Studio Profesional (Alternatif Photoroom) Berbasis Flutter.**

</div>

---

## 📱 Tentang Aplikasi
**MaoneArt Studio** adalah aplikasi mobile Android bertenaga AI untuk memotong latar belakang gambar (AI background cutout), merancang foto produk e-commerce berstandar katalog studio, membuat pas foto resmi (3x4/4x6), menambahkan efek bayangan 3D realistis (*isometric floor shadow*), menambahkan badge toko online, dan mengekspor gambar hingga resolusi 4K Ultra HD.

Dirancang dengan antarmuka **MaoneArt Glassmorphism System** yang modern, elegan, dan ramah pengguna.

---

## 🚀 Fitur Utama

### 1. ⚡ 1-Tap AI Background Removal (Magic Cutout)
- Pemotongan objek foreground presisi tinggi berbasis AI model (RMBG-1.4 / BiRefNet).
- Mode cadangan offline cerdas (*edge alpha feathering*).
- Toggle instan untuk melihat perbandingan objek asli vs hasil cutout.

### 2. 🛍️ E-Commerce Product Studio & Bayangan Lantai 3D
- **3D Floor Shadow Simulator**: Menghasilkan bayangan lantai produk yang realistis untuk katalog Shopee, Tokopedia, dan Instagram.
- **Directional Cast Shadow**: Kontrol jarak bayangan, arah sudut cahaya (0-360°), kelembutan blur, dan kepekatan opacity.
- **Ambient Occlusion**: Bayangan halus kontak produk.

### 3. 🎨 Preset Latar Belakang Lengkap
- **Transparan**: Kotak-kotak catur (Checkerboard) untuk ekspor PNG murni.
- **Pas Foto Resmi**: Merah (Tahun Ganjil), Biru (Tahun Genap), dan Putih Bersih (E-KTP / Visa).
- **Studio E-Commerce**: Pure White, Studio Soft Gray, Cream Silk, Velvet Dark.
- **Studio Lighting**: Spotlight Glow, Amber Studio, Emerald Botanic, Neon Cyberpunk.
- **Galeri Kustom**: Gunakan foto pemandangan atau interior Anda sendiri sebagai latar belakang.

### 4. 🏷️ Badge Toko & Layer Teks
- Badge instan e-commerce: `🔥 BEST SELLER`, `⚡ FLASH SALE`, `🎉 DISKON 50%`, `⭐ ORIGINAL 100%`, `🚚 GRATIS ONGKIR`.
- Teks kustom dengan pengaturan tipografi dan warna.

### 5. 🎚️ Studio Photo EQ & Color Correction
- Pengaturan Kecerahan (Brightness), Kontras (Contrast), Kejenuhan (Vibrance / Saturation), dan Suhu Warna (Warmth).

### 6. 📐 Preset Rasio Kanvas Standar
- `1:1 Persegi` (Shopee, Tokopedia, Instagram Post)
- `4:5 Potret` (Instagram Feed Portrait)
- `9:16 Vertikal` (Instagram Story, TikTok, Reels, WA Status)
- `3:4 Pas Foto` (E-KTP, Ijazah, CV, Dokumen Resmi)
- `16:9 Lanskap` (YouTube Thumbnail, Web Banner)
- `Bebas / Asli` (Freeform Canvas)

### 7. 💾 Ekspor Berkualitas Tinggi & Berbagi
- Format **PNG Transparan** atau **JPG Studio**.
- Pilihan resolusi: **1x Standar (1080p)**, **2x HD (2K)**, dan **4x Ultra HD (4K)**.
- Simpan langsung ke `/sdcard/Download/MaoneArtStudio/` atau bagikan instan via WhatsApp, Telegram, Drive, dll.

---

## 🛠️ Arsitektur & Teknologi
- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Flutter Riverpod](https://riverpod.dev)
- **Design System**: MaoneArt Glassmorphism (`#0C0A09`, `#EA580C`, `#047857`, Symmetrical Action Dialogs)
- **Image Engine**: Dart Image manipulation, Custom Matrix Color Filtering & RepaintBoundary Rendering
- **CI/CD Pipeline**: GitHub Actions Automatic Release APK Builder

---

## 📦 Kompilasi APK (GitHub Actions)
Aplikasi ini telah dilengkapi dengan workflow GitHub Actions (`.github/workflows/build_apk.yml`).
Setiap kali Anda melakukan push ke branch `main`, GitHub Actions akan secara otomatis mengompilasi release APK dan menerbitkannya di menu **Releases** repositori Anda.

---

<div align="center">
Dibuat dengan ❤️ oleh <b>Hermawan (MaoneArt)</b>
</div>

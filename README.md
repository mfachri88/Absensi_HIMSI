# Absensi HIMSI

Proyek **Absensi HIMSI** adalah aplikasi berbasis Flutter yang dirancang untuk membantu pengelolaan absensi, notulensi, dan manajemen konten seperti berita dan agenda kegiatan. Aplikasi ini mendukung fitur untuk admin dan pengguna biasa, dengan antarmuka yang ramah pengguna.

## Fitur Utama

### 1. **Manajemen Absensi**
- Form absensi dengan validasi token.
- Rekapitulasi data absensi dengan filter berdasarkan kategori, tanggal, dan lainnya.
- Ekspor data absensi (placeholder untuk implementasi lebih lanjut).

### 2. **Manajemen Konten**
- **Berita**: Tambah, edit, dan hapus berita.
- **Agenda**: Tambah, edit, dan hapus agenda kegiatan.
- **Notulensi**: Tambah, edit, dan hapus notulensi rapat.

### 3. **Manajemen Pengguna**
- Login/logout dengan autentikasi.
- Peran pengguna: Admin dan Member.
- Pengaturan profil pengguna, termasuk ubah password.

### 4. **Manajemen Token**
- Admin dapat membuat token absensi dengan durasi tertentu.
- Validasi token untuk memastikan kehadiran yang sah.

## Teknologi yang Digunakan
- **Flutter**: Framework utama untuk pengembangan aplikasi.
- **Dart**: Bahasa pemrograman yang digunakan.
- **Provider**: Untuk state management (opsional, jika digunakan).
- **Image Picker**: Untuk memilih gambar dari galeri atau kamera.
- **Intl**: Untuk format tanggal.

## Instalasi dan Penggunaan

### 1. **Persyaratan**
- Flutter SDK versi terbaru.
- Android Studio atau VS Code (opsional).
- Emulator Android/iOS atau perangkat fisik.

### 2. **Langkah Instalasi**
1. Clone repository ini:
   ```bash
   git clone https://github.com/mfachri88/Absensi_HIMSI.git
   cd Absensi_HIMSI
2. Jalankan perintah berikut untuk mengunduh dependensi:
   ```bash
    flutter pub get
3. Jalankan aplikasi di emulator atau perangkat fisik:
   ```bash
   flutter run

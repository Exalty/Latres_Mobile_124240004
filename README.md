# Latres_Mobile_124240004 - TV Shows App

Aplikasi Katalog Serial TV & Film yang dibangun menggunakan Flutter dengan fitur integrasi REST API, Local Storage (Hive & SharedPreferences), State Management, Local Notification, dan Location-Based Service (LBS).

## Fitur Utama
1. **Autentikasi & Sesi Login**: Menggunakan `SharedPreferences` untuk menyimpan status login secara persisten.
2. **Katalog Film Dinamis**: Mengambil data serial TV dari REST API TVMaze (`http`).
3. **Detail & Sinopsis**: Menampilkan data detail, rating, genre chips, dan sinopsis lengkap.
4. **Offline Favorites (Watchlist)**: Menyimpan serial TV favorit secara lokal dengan `Hive` & `TypeAdapter`.
5. **Notifikasi Sistem (Local Notification)**:
   - Notifikasi instan saat menambahkan/menghapus serial favorit.
   - Pengingat jadwal tayang/nonton (*Scheduled Watch Reminder*) dengan durasi pilihan.
6. **Location-Based Service (LBS)**:
   - Mendeteksi posisi koordinat GPS pengguna secara *real-time* via `geolocator`.
   - Mengubah koordinat GPS menjadi nama wilayah/kota (*Reverse Geocoding* via `geocoding`).
   - Menghitung dan menampilkan rekomendasi **Bioskop Terdekat** (XXI, CGV, Cinepolis) beserta jarak tempuh (KM).
   - Tombol shortcut rute peta langsung ke aplikasi **Google Maps** via `url_launcher`.

# Universal-Optimizer-for-Android-Snapdragon—Beta-1 (Root Only)

Script ini adalah kumpulan optimasi sistem untuk perangkat Android yang sudah di-root. Tujuannya adalah untuk meningkatkan performa, mengurangi lag, dan membersihkan file-file sampah. **PERHATIAN: Penggunaan script ini memerlukan akses root dan mungkin memiliki risiko. Lakukan dengan hati-hati dan risiko ditanggung sendiri.**

## Fitur Utama

* **Light Scheduler Tweaks:** Menonaktifkan `sched_autogroup_enabled` untuk mengurangi latency.
* **Reduce CPU Latency:** Mengaktifkan `sched_child_runs_first` untuk prioritas thread anak.
* **Boosting Performance While Charging:** Meningkatkan performa saat perangkat sedang diisi daya.
* **Optimasi I/O Scheduler:** Memungkinkan pemilihan I/O scheduler dan mengatur `read_ahead_kb`.
* **Clear System Cache:** Membersihkan cache sistem untuk membebaskan memori.
* **Set Cache Ratio:** Mengatur rasio `dirty_ratio` dan `dirty_background_ratio`.
* **Cleaning Up Junk Files:** Menghapus file-file log, statistik penggunaan, ANR, tombstone, dan cache aplikasi.
* **Optimizing Dalvik/ART VM Cache:** Mengatur parameter heap VM.
* **Disable GMS Background Usage (opsional):** Mencegah Google Mobile Services berjalan di latar belakang (membutuhkan command `cmd`).
* **Kill GMS Apps (opsional):** Mematikan paksa beberapa aplikasi GMS.
* **Close Background Apps:** Menutup aplikasi yang berjalan di latar belakang.
* **Force Kill Apps:** Mematikan paksa aplikasi pengguna yang tidak masuk ke dalam daftar putih (whitelist).
* **Aggressive User App Cleanup (fallback):** Metode pembersihan aplikasi pengguna yang lebih agresif sebagai langkah terakhir.

## Cara Penggunaan

1.  Pastikan perangkat Android yang digunakan sudah memiliki akses root.
2.  Download script `Universal-Optimizer-for-Android-Snapdragon.sh`.
3.  Pindahkan script ke perangkat Android yang digunakan (misalnya menggunakan `adb push`).
4.  Buka aplikasi terminal di Android (seperti Termux atau Terminal Emulator).
5.  Navigasi ke direktori tempat script di simpan.
6.  Berikan izin eksekusi pada script:
    ```bash
    chmod +x universal_optimizer.sh
    ```
7.  Jalankan script dengan perintah `su` (super user):
    ```bash
    su -c "./universal_optimizer.sh"
    ```
8.  (Opsional) Anda bisa menentukan I/O scheduler saat menjalankan script:
    ```bash
    su -c "./universal_optimizer.sh cfq"
    ```
    Ganti `cfq` dengan scheduler lain yang tersedia di perangkat anda. Jika tidak diisi, script akan meminta input secara interaktif.

## Penjelasan Script

Script ini melakukan beberapa optimasi dengan perintah-perintah `su` (super user). Berikut penjelasan singkat beberapa bagian penting:

* Bagian awal script mengatur tweak kernel dan properti sistem untuk meningkatkan responsivitas.
* Bagian I/O scheduler memungkinkan anda memilih scheduler yang berbeda untuk manajemen disk.
* Pembersihan cache dan file sampah membantu membebaskan ruang penyimpanan dan memori.
* Optimasi Dalvik/ART VM bertujuan untuk meningkatkan kinerja aplikasi.
* Penonaktifan dan pematian aplikasi GMS (jika diaktifkan) dapat membantu mengurangi penggunaan sumber daya di latar belakang.
* Bagian akhir script secara agresif menutup aplikasi pengguna untuk membebaskan memori.

## Daftar Aplikasi yang Diizinkan (Whitelist)

Beberapa aplikasi sistem penting dimasukkan ke dalam daftar putih agar tidak dimatikan secara paksa oleh script:

init zygote zygote64 system_server servicemanager hwservicemanager vndservicemanager surfaceflinger com.android.systemui com.android.settings android.hardware.keymaster@4.0-service-qti android.hardware.bluetooth@1.0-service-qti android.hardware.camera.provider@2.4-service android.hardware.gnss@2.0-service-qti android.hardware.graphics.allocator@2.0-service android.hardware.graphics.composer@2.1-service android.hardware.health@2.1-service android.hardware.sensors@1.0-service android.hardware.usb@1.0-service android.hardware.wifi@1.0-service com.xiaomi.parts vendor.display.color@1.0-service vendor.qti.hardware.soter@1.0-service vendor.qti.hardware.vibrator.service vendor.qti.hardware.tui_comm@1.0-service-qti

## Peringatan

* **Akses Root Diperlukan:** Script ini hanya berfungsi pada perangkat Android yang sudah di-root.
* **Risiko Penggunaan:** Penggunaan script ini dapat menyebabkan masalah pada sistem jika tidak dilakukan dengan benar. Backup data penting anda sebelum menjalankan script ini.
* **Garansi Batal:** Melakukan root dan menjalankan script kustom dapat membatalkan garansi perangkat.
* **Hati-hati dengan Perintah `kill -9`:** Perintah `kill -9` mematikan proses secara paksa dan dapat menyebabkan hilangnya data atau masalah sistem lainnya jika digunakan secara tidak tepat. Script ini menggunakan perintah ini sebagai langkah terakhir untuk membersihkan aplikasi.

## Kontribusi

Jika anda memiliki ide untuk meningkatkan script ini, jangan ragu untuk memberikan kontribusi melalui pull request.

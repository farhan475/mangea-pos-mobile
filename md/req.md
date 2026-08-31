# System Requirements

## 1. Functional Requirements (Kebutuhan Fungsional)
- **F-01 (Multi-Device):** Aplikasi harus menyesuaikan tata letak secara otomatis antara mode Tablet (Landscape) dan Handphone (Portrait).
- **F-02 (Offline Mode):** Aplikasi wajib tetap beroperasi tanpa internet. Data disimpan lokal dan disinkronkan saat koneksi kembali.
- **F-03 (Thermal Printing):** Dukungan cetak struk via Bluetooth dan USB menggunakan protokol ESC/POS.
- **F-04 (Real-time Sync):** Perubahan status pesanan di satu device harus terupdate di device lain tanpa refresh manual.

## 2. Non-Functional Requirements (Kebutuhan Non-Fungsional)
- **NF-01 (Performance):** Respon UI tidak boleh lebih dari 100ms.
- **NF-02 (Reliability):** Mekanisme sinkronisasi harus memastikan tidak ada data duplikat (Idempotency).
- **NF-03 (Security):** Autentikasi berbasis JWT untuk akses API Backend.

## 3. Hardware Requirements
- **Tablet:** Minimal RAM 4GB, Layar 10 inci.
- **Smartphone:** Minimal RAM 3GB.
- **Printer:** Printer Thermal 58mm atau 80mm (Bluetooth/USB).
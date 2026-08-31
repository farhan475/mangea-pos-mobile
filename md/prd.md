**PRD**: Redesign **POS** System (**LUNA** to Bitepoint Style)
Version: 1.0
Status: Draft for AI Development/Design
Objective: Mentransformasi aplikasi **POS** transaksional statis menjadi Dashboard manajemen restoran yang proaktif dan visual.
## Visi Produk
Mengganti interface **LUNA** **POS** yang berbasis daftar (list-heavy) menjadi interface *Command Center* yang membagi informasi berdasarkan urgensi: Metrik Real-time, Antrean Pesanan (Order List), dan Antrean Pembayaran (Payment).
## Arsitektur Informasi & Navigasi
Sidebar (Menu Utama):
Dashboard (New): Ringkasan performa harian.
Menu/**POS**: Daftar produk untuk input pesanan.
Orders: Manajemen status pesanan (Kitchen/Bar flow).
Table (New/Optimized): Denah meja restoran.
Accounting/Reports: Laporan keuangan dan shift.
Settings: Konfigurasi sistem.
## Spesifikasi Fitur Utama (Berdasarkan Redesign)
- Dashboard Header (Top Metrics)
| Fitur | Deskripsi | Logika Data |
| --- | --- | --- |
| New Orders | Counter jumlah pesanan yang baru masuk. | Pesanan dengan status pending dalam 1 jam terakhir. |
| Total Orders | Total pesanan sukses hari ini. | Agregasi harian dengan persentase pertumbuhan vs kemarin. |
| Waiting List | Jumlah meja atau pelanggan yang sedang menunggu. | Status meja occupied tapi pesanan belum ready. |
- Split-Screen Workflow (Core UI)
Area utama dibagi menjadi dua kolom besar untuk mempercepat perputaran meja:
Order List (Left Column):
Search Bar: Filter berdasarkan nama pelanggan atau nomor meja.
Order Card: Menampilkan Kode Meja (A4, B2, dll), Nama Pelanggan, Jumlah Item, dan Status Badge.
Status Logic:
Ready (Hijau): Siap antar.
In Progress (Kuning): Sedang dimasak.
Completed (Biru): Selesai makan, menunggu bayar.
Payment (Right Column):
Daftar pelanggan yang siap bayar.
Action Button: Tombol *Pay Now* yang langsung membuka modal transaksi.
- Sidebar Widgets (Right Side)
Popular Dishes:
Daftar 4-5 menu paling laku secara real-time.
Membantu pelayan merekomendasikan menu ke pelanggan baru.
Out of Stock:
Notifikasi item yang habis atau akan tersedia di jam tertentu.
Mencegah salah input pesanan di bagian **POS**.
## Panduan Desain & UI (UI/UX Guidelines)
Layout: Card-based system dengan soft shadow dan border-radius besar (20px-24px).
Warna:
Primary: Teal/Dark Green (#**005B50**) - Untuk kesan profesional & tenang.
Secondary: Warm Yellow (#**FFC107**) - Untuk elemen interaktif/tombol utama.
Background: Light Gray/Off-white (#**F8F9FA**).
Tipografi: Menggunakan font Sans-serif yang bersih (seperti Inter atau Poppins) dengan hierarki berat (Bold untuk ID Meja, Regular untuk detail).
## User Flow: Dari Pesanan ke Pembayaran
Input: Pelayan masuk ke menu **POS**, pilih meja, input menu.
Tracking: Pesanan otomatis muncul di Dashboard > Order List dengan status In Progress.
Ready: Kitchen update status, badge di Dashboard berubah jadi Ready.
Billing: Pelanggan minta tagihan, status berubah jadi Completed, pesanan pindah/muncul menonjol di kolom Payment.
Closing: Kasir klik Pay Now, pilih metode pembayaran, cetak struk.

Role: Bertindaklah sebagai Senior Flutter Developer & System Architect berpengalaman dalam membangun sistem **POS** (Point of Sale) Enterprise. Task: Bangun struktur aplikasi Flutter untuk *Bitepoint **POS*** yang mendukung Tablet & Mobile, memiliki kemampuan Offline-First, dan integrasi Thermal Printer. ## UI/UX Vision (Bitepoint Style): Layout: Gunakan Dashboard-centric layout. Tablet: Sidebar tetap di kiri, area utama menggunakan 2-3 kolom (Header Metrik -> Order List & Payment List -> Sidebar Widgets). Mobile: Gunakan Bottom Navigation dan Viewport yang responsif (tumpuk kolom menjadi list vertikal). Design System: Corner radius 20dp, palet warna Teal (#**005B50**) dan Mustard Yellow (#**FFC107**). Gunakan Card widget dengan elevasi rendah dan shadow lembut. ## Technical Architecture: State Management: Gunakan BLoC atau Riverpod untuk memisahkan logika bisnis dan UI. Responsive Engine: Implementasikan LayoutBuilder untuk mendeteksi ukuran layar dan menyesuaikan jumlah kolom secara dinamis. ## Offline-First Logic (Wajib): Gunakan Hive atau Drift (SQLite) untuk penyimpanan lokal. Sync Mechanism: Setiap transaksi baru disimpan di database lokal terlebih dahulu. Buat SyncManager yang mendeteksi koneksi internet; jika online, kirim data tertunda ke Backend Go melalui **REST** **API**. Pastikan menu produk di-cache secara lokal sehingga aplikasi tetap bisa bekerja tanpa internet. ## Thermal Printing Module (Wajib): Gunakan library esc_pos_utils dan flutter_pos_printer_platform. Buat class PrinterService untuk menghandle koneksi Bluetooth dan **USB**. Buat template struk (Receipt) yang mencakup: Logo, Nama Toko, Detail Order, Pajak, dan Total. ## Core Screens to Build: Main Dashboard: Header metrik (Total Order, New Order), Split view untuk Order List (status tracking) dan Payment List (ready to bill). **POS** Screen: Grid menu produk dengan filter kategori, Search bar, dan Sidebar keranjang belanja. Report Screen: Ringkasan penjualan harian dari data lokal/sync. ## Backend Integration: Hubungkan ke **API** Golang untuk autentikasi, sinkronisasi data, dan update status order secara real-time via Websockets (jika online). Instructions for Initial Setup: Mulailah dengan membuat folder struktur berbasis fitur (features/dashboard, features/pos, features/sync). Implementasikan responsivitas dasar untuk Tablet (Landscape) dan HP (Portrait). Tunjukkan kode untuk OrderCard yang memiliki status badge (Ready, In Progress, Completed). Berikan boilerplate untuk PrinterService menggunakan Bluetooth.
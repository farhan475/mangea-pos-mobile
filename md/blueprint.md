1. Struktur Folder Flutter (Feature-Driven Architecture)
Struktur ini memastikan kode Anda rapi, mudah diuji, dan modular.
code
Text
lib/
├── core/                        # Komponen global & utilitas
│   ├── constants/               # Warna, ukuran, API keys
│   ├── network/                 # Dio client, interceptors
│   ├── printer/                 # ESC/POS Printer Service logic
│   ├── theme/                   # App Theme (Teal & Yellow style)
│   └── utils/                   # Validasi, formatter mata uang
├── data/                        # Layer Data & Sinkronisasi
│   ├── local/                   # Hive/Drift (Offline Storage)
│   ├── remote/                  # Go Backend API services
│   ├── repositories/            # Menentukan ambil data dari Local atau Remote
│   └── sync/                    # SyncManager (Logic upload data offline ke Go)
├── domain/                      # Business Logic & Entities
│   ├── models/                  # Data class (Product, Order, User)
│   └── repository_interfaces/    # Abstraksi repository
├── features/                    # UI Berbasis Fitur
│   ├── dashboard/               # Widget dashboard & status tracking
│   ├── pos/                     # Grid menu, cart, & checkout
│   ├── reports/                 # Laporan harian & shift
│   └── settings/                # Printer & Account config
├── shared_widgets/              # Widget reusable (Button, TextField, Card)
└── main.dart                    # Entry point & app initialization
2. Skema Database MySQL (Optimized for Sync & Dashboard)
Gunakan UUID sebagai Primary Key agar saat offline, Flutter bisa membuat ID unik tanpa perlu menunggu respon dari database MySQL di server.
code
SQL
-- 1. Tabel Produk & Kategori
CREATE TABLE categories (
    id VARCHAR(36) PRIMARY KEY, -- Gunakan UUID
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id VARCHAR(36) PRIMARY KEY,
    category_id VARCHAR(36),
    name VARCHAR(255) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    stock INT DEFAULT 0,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- 2. Tabel Order (Otak dari Dashboard)
CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY, -- Dibuat oleh Flutter/Go
    user_id VARCHAR(36),
    customer_name VARCHAR(100),
    table_number VARCHAR(10),
    total_amount DECIMAL(15, 2) NOT NULL,
    status ENUM('pending', 'cooking', 'ready', 'paid', 'cancelled') DEFAULT 'pending',
    payment_method ENUM('cash', 'qris', 'debit') NULL,
    sync_status ENUM('synced', 'pending') DEFAULT 'synced', -- Penting untuk Offline Sync
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Detail Item Pesanan
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(36),
    product_id VARCHAR(36),
    quantity INT NOT NULL,
    price_at_sale DECIMAL(15, 2) NOT NULL,
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 4. Indeks untuk Performa Dashboard "Popular Dishes"
CREATE INDEX idx_order_status ON orders(status);
CREATE INDEX idx_created_at ON orders(created_at);
3. Logika Sinkronisasi (Offline-First)
Ini adalah alur kerja yang harus Anda tanamkan pada AI saat membangun:
Input Order: Saat kasir klik 'Bayar' atau 'Pesan', Flutter simpan ke Local DB (Hive/Drift) dengan sync_status = 'pending'.
Sync Background: Flutter menjalankan background service yang mengecek: "Apakah ada internet? Apakah ada data dengan status pending?"
Push to Go: Flutter kirim JSON pesanan ke API Go.
Backend Go: Menerima data, simpan ke MySQL, lalu kirim respon sukses.
Mark as Synced: Flutter update status di Local DB menjadi synced.
4. Strategi Cetak Struk (Flutter)
Berikan instruksi ini ke AI Anda untuk modul Printer:
Discovery: Cari perangkat Bluetooth menggunakan flutter_blue_plus atau print_bluetooth_thermal.
Template: Buatlah fungsi generateReceipt(Order order) yang merubah data Order menjadi deretan bytes perintah ESC/POS.
Format:
[C] Center: Nama Toko & Alamat.
[L] Left: Nama Menu & Qty.
[R] Right: Harga.
[C] Center: Footer / QR Code.
Langkah Selanjutnya:
Anda sekarang memiliki:
Konsep Visual (Bitepoint style).
PRD & Tech Stack (Flutter, Go, MySQL).
Struktur Folder & Skema Database.
Saran Lyra:
Mulailah dengan membangun UI Dashboard (Layout Kolom) di Flutter terlebih dahulu. Setelah UI-nya terasa pas di Tablet dan HP, baru masuk ke integrasi database lokal (Hive).

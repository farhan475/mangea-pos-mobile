# Database Design (MySQL)

## 1. Struktur Tabel Utama

### A. Tabel `products`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | VARCHAR(36) | Primary Key (UUID) |
| `category_id` | VARCHAR(36) | FK to categories |
| `name` | VARCHAR(255) | Nama produk |
| `price` | DECIMAL(15,2) | Harga jual |
| `is_available` | BOOLEAN | Status stok |

### B. Tabel `orders` (Pusat Data)
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | VARCHAR(36) | Primary Key (UUID) |
| `table_number` | VARCHAR(10) | Identitas meja |
| `total_amount` | DECIMAL(15,2) | Total harga |
| `status` | ENUM | pending, cooking, ready, paid |
| `sync_status` | ENUM | synced, pending (Untuk Flutter-Go sync) |
| `created_at` | TIMESTAMP | Waktu pesanan dibuat |

### C. Tabel `order_items`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INT AI | Primary Key |
| `order_id` | VARCHAR(36) | FK to orders |
| `product_id` | VARCHAR(36) | FK to products |
| `qty` | INT | Jumlah pesanan |

## 2. Logika Sinkronisasi Data (Offline-First)
1. **Device ID:** Setiap device memiliki ID unik.
2. **UUID Strategy:** Semua ID (PK) digenerate di Flutter menggunakan UUID v4 untuk menghindari konflik saat sinkronisasi ke MySQL.
3. **Versioning:** Gunakan kolom `updated_at` untuk menentukan data terbaru saat konflik sinkronisasi terjadi.
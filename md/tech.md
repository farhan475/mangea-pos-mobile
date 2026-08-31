# Tech Stack Specification

## 1. Frontend (Mobile & Tablet)
- **Framework:** Flutter
- **State Management:** BLoC (Business Logic Component) atau Riverpod.
- **Local Database:** Hive (NoSQL) atau Drift (SQLite) untuk penyimpanan data offline.
- **Printer Protocol:** `esc_pos_utils` & `flutter_pos_printer_platform`.
- **UI Toolkit:** Tailwind-style Flutter (custom design system) dengan Google Fonts (Inter/Poppins).

## 2. Backend (Server Side)
- **Language:** Golang (Go)
- **Framework:** Echo atau Gin Web Framework.
- **Real-time Engine:** Websockets (untuk push notifications status pesanan).
- **Validation:** Go-playground/validator.

## 3. Infrastructure & DevOps
- **Database:** MySQL 8.0+
- **API Style:** RESTful API dengan JSON.
- **Container:** Docker (untuk standarisasi environment backend).
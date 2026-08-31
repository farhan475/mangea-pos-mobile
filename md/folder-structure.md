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
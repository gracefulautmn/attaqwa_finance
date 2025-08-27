# Attaqwa Finance - Aplikasi Keuangan Sederhana

## Gambaran Umum

Attaqwa Finance adalah aplikasi mobile untuk mengelola keuangan personal dengan cara yang mudah dan sederhana. Aplikasi ini dibuat dengan Flutter dan menggunakan Supabase sebagai backend.

## Fitur Utama

### ✨ Flow Sederhana
- **Pemasukan**: Catat semua uang yang masuk
- **Pengeluaran**: Catat semua uang yang keluar  
- **Kategori**: Organisir transaksi berdasarkan kategori
- **Jumlah**: Input nominal dengan format yang mudah
- **Catatan**: Tambahkan deskripsi untuk setiap transaksi

### 📱 Halaman Aplikasi
1. **Home/Dashboard**: Ringkasan saldo dan transaksi terbaru
2. **Tambah Transaksi**: Form untuk menambah pemasukan/pengeluaran
3. **Riwayat Transaksi**: Daftar semua transaksi dengan filter
4. **Kategori**: Kelola kategori transaksi

## Struktur Database

### Tabel `categories`
```sql
- id (SERIAL PRIMARY KEY)
- name (VARCHAR) - Nama kategori
- icon (VARCHAR) - Icon kategori  
- color (VARCHAR) - Warna kategori
- created_at, updated_at (TIMESTAMP)
```

### Tabel `transactions` 
```sql
- id (SERIAL PRIMARY KEY)
- type (VARCHAR) - 'income' atau 'expense'
- amount (DECIMAL) - Jumlah uang
- category_id (INTEGER) - Referensi ke categories
- description (TEXT) - Catatan transaksi
- transaction_date (DATE) - Tanggal transaksi
- created_at, updated_at (TIMESTAMP)
```

## Setup Project

### Prerequisites
- Flutter SDK (3.8.1+)
- Dart SDK
- Android Studio / VS Code
- Supabase Account

### Installation

1. **Clone repository**
```bash
git clone <repository-url>
cd attaqwa_finance
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Supabase**
   - Buat project baru di [Supabase](https://supabase.com)
   - Jalankan SQL schema dari file `database_schema.sql`
   - Update file `.env` dengan URL dan API key Anda

4. **Run aplikasi**
```bash
flutter run
```

## Struktur Folder

```
lib/
├── main.dart                    # Entry point aplikasi
├── app/
    ├── data/
    │   ├── models/              # Model data (Category, Transaction)
    │   └── services/            # Service untuk API calls
    ├── modules/                 # Feature modules
    │   ├── home/               # Dashboard
    │   ├── add_transaction/    # Form tambah transaksi  
    │   ├── transactions/       # Riwayat transaksi
    │   └── categories/         # Kelola kategori
    ├── routes/                 # Routing konfigurasi
    ├── themes/                 # Theme dan styling
    └── widgets/                # Reusable widgets
```

## Cara Penggunaan

### 1. Tambah Transaksi Baru
- Tap tombol "+" di halaman Home
- Pilih jenis: Pemasukan atau Pengeluaran
- Masukkan jumlah uang
- Pilih kategori yang sesuai
- Pilih tanggal transaksi
- Tambahkan catatan (opsional)
- Tap "Simpan Transaksi"

### 2. Lihat Riwayat Transaksi
- Dari Home, tap "Riwayat" atau "Lihat Semua"
- Filter berdasarkan: Semua, Pemasukan, atau Pengeluaran
- Swipe kiri pada transaksi untuk menghapus

### 3. Kelola Kategori
- Dari Home, tap menu "Kategori"
- Lihat semua kategori yang tersedia
- Hapus kategori yang tidak diperlukan

## Kategori Default

Aplikasi sudah dilengkapi dengan kategori default:

**Pengeluaran:**
- Makanan & Minuman 🍽️
- Transportasi 🚗  
- Belanja 🛒
- Kesehatan 🏥
- Pendidikan 🎓
- Hiburan 🎬
- Tagihan 📄
- Lain-lain 📂

**Pemasukan:**
- Gaji 💼
- Bisnis 🏢
- Investasi 📈
- Hadiah 🎁
- Lainnya 💰

## Teknologi yang Digunakan

- **Flutter**: Framework UI
- **GetX**: State management & routing
- **Supabase**: Backend as a Service
- **Intl**: Formatting tanggal dan mata uang

## Kontribusi

1. Fork repository
2. Buat feature branch (`git checkout -b feature/nama-fitur`)
3. Commit perubahan (`git commit -am 'Tambah fitur baru'`)
4. Push ke branch (`git push origin feature/nama-fitur`)
5. Buat Pull Request

## Lisensi

Project ini menggunakan lisensi MIT. Lihat file `LICENSE` untuk detail.

## Support

Jika ada pertanyaan atau masalah, silakan buat issue di repository atau hubungi developer.

---

**Attaqwa Finance** - Aplikasi keuangan yang mudah dan sederhana 💰✨

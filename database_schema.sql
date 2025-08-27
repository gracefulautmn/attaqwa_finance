-- Database Schema untuk Aplikasi Keuangan Sederhana
-- Attaqwa Finance

-- Tabel Kategori
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(50),
  color VARCHAR(10),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Transaksi
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')), -- pemasukan atau pengeluaran
  amount DECIMAL(15,2) NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  description TEXT,
  transaction_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT INTO categories (name, icon, color) VALUES
-- Kategori Pengeluaran
('Makanan & Minuman', 'restaurant', '#FF6B6B'),
('Transportasi', 'directions_car', '#4ECDC4'),
('Belanja', 'shopping_cart', '#45B7D1'),
('Kesehatan', 'local_hospital', '#96CEB4'),
('Pendidikan', 'school', '#FECA57'),
('Hiburan', 'movie', '#FF9FF3'),
('Tagihan', 'receipt', '#54A0FF'),
('Lain-lain', 'category', '#5F27CD'),

-- Kategori Pemasukan
('Gaji', 'work', '#00D2D3'),
('Bisnis', 'business', '#FF9F43'),
('Investasi', 'trending_up', '#05C46B'),
('Hadiah', 'card_giftcard', '#FFC312'),
('Lainnya', 'attach_money', '#0B8043');

-- Indexes untuk performa
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_category ON transactions(category_id);

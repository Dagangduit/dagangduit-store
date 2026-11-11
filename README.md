# DagangDuit — Toko EA & Indikator Trading

Website katalog produk trading (EA & Indikator MT4/MT5) dengan checkout QRIS, sistem sewa/beli, dan panel admin untuk mengelola produk.

## Fitur

### Frontend (`index.html`)
- **Katalog produk** dari Supabase: search, filter kategori (Semua/EA/Indicator), kartu produk dengan efek tilt + shine.
- **Multi-galeri foto** per produk — lightbox dengan zoom (scroll wheel), drag pan, navigasi ‹ › / panah keyboard.
- **Harga fleksibel**: mode beli sekali atau sewa 1/3/12 bulan, diskon otomatis (harga coret).
- **Checkout QRIS**: modal pembayaran + konfirmasi otomatis via WhatsApp.
- **i18n ID/EN**: toggle bahasa, seluruh teks ikut berganti (hero, kalkulator, FAQ, testimoni, katalog, modal).
- **Mata uang otomatis**: ID → Rupiah, EN → USD dengan kurs live (refresh 1 jam).
- **Kalkulator profit compounding** real-time.
- **Ticker harga pasar live** (Yahoo Finance, dengan fallback data).
- Animasi: aurora background, particle, typing effect, counter, marquee testimoni, scroll reveal, confetti.

### Admin (`admin.html`)
- Login via Supabase Auth.
- CRUD produk: nama, kategori, platform, deskripsi, diskon %, harga beli + sewa.
- **Pilihan mata uang IDR/USD** — input USD otomatis dikonversi ke IDR via kurs live.
- Upload **multi-gambar** ke Supabase Storage (foto pertama = cover).
- Tabel produk dengan **search, filter kategori, dan sorting** (nama, harga, tanggal).

## Tech Stack
- HTML + Tailwind CSS (CDN browser v4)
- [Supabase](https://supabase.com) JS v2 — database, auth, storage
- Vanilla JavaScript (tanpa build step)

## Setup

### 1. Supabase Project
1. Buat project di [supabase.com](https://supabase.com).
2. Jalankan `schema.sql` di **SQL Editor** untuk membuat tabel `products` + RLS policies.
3. Buat **Storage bucket** bernama `product-images` (public).
4. Copy `SUPABASE_URL` dan `SUPABASE_ANON_KEY` — sudah terisi di kedua file HTML.

### 2. Jalankan
Buka langsung di browser atau serve statis:

```bash
npx serve .
# atau
python -m http.server 8000
```

Lalu buka `index.html` (toko) dan `admin.html` (panel admin).

### 3. Admin
- Daftar/login lewat `admin.html` menggunakan akun Supabase Auth.
- Tambah produk → upload gambar → simpan. Produk langsung tampil di katalog.

## Struktur File

```
├── index.html      # Toko / katalog publik
├── admin.html      # Panel admin (login + CRUD produk)
├── schema.sql      # Skema database + migrasi
├── logo.png        # Logo DagangDuit
├── favicon.ico     # Favicon
└── README.md
```

## Skema Database (`products`)

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | Nama produk |
| `description` | text | Deskripsi |
| `category` | text | `EA` / `Indicator` |
| `platform` | text | `MT4` / `MT5` |
| `price` | numeric | Harga beli (IDR) |
| `price_1m` / `price_3m` / `price_12m` | numeric | Harga sewa per durasi (IDR, nullable) |
| `discount_percent` | numeric | Diskon 0–100% |
| `images` | jsonb | Array URL gambar |
| `image_url` | text | Cover image (gambar pertama) |
| `created_at` | timestamptz | Tanggal dibuat |

> Semua harga disimpan dalam **IDR**. Konversi USD↔IDR dilakukan di frontend/admin via kurs live.

## Konfigurasi WhatsApp
Nomor admin di-hardcode di `index.html` (`wa.me/6285161853108`). Ganti sesuai kebutuhan.

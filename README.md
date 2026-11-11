# DagangDuit — Toko EA & Indikator Trading

Website katalog produk trading (EA & Indikator MT4/MT5) dengan checkout multi-metode (QRIS & internasional), sistem sewa/beli, tracking order, dan panel admin lengkap.

## Fitur

### Frontend (`index.html`)
- **Katalog produk** dari Supabase: search, filter kategori (Semua/EA/Indicator), kartu produk dengan efek tilt + shine.
- **Modal detail produk**: galeri gambar multi-foto (thumbnail, swipe HP, keyboard ← →, klik untuk lightbox zoom/drag), deskripsi lengkap, pilihan paket dengan harga diskon.
- **Lightbox**: zoom scroll wheel, drag pan, navigasi ‹ › / panah keyboard, counter foto.
- **Harga fleksibel**: mode beli sekali atau sewa 1/3/12 bulan, diskon otomatis (harga coret).
- **Checkout multi-metode**:
  - **QRIS** untuk pembeli IDR (gambar QRIS bisa diatur admin).
  - **Internasional** untuk USD: PayPal, Wise, USDT (TRC20), Bank Transfer — link diatur admin, support copy alamat.
- **Order tracking otomatis**: setiap klik konfirmasi WA mencatat order ke tabel `orders` (produk, paket, harga, mata uang, metode bayar).
- **i18n ID/EN**: toggle bahasa + auto-deteksi browser, seluruh teks ikut berganti.
- **Mata uang otomatis**: ID → Rupiah, EN → USD dengan kurs live (refresh 1 jam).
- **Kalkulator profit compounding** real-time.
- **Form Custom EA/Indicator**: request jasa development via WhatsApp (dengan honeypot anti-spam).
- **Ticker harga pasar live** (Yahoo Finance, dengan fallback data).
- **Badge hero rotatif**: "New Order" berganti tiap 10 menit, "Today's Profit" tiap 30 menit.
- **Pengaturan dinamis dari admin**: nomor WA, teks promo ID/EN, gambar QRIS — tanpa edit kode.
- Animasi: aurora background, particle, typing effect, counter, marquee testimoni, scroll reveal, confetti.

### Admin (`admin.html`)
- Login via Supabase Auth.
- CRUD produk: nama, kategori, platform, deskripsi, diskon %, harga beli + sewa.
- **Pilihan mata uang IDR/USD** — input USD otomatis dikonversi ke IDR via kurs live.
- Upload **multi-gambar** ke Supabase Storage (foto pertama = cover).
- Tabel produk dengan **search, filter kategori, dan sorting** (nama, harga, tanggal).
- **Pengaturan umum**: nomor WhatsApp, teks promo (ID & EN), gambar QRIS.
- **Pengaturan pembayaran internasional**: link PayPal, Wise, USDT, Bank.
- **Manajemen Orders**: lihat semua order masuk, update status (pending/paid/delivered/cancelled).

## Tech Stack
- HTML + Tailwind CSS (CDN browser v4)
- [Supabase](https://supabase.com) JS v2 — database, auth, storage
- Vanilla JavaScript (tanpa build step)

## Setup

### 1. Supabase Project
1. Buat project di [supabase.com](https://supabase.com).
2. Jalankan `schema.sql` di **SQL Editor** — membuat tabel `products`, `settings`, `orders` + RLS policies + storage policies.
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
- Isi **Pengaturan Umum** (WA, promo, QRIS) dan **Link Pembayaran** (PayPal/Wise/USDT/Bank) agar checkout internasional aktif.

## Struktur File

```
├── index.html      # Toko / katalog publik
├── admin.html      # Panel admin (login + CRUD + settings + orders)
├── schema.sql      # Skema database + RLS policies
├── supabase.txt    # Kredensial (DI-GITIGNORE, jangan di-push)
├── Qris.jpg        # Gambar QRIS default
├── logo.png        # Logo DagangDuit
├── favicon.ico     # Favicon
├── .github/
│   └── workflows/
│       └── keep-alive.yml  # Cron harian anti-pause Supabase free tier
└── README.md
```

## Skema Database

### `products`
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

### `settings` (key-value, dikelola admin)
| Key | Keterangan |
|---|---|
| `wa_number` | Nomor WhatsApp admin (format 62xxx) |
| `promo_id` / `promo_en` | Teks promo bar bahasa Indonesia / Inggris |
| `qris_img` | URL gambar QRIS |
| `pay_paypal` / `pay_wise` / `pay_usdt` / `pay_bank` | Link/akun pembayaran internasional |

### `orders`
| Kolom | Keterangan |
|---|---|
| `product_id` / `product_name` | Produk yang diorder |
| `plan_label` | Paket (Beli / Sewa 1/3/12 Bulan) |
| `price` / `currency` | Harga dalam mata uang yang ditampilkan |
| `pay_method` | `QRIS` / `International` |
| `buyer_name` / `buyer_wa` | Data pembeli (opsional) |
| `status` | `pending` / `paid` / `delivered` / `cancelled` |
| `created_at` | Waktu order |

> Semua harga produk disimpan dalam **IDR**. Konversi USD↔IDR dilakukan di frontend/admin via kurs live.

## Keep-Alive Supabase Free Tier

Supabase free tier pause otomatis setelah ~7 hari tanpa aktivitas. Dua opsi penjagaan:

- **GitHub Actions** (`.github/workflows/keep-alive.yml`): cron harian ping REST API. Butuh secrets `SUPABASE_URL` & `SUPABASE_ANON_KEY` di repo Settings → Secrets. Catatan: akun GitHub harus bebas billing issue.
- **cron-job.org** (alternatif): buat cronjob harian ke `https://<project>.supabase.co/rest/v1/products?select=id&limit=1` dengan header `apikey` + `Authorization: Bearer <anon_key>`.

## Keamanan
- `supabase.txt` berisi kredensial — **sudah di-gitignore**, jangan pernah di-commit.
- Hanya **anon/publishable key** yang ada di client-side (memang public-by-design); perlindungan data via **RLS policies**.
- Jangan pernah menaruh **service_role key** di file HTML/JS manapun.

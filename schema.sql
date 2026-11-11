-- 1. Buat tabel produk jika belum ada
create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  price       numeric(12, 2) not null check (price >= 0),
  price_1m    numeric(12, 2) check (price_1m is null or price_1m >= 0),
  price_3m    numeric(12, 2) check (price_3m is null or price_3m >= 0),
  price_12m   numeric(12, 2) check (price_12m is null or price_12m >= 0),
  description text default '',
  platform    text default 'MT5',
  category    text default 'EA' check (category in ('EA', 'Indicator')),
  image_url   text default '',
  images      jsonb not null default '[]'::jsonb,
  discount_percent numeric(5, 2) not null default 0 check (discount_percent >= 0 and discount_percent <= 100),
  created_at  timestamptz not null default now()
);

-- Migrasi untuk tabel yang sudah ada (jalankan sekali, aman diulang)
alter table public.products add column if not exists price_1m  numeric(12, 2);
alter table public.products add column if not exists price_3m  numeric(12, 2);
alter table public.products add column if not exists price_12m numeric(12, 2);
alter table public.products add column if not exists category text default 'EA';
alter table public.products add column if not exists images   jsonb not null default '[]'::jsonb;
alter table public.products add column if not exists discount_percent numeric(5, 2) not null default 0;

-- 2. Aktifkan Row Level Security
alter table public.products enable row level security;

-- 3. Hapus policy lama jika sudah ada (untuk mencegah error 42710)
drop policy if exists "Public can read products" on public.products;
drop policy if exists "Authenticated can insert products" on public.products;
drop policy if exists "Authenticated can update products" on public.products;
drop policy if exists "Authenticated can delete products" on public.products;

-- 4. Buat ulang policy dengan bersih
create policy "Public can read products"
  on public.products for select
  using (true);

create policy "Authenticated can insert products"
  on public.products for insert
  to authenticated
  with check (true);

create policy "Authenticated can update products"
  on public.products for update
  to authenticated
  using (true)
  with check (true);

create policy "Authenticated can delete products"
  on public.products for delete
  to authenticated
  using (true);

-- ============================================================
-- 5. STORAGE: bucket 'product-images'
--    Buat manual dulu di Dashboard Supabase:
--    Storage → New bucket → nama: product-images → Public: ON
--    Lalu jalankan policy di bawah:
-- ============================================================

drop policy if exists "Public can view product images" on storage.objects;
drop policy if exists "Authenticated can upload product images" on storage.objects;
drop policy if exists "Authenticated can delete product images" on storage.objects;

create policy "Public can view product images"
  on storage.objects for select
  using (bucket_id = 'product-images');

create policy "Authenticated can upload product images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'product-images');

create policy "Authenticated can delete product images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'product-images');

-- ============================================================
-- 6. SETTINGS: key-value untuk konfigurasi (payment links, dll)
-- ============================================================
create table if not exists public.settings (
  key   text primary key,
  value text not null default ''
);

alter table public.settings enable row level security;

drop policy if exists "Public can read settings" on public.settings;
drop policy if exists "Authenticated can manage settings" on public.settings;

create policy "Public can read settings"
  on public.settings for select
  using (true);

create policy "Authenticated can manage settings"
  on public.settings for all
  to authenticated
  using (true)
  with check (true);

-- ============================================================
-- 7. ORDERS: pesanan masuk dari checkout (konfirmasi WA)
-- ============================================================
create table if not exists public.orders (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid references public.products(id) on delete set null,
  product_name text not null,
  plan_label   text not null,
  price        numeric(12, 2) not null,
  currency     text not null default 'IDR',
  pay_method   text not null default 'QRIS',
  buyer_name   text not null,
  buyer_wa     text not null,
  status       text not null default 'pending' check (status in ('pending','paid','done','cancelled')),
  created_at   timestamptz not null default now()
);

alter table public.orders enable row level security;

drop policy if exists "Anyone can create order" on public.orders;
drop policy if exists "Authenticated can read orders" on public.orders;
drop policy if exists "Authenticated can update orders" on public.orders;
drop policy if exists "Authenticated can delete orders" on public.orders;

create policy "Anyone can create order"
  on public.orders for insert
  with check (true);

create policy "Authenticated can read orders"
  on public.orders for select
  to authenticated
  using (true);

create policy "Authenticated can update orders"
  on public.orders for update
  to authenticated
  using (true)
  with check (true);

create policy "Authenticated can delete orders"
  on public.orders for delete
  to authenticated
  using (true);

-- ============================================================
-- 8. ORDER FEED PUBLIK (untuk badge hero di index.html)
--    Hanya mengekspos nama pembeli + produk — TANPA buyer_wa.
-- ============================================================
create or replace view public.order_feed as
  select buyer_name, product_name
  from public.orders
  where status <> 'cancelled'
  order by created_at desc
  limit 20;

grant select on public.order_feed to anon, authenticated;

notify pgrst, 'reload schema';
-- ZyvoMart Database Schema
-- Run this script in Supabase SQL Editor.

create extension if not exists pgcrypto;

-- Product catalog: customers can access only public product fields.
create table if not exists public.products (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    description text not null default '',
    image_url text not null default '',
    category text not null default 'Other',
    purchase_cost numeric(12,2) not null default 0
        check (purchase_cost >= 0),
    selling_price numeric(12,2) not null
        check (selling_price >= 0),
    stock integer not null default 0
        check (stock >= 0),
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Orders: customer identity and delivery details.
create table if not exists public.orders (
    id uuid primary key default gen_random_uuid(),
    customer_id uuid not null references auth.users(id),
    customer_name text not null,
    customer_email text not null,
    phone text not null,
    address text not null,
    city text not null,
    state text not null,
    postal_code text not null,
    payment_method text not null default 'COD'
        check (payment_method = 'COD'),
    payment_status text not null default 'pending'
        check (payment_status in ('pending', 'paid', 'refunded')),
    order_status text not null default 'placed'
        check (order_status in (
            'placed', 'confirmed', 'shipped',
            'delivered', 'cancelled'
        )),
    subtotal numeric(12,2) not null check (subtotal >= 0),
    delivery_charge numeric(12,2) not null default 0
        check (delivery_charge = 0),
    total numeric(12,2) not null check (total >= 0),
    created_at timestamptz not null default now()
);

create table if not exists public.order_items (
    id uuid primary key default gen_random_uuid(),
    order_id uuid not null references public.orders(id)
        on delete cascade,
    product_id uuid not null references public.products(id),
    product_title text not null,
    quantity integer not null check (quantity > 0),
    unit_price numeric(12,2) not null check (unit_price >= 0),
    line_total numeric(12,2) not null check (line_total >= 0)
);

-- Enable Row Level Security.
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Remove broad table access. Access will be granted through
-- carefully defined policies and server-side order functions.
revoke all on public.products from anon, authenticated;
revoke all on public.orders from anon, authenticated;
revoke all on public.order_items from anon, authenticated;

-- Public catalog view intentionally excludes purchase_cost.
create or replace view public.store_products
with (security_invoker = false)
as
select
    id,
    title,
    description,
    image_url,
    category,
    selling_price,
    stock,
    active,
    created_at
from public.products
where active = true;

revoke all on public.store_products from public;
grant select on public.store_products to anon, authenticated;

-- Admin identity is configured separately using a protected
-- server-side check. Do not grant customers direct table access.

-- IMPORTANT:
-- This schema alone does NOT implement checkout or admin writes.
-- Add a server-validated order function and an admin-only
-- server-side product-management function before going live.

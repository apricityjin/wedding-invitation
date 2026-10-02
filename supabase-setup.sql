-- ============================================================
-- 婚礼邀请函 Supabase 初始化脚本
-- 使用方法：Supabase Dashboard → SQL Editor → 新建查询 → 整段粘贴执行
-- 执行后还需：Authentication → Users → Add User 创建主人账号（邮箱+密码）
-- ============================================================

-- 1. 祝福墙：所有人可读可写，仅主人（登录用户）可删
create table if not exists public.wishes (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 20),
  text text not null check (char_length(text) between 1 and 200),
  created_at timestamptz not null default now()
);
alter table public.wishes enable row level security;

create policy "wishes_select_all" on public.wishes
  for select to anon, authenticated using (true);
create policy "wishes_insert_all" on public.wishes
  for insert to anon, authenticated with check (true);
create policy "wishes_delete_host" on public.wishes
  for delete to authenticated using (true);

-- 2. 出席回执：所有人可提交，仅主人可查看/删除（含手机号，必须保护）
create table if not exists public.rsvp (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 20),
  guests smallint not null check (guests between 0 and 5),
  phone text not null check (phone ~ '^1[3-9][0-9]{9}$'),
  wish text check (wish is null or char_length(wish) <= 200),
  created_at timestamptz not null default now()
);
alter table public.rsvp enable row level security;

create policy "rsvp_insert_all" on public.rsvp
  for insert to anon, authenticated with check (true);
create policy "rsvp_select_host" on public.rsvp
  for select to authenticated using (true);
create policy "rsvp_delete_host" on public.rsvp
  for delete to authenticated using (true);

-- 3. 照片元数据：所有人可读，仅主人可增删（文件本体在 Storage）
create table if not exists public.photos (
  id bigint generated always as identity primary key,
  path text not null unique,
  created_at timestamptz not null default now()
);
alter table public.photos enable row level security;

create policy "photos_select_all" on public.photos
  for select to anon, authenticated using (true);
create policy "photos_insert_host" on public.photos
  for insert to authenticated with check (true);
create policy "photos_delete_host" on public.photos
  for delete to authenticated using (true);

-- 4. 设置表（当前用于自定义封面）：所有人可读，仅主人可写
create table if not exists public.settings (
  key text primary key,
  value text not null
);
alter table public.settings enable row level security;

create policy "settings_select_all" on public.settings
  for select to anon, authenticated using (true);
create policy "settings_insert_host" on public.settings
  for insert to authenticated with check (true);
create policy "settings_update_host" on public.settings
  for update to authenticated using (true) with check (true);
create policy "settings_delete_host" on public.settings
  for delete to authenticated using (true);

-- 5. 存储桶 photos：公开可读，仅主人可上传/覆盖/删除
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

create policy "storage_select_all" on storage.objects
  for select to anon, authenticated using (bucket_id = 'photos');
create policy "storage_insert_host" on storage.objects
  for insert to authenticated with check (bucket_id = 'photos');
create policy "storage_update_host" on storage.objects
  for update to authenticated
  using (bucket_id = 'photos') with check (bucket_id = 'photos');
create policy "storage_delete_host" on storage.objects
  for delete to authenticated using (bucket_id = 'photos');

-- 6. 显式授权（默认权限通常已覆盖，显式声明以防 Data API 设置关闭了新表自动暴露）
grant select, insert, delete on public.wishes to anon, authenticated;
grant insert on public.rsvp to anon;
grant select, insert, delete on public.rsvp to authenticated;
grant select on public.photos to anon;
grant select, insert, delete on public.photos to authenticated;
grant select on public.settings to anon;
grant select, insert, update, delete on public.settings to authenticated;

-- ============================================================
-- 主人账号创建（在 Dashboard 操作，不在此脚本内）：
--   Authentication → Users → Add User → Create new user
--   填邮箱和密码，勾选 Auto Confirm User
-- 前端用这个邮箱密码登录后即为主人态（authenticated 角色）。
-- ============================================================

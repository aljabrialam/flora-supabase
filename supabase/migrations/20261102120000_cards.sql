create table public.cards (
  id text primary key check (char_length(id) = 10),
  data jsonb not null,                -- bouquet, message, stickers, names
  photo_path text,
  reply_to text references public.cards(id),
  created_at timestamptz default now(),
  opened_at timestamptz
);
alter table public.cards enable row level security;
-- anyone may create a card; nobody may list or read the table directly
create policy "insert cards" on public.cards for insert to anon with check (octet_length(data::text) < 20000);

-- read one card by id only (no listing)
create or replace function public.get_card(p_id text) returns public.cards
language sql security definer set search_path = public as
$$ select * from public.cards where id = p_id $$;

-- mark opened once
create or replace function public.mark_opened(p_id text) returns void
language sql security definer set search_path = public as
$$ update public.cards set opened_at = now() where id = p_id and opened_at is null $$;

-- sender checks status of their own ids
create or replace function public.card_status(p_ids text[]) returns table(id text, opened_at timestamptz)
language sql security definer set search_path = public as
$$ select id, opened_at from public.cards where id = any(p_ids) limit 20 $$;

grant execute on function public.get_card, public.mark_opened, public.card_status to anon;

-- storage: public bucket "card-photos" (unguessable paths), uploads only
insert into storage.buckets (id, name, public) values ('card-photos','card-photos', true);
create policy "upload photos" on storage.objects for insert to anon
  with check (bucket_id = 'card-photos' and (storage.extension(name) = 'jpg'));

-- keep photos small and JPEG only
update storage.buckets set file_size_limit = 1572864, allowed_mime_types = '{image/jpeg}' where id = 'card-photos';

-- ============================================================================
-- 0002_storage_avatars.sql · bucket público de avatares + policies
-- Separado da 0001 de propósito: mexe em objetos do Supabase Storage, não em
-- tabelas nossas. Se o `supabase db push` reclamar de permissão aqui (owner do
-- storage.objects), rode este arquivo no SQL Editor do dashboard e marque a
-- migração como aplicada com `supabase migration repair --status applied 0002`.
-- ============================================================================

-- Bucket público: a URL do avatar é lida sem token (perfil é público por definição).
-- 2 MB e só imagem; o app redimensiona antes de subir.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Caminho obrigatório: <uid>/<arquivo>. A primeira pasta é o dono.
-- Qualquer logado lê (bucket público); só o dono grava, troca e apaga na própria pasta.
create policy "avatars: leitura pública" on storage.objects
  for select to authenticated, anon
  using (bucket_id = 'avatars');

create policy "avatars: subir na minha pasta" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars: trocar na minha pasta" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars: apagar na minha pasta" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

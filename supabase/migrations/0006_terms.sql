-- Fase 08 · aceite dos termos no cadastro (política de conteúdo gerado por
-- usuário da Google Play: o app precisa registrar que a pessoa aceitou os
-- termos de uso e a política de privacidade).
--
-- O app grava `terms_accepted_at = now()` no passo 1 do onboarding (a caixa
-- "Li e aceito…" é obrigatória para continuar). Quem entra pelo Google passa
-- pelo mesmo passo, então a coluna vale para os dois caminhos. A policy
-- "profiles: editar só o próprio" (0001) já cobre a escrita: só o dono.
alter table public.profiles
  add column if not exists terms_accepted_at timestamptz;

comment on column public.profiles.terms_accepted_at is
  'Quando a pessoa aceitou os termos e a política (passo 1 do onboarding). Null = conta criada antes da fase 08 ou aceite pendente.';

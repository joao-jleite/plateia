# Pendências do João

Tudo o que só você pode fazer (contas, chaves, celular, dinheiro). Cada fase acrescenta aqui; marque `[x]` quando fizer. Chaves vão em `research/.env` (fase 01) ou em `supabase secrets set` (fase 03+), nunca no chat.

## Fase 01 · Validar APIs

- [ ] **Chave do TMDB** (grátis, ~5 min). Destrava os números do TMDB na tabela de `docs/decisoes-apis.md` e todo o catálogo da fase 03.
  1. Criar conta em https://www.themoviedb.org/signup e confirmar o e-mail.
  2. Em https://www.themoviedb.org/settings/api pedir uma chave "Developer" (tipo de uso: app pessoal/educacional por enquanto; URL pode ser o GitHub).
  3. Copiar o **API Read Access Token** (o longo, começa com `eyJ`) e colar em `research/.env` como `TMDB_API_KEY=`.
- [ ] **Chave da Streaming Availability (Movie of the Night) via RapidAPI** (grátis, 1.000 req/mês). Destrava os deep links.
  1. Conta em https://rapidapi.com (pode entrar com GitHub/Google).
  2. Abrir https://rapidapi.com/movie-of-the-night-movie-of-the-night-default/api/streaming-availability/pricing e assinar o plano **Free** (pede cartão? se pedir, prefira a alternativa abaixo).
  3. Copiar a `X-RapidAPI-Key` (aba Endpoints, canto direito) para `research/.env` como `RAPIDAPI_KEY=`.
  - Alternativa sem RapidAPI: chave direta em https://developers.movieofthenight.com (header `X-API-Key`, base `https://api.movieofthenight.com/v4`). Se escolher essa, avise na próxima fase que o script 03 precisa trocar o header e a base.
- [ ] **Chave da Watchmode** (grátis, 2.500 créditos/mês). Só para fechar a tabela comparativa; a fonte já foi descartada, então é opcional.
  1. https://api.watchmode.com → "Get a free API key" → confirmar e-mail.
  2. Colar em `research/.env` como `WATCHMODE_API_KEY=`.
- [ ] **Rodar a pesquisa com as chaves**: PowerShell em `research\` → `.\run_all.ps1`. Gasta ~40 chamadas TMDB, ~44 créditos Watchmode, ~21 req MOTN. Depois me mande "roda a fase 01 de novo" para eu atualizar os números no documento.
- [ ] **CSV da Netflix**: no navegador, Conta → Perfis → seu perfil → *Atividade de visualização* → rolar até o fim → "Baixar tudo". Salvar como `research/NetflixViewingHistory.csv` (está no `.gitignore`). Destrava o formato real para a fase 05.
- [ ] **Testar no celular se o link abre o app** (2 min, com os apps instalados). Mande cada URL para você mesmo no Telegram/WhatsApp e toque:
  - Netflix: `https://www.netflix.com/search?q=stranger%20things`
  - HBO Max: `https://play.hbomax.com/search?q=the%20last%20of%20us`
  - Prime Video: `https://www.primevideo.com/search?phrase=the%20boys`
  - Globoplay: `https://globoplay.globo.com/busca/?q=arcanjo%20renegado`
  - Apple TV: `https://tv.apple.com/br/search?term=ruptura`
  - Paramount+: `https://www.paramountplus.com/br/search/?q=yellowstone`
  - Crunchyroll: `https://www.crunchyroll.com/pt-br/search?q=frieren`
  - Disney+ (não tem busca): `https://www.disneyplus.com/pt-br` só para ver se abre o app.
  Anote quais abriram o **app** e quais abriram o **navegador**; isso define o texto do botão na fase 03.

## Para as próximas fases (já dá para adiantar)

- [ ] **Supabase**: criar projeto (região `sa-east-1`, São Paulo) em https://supabase.com/dashboard; anotar URL e `anon key` (vão no app) e guardar a `service_role` (nunca no app). Fase 03.
- [ ] **Google Cloud**: projeto + credencial OAuth "Android" (SHA-1 da keystore de debug e, depois, da release) para o login Google do Supabase Auth. Fase 03/04.
- [ ] **Conta Google Play Console** (US$ 25 uma vez) e **keystore de release** (guardar senha fora do git). Fase 08.
- [ ] **Antes de cobrar qualquer coisa ou colocar anúncio**: pedir licença comercial do TMDB (e-mail para `sales@themoviedb.org`, assunto "Commercial API Use", informando o país) e assinar o Starter da Streaming Availability (US$ 49/mês). Fase 08.
- [ ] **Decidir preço** do plano premium (se houver). Fase 07/08.

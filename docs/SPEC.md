# SPEC · Plateia (codinome) · MVP Android

> **Status: aprovado por procuração em 2026-10-22.** O João deu liberdade total para rodar as 8 fases sem aprovação por etapa; esta spec vale como aprovada até ele dizer o contrário. O que mais merece a leitura dele (10 minutos) está marcado com **▶** e repetido em `docs/PENDENCIAS-JOAO.md`:
> ▶ nome do pacote Android (`io.github.joaojleite.watchlog`, §5.1) · ▶ uma linha por título no diário (§5.2) · ▶ perfil privado esconde o conteúdo, não o cartão (§5.3) · ▶ o que entra no feed (§5.5) · ▶ preços dos streamings vêm como estimativa (§5.9).

Fonte das decisões de API: `docs/decisoes-apis.md` (fase 01). Arquitetura e banco: `docs/ARQUITETURA.md` e `supabase/migrations/0001_init.sql`.

## 1. O produto em um parágrafo

App Android, em português, para registrar o que você assiste em qualquer streaming (filmes, séries e anime no mesmo lugar), dar nota, escrever review, montar listas e ver o que os amigos estão assistindo. Para cada título ele mostra **onde está no Brasil** e tem um botão que **abre o app oficial** do streaming. Com base no que você quer ver, diz **qual streaming vale assinar este mês**. Ele **não toca vídeo**, não entra na sua conta de streaming e não guarda o CSV da Netflix: lê, casa com o catálogo e descarta.

## 2. Personas

**Camila, 27, Embu das Artes.** Assina Netflix e Prime, alterna HBO Max e Disney+ conforme a série do momento, assiste anime na Crunchyroll. Cansou de abrir quatro apps para descobrir onde está "aquela série que a amiga indicou" e de pagar streaming que não usa no mês. Quer: registrar rápido, saber onde está, saber o que cancelar.

**Rafael, 34, São Paulo.** Usou Letterboxd por anos, mas em inglês e só para filmes; as séries ficavam numa nota do celular. Gosta de ranquear, escrever três linhas sobre cada coisa e comparar notas com os amigos. Quer: séries e filmes juntos, em português, perfil que dê orgulho de mostrar, importar o histórico antigo para o perfil não nascer vazio.

## 3. As cinco jornadas do MVP

Cada passo diz a tela (§4) e a tabela que toca (§8).

### J1 · Cadastro, importação da Netflix e um perfil que já nasce cheio
1. **Entrar** (`/login`): e-mail + senha ou Google. Supabase Auth cria o usuário; um trigger cria o `profile` com @ provisório.
2. **Escolher @** (`/onboarding/username`): 3–20 caracteres, minúsculas, dígitos e `_`, único. Nome de exibição e foto opcionais (Google já preenche).
3. **Importar a Netflix** (`/onboarding/import`): "Baixe seu histórico em Conta → Perfis → Atividade de visualização → Baixar tudo e escolha o arquivo." Botão "Agora não".
4. O app lê o CSV **no aparelho**, agrupa por série/filme, manda só os nomes para a Edge Function `import-match`, recebe os casamentos e grava os de alta confiança como "Assisti" (`entries`, `source = netflix_import`). Mostra progresso ("312 títulos, 9 para revisar").
5. **Revisar duvidosos** (`/import/review`): 2–3 candidatos por item, "nenhum destes" pula. Pode fazer depois pelo perfil.
6. **Seguir alguém** (`/onboarding/follow`): busca por @ ou "compartilhar meu perfil"; pular é permitido.
7. Perfil (`/profile/:username`) já mostra grade de pôsteres e estatísticas. `onboarded_at` é preenchido.

### J2 · Buscar um título, ver onde está e abrir o app do streaming
1. **Buscar** (`/search`): digita, resultados em pt-BR com pôster, ano, tipo (filme/série/anime). Vem da Edge Function `catalog-search` (TMDB), sem gravar nada.
2. **Detalhe** (`/title/:type/:tmdbId`): pôster, sinopse, elenco, temporadas, nota dos amigos. A Edge Function `catalog-title` grava/renova o cache (`titles`, `title_availability`, `title_sync`).
3. Seção **Onde assistir**: um cartão por streaming, assinatura primeiro, depois grátis/com anúncios, depois aluguel e compra. Logo do streaming + botão. Texto discreto "Dados: TMDB · JustWatch" (atribuição obrigatória).
4. **Botão**: "Abrir na Netflix" quando há link direto; "Buscar na Netflix" quando só há busca; "Abrir o Disney+" quando nem busca existe; último recurso "Ver na JustWatch". O Android abre o app oficial (App Links) ou o site se não estiver instalado.
5. Abrir o mesmo título de novo em até 7 dias não chama API externa.

### J3 · Registrar "assisti / quero ver / assistindo", com nota e review
1. No detalhe, botão grande **Registrar** abre uma folha (`sheet`) com três estados: **Assisti**, **Assistindo**, **Quero ver**. Um toque marca; segundo toque no mesmo estado desmarca.
2. Com Assisti/Assistindo aparecem: nota em meias estrelas (0,5–5), data (padrão hoje), review (até 5.000 caracteres) e a chave "contém spoiler". Em série, temporada e episódio atuais.
3. Salvar grava **uma linha** em `entries` por (usuário, título). Reassistir aumenta `watch_count` e atualiza a data. A interface atualiza na hora e desfaz com aviso se o servidor recusar.
4. Um trigger cria a atividade do feed (§5.5). "Quero ver" não gera atividade.
5. **Adicionar à lista** na mesma folha: escolhe ou cria uma lista (`lists`, `list_items`).

### J4 · Seguir amigos e ver o feed deles
1. **Encontrar** (`/search/users`, link de convite `/u/:username`, botão compartilhar do perfil).
2. **Seguir**: perfil público aceita na hora; perfil privado vira pedido. O seguido recebe notificação in-app.
3. **Feed** (`/feed`): atividades de quem eu sigo, mais novas primeiro. Cada item: avatar, "@ana assistiu *The Bear* ★★★★½", pôster, review (borrada se spoiler), contadores de curtidas e comentários.
4. **Curtir e comentar** (`/activity/:id`). Comentário também pode ter spoiler.
5. **Assistindo agora**: faixa no topo do feed com os check-ins ativos dos amigos (expiram em 3 h).
6. **Bloquear ou denunciar** no menu do perfil, da review e do comentário.
7. **Notificações** (`/notifications`): seguiu você, pediu para seguir, aceitou, curtiu, comentou.

### J5 · Ver "qual streaming assinar este mês"
1. Aba **Assinar** (`/subscribe`). Fonte: meu "Quero ver" e "Assistindo" (peso 1) e títulos que amigos que eu sigo assistiram ou avaliaram com ≥ 4 nos últimos 30 dias e não estão no meu diário (peso 0,3).
2. Para cada streaming destacado: quantos títulos ele resolve (só assinatura, com ou sem anúncios), preço do plano, custo por título, o que fica de fora.
3. Resposta em uma frase: "Este mês, assine a **HBO Max**: resolve 8 dos seus 12 títulos por R$ 39,90". Combinação de dois só se o segundo acrescentar ≥ 3 títulos e o custo por título da dupla for menor que o do primeiro sozinho.
4. "Preços de 22/10/2026 · estimativa" sempre visível, com a data de `provider_prices.updated_at`.
5. **Meus streamings**: marcar o que assino e a data de renovação (`user_subscriptions`). O app calcula a economia anual (assinar um por mês × 12 contra tudo o que marquei) e agenda uma notificação local 3 dias antes de cada renovação.
6. Título sem disponibilidade em cache aparece como "sem dados", nunca como chute.

## 4. Mapa de telas

Shell com barra inferior de 5 abas. Entre parênteses, a fase que entrega.

| Aba / rota | O que tem | Fase |
|---|---|---|
| `/login`, `/signup`, `/reset` | e-mail + senha, Google, recuperar senha | 03 |
| `/onboarding/username` → `/onboarding/import` → `/onboarding/follow` | §J1 | 03 · 05 · 06 |
| **Início** `/home` | em alta no Brasil; novidades por streaming (8 destacados); faixa "assistindo agora" dos amigos | 03 · 06 |
| **Buscar** `/search`, `/search/users` | títulos (TMDB) e pessoas (@) | 03 · 06 |
| `/title/:type/:tmdbId` | detalhe, onde assistir, folha Registrar, adicionar à lista | 03 · 04 |
| **Feed** `/feed`, `/activity/:id` | atividades, curtidas, comentários | 06 |
| **Assinar** `/subscribe`, `/subscribe/mine` | recomendação, meus streamings, lembretes | 07 |
| **Perfil** `/profile/:username` (+ `/diary`, `/watchlist`, `/lists`, `/reviews`, `/followers`, `/following`, `/stats`) | grade de pôsteres, abas, estatísticas (horas, por streaming, gênero, ano) | 04 |
| `/list/:id` | lista, ordenação, ranqueada | 04 |
| `/import`, `/import/review` | importar CSV, revisar duvidosos | 05 |
| `/notifications` | in-app | 06 |
| `/settings` (+ `/privacy`, `/blocked`, `/account`) | perfil privado, bloqueados, apagar conta, sobre e atribuições | 04 · 06 · 08 |
| `/u/:username` | link de convite (abre o perfil) | 06 |

Até a fase 06 a aba Feed mostra um estado vazio "em breve"; até a 07, a aba Assinar também. Estados de carregando, vazio e erro em toda tela (convenção do `CLAUDE.md`).

## 5. Regras de negócio

### 5.1 Conta e identidade
- Login por e-mail/senha ou Google (Supabase Auth). Sem login não se vê nada: o app é só para gente logada (o role `anon` do banco não tem privilégio nenhum).
- `@username`: `^[a-z0-9_]{3,20}$`, único, trocável quando quiser (links antigos quebram; aceito no MVP).
- **▶ Pacote Android: `io.github.joaojleite.watchlog`.** Neutro quanto ao nome do produto (Plateia é codinome), no padrão do GitHub do João (`joao-jleite`, sem domínio próprio), imutável na Play Store. Nome visível do app é só um rótulo (`android:label`) e pode mudar.
- Apagar a conta: em Configurações, com confirmação; apaga `auth.users` e, em cascata, tudo que é da pessoa (exigência da Play para apps com cadastro).

### 5.2 Diário
- **▶ Uma linha por (usuário, título)** em `entries`. O `status` é o estado atual: `watched` (assisti), `watching` (assistindo), `want` (quero ver). Reassistir incrementa `watch_count` e atualiza `watched_at`. Diário por episódio e várias "sessões" do mesmo filme ficam para depois (§6).
- Nota: 0,5 a 5 em **meias estrelas**, opcional, só com `watched` ou `watching`. Review: até 5.000 caracteres, opcional, só com `watched` ou `watching`. "Quero ver" não tem nota nem review (restrição no banco).
- Séries: `current_season`/`current_episode` quando assistindo; `episodes_watched` alimenta horas assistidas (episódios × duração média do TMDB). Filmes: `runtime_minutes`.
- Importação grava `source = netflix_import`; edição manual depois não muda a origem, mas uma reimportação **nunca** sobrescreve nota, review ou status que a pessoa alterou à mão.
- Estatísticas do perfil (horas, por streaming, por gênero, por ano) são calculadas a partir de `entries` + `titles` + `title_availability`; "por streaming" usa onde o título está hoje (não onde foi visto).

### 5.3 Privacidade do perfil
- Perfil nasce **público**. A pessoa pode torná-lo **privado** em Configurações.
- **▶ Privado esconde o conteúdo, não o cartão.** Username, nome, foto, bio e contadores continuam visíveis a qualquer pessoa logada, para que dê para encontrar o perfil e pedir para seguir. Diário, listas, atividades e check-ins só aparecem para seguidores aceitos.
- Seguir perfil público: aceito na hora. Seguir perfil privado: vira pedido (`follows.status = pending`); o dono aceita ou recusa. O cliente não escolhe o status: um trigger decide.
- Virar público aceita automaticamente os pedidos pendentes. Virar privado mantém os seguidores atuais.
- Lista tem privacidade própria: lista **privada** só o dono vê (nem seguidor); lista pública segue a privacidade do perfil.
- Sempre só do dono, independente de privacidade: streamings assinados, importações, candidatos de revisão, notificações, denúncias feitas.
- A lista "seguindo" de um perfil privado é conteúdo dele. Consequência: na lista de seguidores de alguém, um seguidor de perfil privado que você não segue não aparece (o contador, sim).

### 5.4 Bloqueio
- Bloquear vale **nos dois sentidos** e no banco (RLS), não só na interface: nenhum dos dois vê perfil, diário, listas, atividades, curtidas, comentários ou notificações do outro, nem o encontra na busca.
- Bloquear desfaz follows e pedidos nos dois sentidos e apaga as notificações entre os dois. Desbloquear não refaz nada.
- O bloqueado não é avisado nem consegue descobrir (não lê `blocks`). Quem bloqueou vê a própria lista em Configurações → Bloqueados.

### 5.5 Feed
- **▶ Entra no feed:** marcou assistido, deu nota, escreveu review, começou a assistir (status assistindo), criou lista pública, importou histórico (um evento só: "importou 312 títulos da Netflix").
- **Não entra:** quero ver, lista privada, edições que não mudam nota/review/status, assinaturas, check-ins (eles têm a faixa própria).
- Um evento por mudança, escolhendo o mais significativo (review > nota > status). Editar a mesma coisa de novo em até 1 hora atualiza o evento em vez de criar outro (regra no trigger). O cliente ainda agrupa visualmente eventos consecutivos da mesma pessoa no mesmo dia ("assistiu 4 títulos hoje").
- Ordem: cronológica inversa, sem algoritmo. Quem aparece: quem eu sigo (aceito) e eu.
- Atividades são criadas **só por trigger**; cliente não insere nem edita (não dá para forjar). O autor pode apagar uma atividade sua.
- Curtidas e comentários pertencem à atividade. O dono da atividade pode apagar comentário alheio nela.

### 5.6 Spoiler
- Review e comentário têm a chave "contém spoiler". Com ela ligada o texto aparece **borrado** no feed, no detalhe do título e no perfil até a pessoa tocar ("mostrar spoiler"). A nota nunca é escondida.
- Spoiler não marcado é motivo de denúncia (`reason = spoiler`).

### 5.7 Onde assistir e o botão do streaming
- "Onde está" vem do TMDB `watch/providers` (região BR, dados da JustWatch). "Link que abre o app" vem da Streaming Availability (Movie of the Night). Decisão da fase 01; não reabrir.
- Tipos exibidos, nesta ordem: assinatura (`flatrate`), com anúncios (`ads`), grátis (`free`), aluguel (`rent`), compra (`buy`). Aluguel e compra mostram o preço quando a fonte informa.
- Texto do botão: **"Abrir na Netflix"** (há `deep_link`) · **"Buscar na Netflix"** (sem link; URL de busca no domínio verificado por assetlinks) · **"Abrir o Disney+"** (sem busca: abre o pacote `com.disney.disneyplus` ou a Play Store) · **"Ver na JustWatch"** (último recurso, link do TMDB). Nunca prometer "abrir" quando só há busca.
- HBO Max usa sempre `play.hbomax.com`. Globoplay só tem busca (nenhuma fonte dá o id do título lá).
- Atribuição visível na seção: logo do TMDB + "Este produto usa a API do TMDB, mas não é endossado nem certificado pelo TMDB" (na tela Sobre) e "Onde assistir: dados da JustWatch via TMDB" ao lado da lista. Logos dos streamings só para indicar onde o título está.
- Cache: disponibilidade e links renovados a cada **7 dias**; detalhe do título a cada **30 dias**; tela Início a cada **6 horas**. "Atualizado há N dias" discreto; puxar para atualizar força a renovação se a última tiver mais de 24 h.
- Cota: a Streaming Availability tem 1.000 req/mês no grátis; o app para em **900** e, a partir daí, usa só o plano B (busca) até o mês virar. O TMDB não tem cota mensal; respeitar o rate limit (≤ 5 chamadas simultâneas por função).

### 5.8 Importação da Netflix
- Arquivo `NetflixViewingHistory.csv` (`Title,Date`) ou `ViewingActivity.csv` da exportação completa. Formato em `docs/decisoes-apis.md`.
- O CSV é lido **no aparelho** (isolate), agrupado por série/filme pelos padrões `: Temporada N:`, `: Parte N:`, `: Minissérie:`, arco nomeado; data D/M vs M/D decidida pelo conjunto. Só os **nomes agrupados** vão para o servidor; o arquivo não é enviado nem guardado. Fica em `imports` apenas o resumo e o hash do arquivo (para avisar "você já importou este arquivo em DD/MM").
- Confiança do casamento: **alta** entra direto como `watched` (data = última reprodução; `episodes_watched` = linhas da série); **média/baixa** vai para `import_candidates` com 2–3 opções. Meta da fase 05: ≥ 90% automático no CSV real.
- Idempotente: unique (usuário, título) + regra de não sobrescrever o que foi editado à mão (fase 05: registro ainda `netflix_import` avança data e episódios; registro `manual` só ganha o que estava vazio; status diferente de "assisti", nota, review e reassistir nunca mudam; editar à mão marca `source = manual`). Importar duas vezes não duplica nem gera dois eventos de feed (o evento `imported` exige título novo, `imports.titles_new > 0`), e um nome já revisado ou pulado não volta à fila (unique por usuário e nome).
- `ViewingActivity.csv` (exportação completa): linhas com `Supplemental Video Type` (trailer, prévia, resumo) e com menos de 2 min não contam; com mais de um perfil, a pessoa escolhe o dela. Filme repetido em dias diferentes conta uma vez (`watch_count` fica 1).
- Trailers e extras que apareçam como título normal: se não casarem, caem na revisão e a pessoa pula.

### 5.9 Qual assinar
- Função pura e testável (fase 07), sem interface: entrada = títulos candidatos com pesos + disponibilidade em cache + preços; saída = ranking com explicação legível.
- Só assinatura conta (`flatrate`/`ads`). Aluguel e compra aparecem à parte ("3 títulos só para alugar").
- Preço usado: plano `standard` por padrão; chave "aceito anúncios" troca para `ads` quando existir.
- **▶ Preços em `provider_prices` nascem como estimativa** (`is_estimate = true`) para a fase 07 ter com o que trabalhar; o João confere no site de cada streaming, corrige pelo dashboard e zera a flag. A tela sempre mostra a data de atualização e a palavra "estimativa" enquanto a flag estiver ligada.
- Empate: menor preço; persistindo, o que a pessoa já assina; persistindo, ordem de exibição.
- Lembrete de cancelamento: notificação **local** (sem servidor) 3 dias antes de `renews_on`, só se `remind_before_renewal`.

### 5.10 Conteúdo, moderação e termos
- Denunciar: perfil, review (entrada), lista, comentário, atividade. Motivos: spam, assédio, ódio, sexual, violência, spoiler, direitos autorais, outro. O denunciante só cria e vê as próprias denúncias; o João trata pelo dashboard do Supabase (`reports.status`) e remove conteúdo quando preciso.
- Bloqueio por usuário (§5.4) e denúncia cobrem o que a política de conteúdo gerado por usuário da Google Play exige; a política de privacidade e os termos ficam numa página pública (fase 08).
- Sem mensagens diretas no MVP (reduz superfície de abuso).
- Termos das APIs: plano grátis do TMDB é não comercial; antes de qualquer cobrança ou anúncio, licença comercial do TMDB e Starter da Streaming Availability (~US$ 200/mês). Até lá, US$ 0.

## 6. Fora do MVP ("depois")

Nada abaixo serve às cinco jornadas; só entra depois de o MVP estar na loja.

- Notificações **push** (as do MVP são in-app; o lembrete de renovação é local).
- Mensagens diretas, grupos, "assistir junto".
- Diário por **episódio** e múltiplas sessões do mesmo filme com data cada (hoje: `watch_count`).
- Importar de outros serviços (Letterboxd CSV, Trakt, Prime, Disney+). Só a Netflix exporta histórico.
- Recomendação algorítmica de títulos; "média dos amigos" em destaque; distribuição de notas.
- Múltiplas regiões (o banco já tem `region`; a interface não).
- iOS, web, tablet.
- Páginas públicas na web (perfil/lista compartilhável para quem não tem o app).
- Monetização (premium, anúncios) e os planos comerciais das APIs.
- Tags, "assistido com @amigo", notas por temporada, trailers, calendário de lançamentos, lembrete "novo episódio".
- Painel de moderação próprio (o João usa o dashboard do Supabase).
- Realtime (feed atualiza por puxar; sem assinatura em tempo real).

## 7. O que define "MVP pronto"
- As cinco jornadas funcionam no celular do João com uma segunda conta de teste.
- Importação do CSV real ≥ 90% automática.
- Testes de RLS (`npm run db:test`) e `flutter analyze` limpos.
- Checklist da Play (`docs/RELEASE.md`) completo, AAB gerado.

## 8. Glossário tabela ↔ conceito

| Conceito | Tabela(s) | Observação |
|---|---|---|
| Perfil | `profiles` | 1:1 com `auth.users`, criado por trigger |
| Seguir / pedido | `follows` | `status` pending/accepted |
| Bloqueio | `blocks` | só quem bloqueou lê |
| Streaming | `providers`, `provider_prices` | id do TMDB; preços editados pelo João |
| Título | `titles` | cache do TMDB, uuid interno |
| Onde assistir | `title_availability`, `title_sync` | por título/região/streaming/tipo |
| Início | `home_sections` | cache 6 h |
| Cota | `api_usage` | só Edge Functions |
| Diário | `entries` | 1 linha por usuário×título |
| Listas | `lists`, `list_items` | privacidade própria |
| Assistindo agora | `checkins` | expira |
| Importação | `imports`, `import_candidates` | sem o CSV |
| Meus streamings | `user_subscriptions` | lembrete local |
| Feed | `activities` (+ view `feed`) | só triggers escrevem |
| Curtidas / comentários | `likes`, `comments` | contadores em `activities` |
| Notificações | `notifications` | in-app |
| Denúncias | `reports` | dashboard |
| Avatar | bucket `avatars` | pasta = uid |

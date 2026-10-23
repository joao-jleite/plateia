# Release · Plateia (codinome) · fase 08

Checklist completo para colocar o app na Google Play em **teste interno** e, depois, em produção. O que está marcado `[x]` foi feito na fase 08; o que está `[ ]` só o João faz (conta, chave, celular) e está detalhado em `docs/PENDENCIAS-JOAO.md`.

## 1. Build

| O quê | Comando | Observação |
|---|---|---|
| Demonstração (dados de amostra) | `flutter build apk --profile --dart-define=BACKEND=fixtures` | É o `plateia-fase08.apk` da Área de Trabalho. Profile = AOT sem a faixa de debug. **Nunca** release com fixtures: o app recusa e mostra a tela "Este build não está configurado". |
| APK de teste contra o Supabase | `flutter build apk --release --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon ou publishable> --dart-define=GOOGLE_WEB_CLIENT_ID=<client id web>` | Para instalar no celular por `adb install`. Sem `SUPABASE_URL` o release abre na tela de erro legível (provado no emulador na fase 08), não trava. |
| AAB para a Play | `flutter build appbundle --release --dart-define=…` (os mesmos três) | Sai em `build/app/outputs/bundle/release/app-release.aab`. |

- `versionCode` é o número depois do `+` em `pubspec.yaml` (`1.0.0+8`). **Sobe 1 a cada upload** na Play; nunca repete. `versionName` é o que a pessoa vê.
- R8 ligado no release (`isMinifyEnabled`/`isShrinkResources`) com `android/app/proguard-rules.pro` (mantém `com.dexterous.**` e Gson para o lembrete do `flutter_local_notifications` sobreviver ao reinício).
- `--dart-define` entra no binário: a anon/publishable key do Supabase é pública por natureza (a segurança é a RLS); as chaves do TMDB e da RapidAPI nunca entram no app (ficam nos secrets das Edge Functions).

### Assinatura

- [x] `android/app/build.gradle.kts` lê `android/key.properties` (fora do git). Sem o arquivo, o release sai assinado com a chave de **debug** e o Gradle imprime `AVISO: android/key.properties não existe…`. Esse build serve para provar que o pipeline compila; a Play recusa um AAB assinado com debug.
- [ ] **Keystore de release** (João): comando em `docs/PENDENCIAS-JOAO.md` (Fase 08). Preencher `android/key.properties` a partir de `android/key.properties.example`. Guardar `.jks` + senhas em gerenciador de senhas e numa cópia offline.
- [ ] **Play App Signing** (padrão ao criar o app no Console): a Play guarda a chave de assinatura final; a sua keystore vira "chave de upload". Anote o **SHA-256 da chave de assinatura do app** (Console → Configuração → Integridade do app) para o `assetlinks.json` (§6) e o **SHA-1** da chave de upload e da de assinatura para o cliente OAuth Android do Google Cloud (login Google).

### Provas da fase 08 (sem keystore, sem Supabase)

Ver a seção "Decisões" do `CLAUDE.md` (2026-10-23) com os números: `flutter build apk --release` e `flutter build appbundle --release` compilam (assinados com debug); o APK de release instalado no emulador sem `SUPABASE_URL` mostra a tela de erro de configuração; `plateia-fase08.apk` (profile + fixtures) roda o app inteiro.

## 2. Conta e ficha da loja (Google Play Console)

- [ ] Conta de desenvolvedor (US$ 25, uma vez; verificação de identidade pode levar dias). Conta pessoal exige **teste fechado com 12 testadores por 14 dias** antes de produção (regra para contas criadas depois de nov/2023): o teste interno (até 100 e-mails) não conta para isso.
- [ ] Criar o app: nome **Plateia** (ou o nome final; o pacote `io.github.joaojleite.watchlog` não muda), idioma padrão **português (Brasil)**, app (não jogo), gratuito. "Gratuito" é irreversível na Play.
- [ ] Ficha principal:
  - Nome (30): `Plateia`
  - Descrição breve (80): `Seu diário de filmes, séries e anime, com onde assistir no Brasil.`
  - Descrição completa (4000): base no `docs/site/index.html` ("O que dá para fazer"); incluir a frase de atribuição do TMDB e que o app não reproduz vídeo nem precisa de conta de streaming.
  - Ícone 512×512: `assets/branding/icon_legacy.png` redimensionado (PNG, 32 bits).
  - Imagem de destaque 1024×500: montar com a marca sobre `#0E0D12` (o João gera a partir do SVG; a fase 08 não cria peça promocional).
  - Capturas de tela do celular: mínimo 2, 16:9 ou 9:16, de 320 a 3840 px. Sugestão: Início, Detalhe com Onde assistir, Assinar, Perfil, Feed (todas com dados de amostra servem para o teste interno; para produção, dados reais).
  - Categoria: **Entretenimento**. Tags: filmes, séries, streaming.
  - E-mail de contato: o do João (o mesmo das páginas). Site: `https://joao-jleite.github.io/plateia/`.
  - Política de privacidade: `https://joao-jleite.github.io/plateia/privacidade.html` (obrigatória porque o app tem conta).

## 3. Conteúdo do app (formulários obrigatórios)

### Classificação de conteúdo (IARC)
Questionário: app de **entretenimento/utilidade** com **conteúdo gerado por usuário** (reviews, comentários) e **interação entre usuários** (seguir, comentar); sem compras, sem anúncios, sem localização, sem violência/sexo/drogas no conteúdo próprio do app. Resultado esperado: Livre/L no Brasil (ClassInd) com aviso "interação de usuários".

### Público-alvo e conteúdo
- Faixa etária: **13+** (termos exigem 13 anos; sem recurso para crianças). Não marcar "atraente para crianças".
- Anúncios: **não** tem.
- Apps de notícias: não. Covid: não. Apps governamentais: não. Apps financeiros: não.

### Segurança dos dados (respostas coerentes com o banco; `supabase/migrations/0001_init.sql` é a fonte)

| Pergunta | Resposta |
|---|---|
| Coleta ou compartilha dados do usuário? | **Sim, coleta.** Não compartilha com terceiros para fins deles. |
| Dados criptografados em trânsito? | **Sim** (HTTPS no Supabase e nas Edge Functions). |
| Oferece forma de pedir a exclusão? | **Sim**: no app (Configurações → Apagar conta) e pela página `apagar-conta.html`. |

Tipos de dados coletados (todos "coletados", nenhum "compartilhado", nenhum "efêmero", vinculados à conta):

| Categoria | Tipo | Obrigatório? | Finalidade |
|---|---|---|---|
| Informações pessoais | **Nome** (display_name), **Endereço de e-mail**, **ID de usuário** (uuid, @) | e-mail e @ sim; nome não | Funcionalidade do app, gerenciamento da conta |
| Fotos e vídeos | **Fotos** (avatar) | não | Funcionalidade do app (perfil) |
| Mensagens | **Outras mensagens no app** (reviews, comentários, bio, check-in) | não | Funcionalidade do app |
| Atividade do app | **Interações no app** (diário, listas, follows, curtidas, streamings marcados) | não | Funcionalidade do app, personalização (qual assinar) |
| Informações do app e desempenho | **Registros de falhas** | não | Só se o João ligar o Sentry (pendência); hoje nada sai do aparelho |
| Arquivos e documentos | **Arquivos** (CSV da Netflix) | não | O arquivo é lido no aparelho e **não** é enviado; só nomes de títulos e um hash. Marcar como *processado no dispositivo / não coletado*; o hash e os títulos entram em "Interações no app". |

Não coleta: localização, contatos, identificadores de dispositivo/publicidade, dados financeiros, saúde, histórico de navegação, informações do calendário. Dados sensíveis da LGPD: nenhum.

### Política de conteúdo gerado por usuário (UGC)
- [x] Termos de uso aceitos no cadastro: caixa obrigatória no passo 1 do onboarding (`profiles.terms_accepted_at`, migração `0006`) + aviso com links no login e no cadastro. Páginas em `docs/site/termos.html` e `privacidade.html`.
- [x] Denúncia dentro do app: perfil, review, lista, comentário e atividade → tabela `reports` (motivo + detalhes).
- [x] Bloqueio: `blocks`, simétrico no efeito, desfaz follows, esconde tudo nos dois sentidos.
- [x] Remoção de conteúdo: o João lê `reports` no dashboard do Supabase (Table Editor → `reports`, `status`), apaga a linha ofensiva (`entries`, `comments`, `lists`, `activities`) ou a conta (`auth.users`, cascade) e marca a denúncia como tratada. Sem fila de moderação no app no MVP.
- [x] Sem mensagens diretas (reduz superfície de abuso).
- [ ] Na ficha: marcar "o app contém conteúdo gerado por usuário" e descrever os três mecanismos acima.

### Declaração de permissões
`INTERNET`, `POST_NOTIFICATIONS` (lembrete local), `RECEIVE_BOOT_COMPLETED` (reagendar o lembrete). Nenhuma permissão sensível: sem localização, sem `SCHEDULE_EXACT_ALARM`, sem `QUERY_ALL_PACKAGES` (a lista `<queries>` do manifesto nomeia só os 8 streamings).

### Apagar conta (exigência da Play para apps com conta)
- [x] No app: Configurações → Apagar conta → Edge Function `account-delete` (apaga `auth.users`, cascade).
- [x] Página pública: `docs/site/apagar-conta.html` → URL para o campo "Exclusão de dados" do Console: `https://joao-jleite.github.io/plateia/apagar-conta.html`.

## 4. Países e preço
- Países: **Brasil** só, no lançamento (o "onde assistir" é região BR; preços em R$).
- Preço: gratuito, sem compras no app, sem anúncios. **Antes de cobrar ou anunciar**: licença comercial do TMDB (`sales@themoviedb.org`) e Starter da Streaming Availability (US$ 49/mês). Até lá, US$ 0 (decisão da fase 01).

## 5. Trilhas e lançamento
1. [ ] **Teste interno** (até 100 e-mails, sem revisão): subir o AAB, adicionar o e-mail do João (e do Vini). Link de instalação sai na hora. Objetivo: celular real contra o projeto Supabase real, os roteiros de `docs/PENDENCIAS-JOAO.md` (fases 03–07).
2. [ ] **Teste fechado** (12 testadores, 14 dias, exigido para conta pessoal) → pedir acesso à produção no Console.
3. [ ] **Produção** com lançamento gradual (20% → 100%).
4. A cada upload: `versionCode` +1, notas da versão em pt-BR, `flutter test` + `npm run db:test` + `deno task test` verdes, `supabase db push` antes de publicar se houver migração nova (a `0006` desta fase ainda não foi aplicada no projeto, que não existe).

## 6. Site público (GitHub Pages)
- [x] `docs/site/`: `index.html`, `privacidade.html`, `termos.html`, `apagar-conta.html`, `404.html` (convite `/u/<username>`), `u/index.html`, `estilo.css`, `icone.png`, `.nojekyll`, `.well-known/assetlinks.json` (modelo com o SHA-256 a preencher).
- [ ] Publicar: repositório `joao-jleite/plateia` com Pages servindo a pasta (copiar `docs/site/` para a raiz do repo ou configurar Pages → "Deploy from a branch" → `/docs` depois de mover). URL final: `https://joao-jleite.github.io/plateia/`. O app já usa essa base (`Legal.siteBase`, `Routes.inviteUrl`).
- [ ] **App Links** (abrir o convite direto no app, sem "abrir com"): trocar o SHA-256 em `.well-known/assetlinks.json` pelo da chave de assinatura da Play, publicar, e então adicionar `android:autoVerify="true"` ao intent-filter de `joao-jleite.github.io` no `AndroidManifest.xml`. O `.nojekyll` garante que o GitHub sirva a pasta `.well-known`.

## 7. Monitoramento
- [x] Sem serviço externo nesta fase: `FlutterError.onError` e `PlatformDispatcher.onError` imprimem `[crash] …` no logcat também em release (`main.dart`). Edge Functions logam `{fn, user, ms, upstream_calls}` no dashboard.
- [ ] Recomendado quando houver gente de fora: **Sentry** (plano Developer, grátis, 5 mil erros/mês, sem cartão): conta no sentry.io → projeto Flutter → `flutter pub add sentry_flutter` → `SentryFlutter.init((o) => o.dsn = const String.fromEnvironment('SENTRY_DSN'), appRunner: …)` em `main.dart` → `--dart-define=SENTRY_DSN=…` no build. Declarar "Registros de falhas" na Segurança dos dados. Crashlytics foi descartado: exige Firebase/`google-services.json` e duplica o que o Supabase já faz.

## 8. Antes de apertar "publicar" (resumo)
- [ ] `flutter analyze` limpo; `flutter test`, `npm run db:test`, `deno task test` verdes.
- [ ] `supabase migration list` com 0001–0006 remotas; 6 funções no ar; secrets setados.
- [ ] `android/key.properties` presente e o AAB assinado com a keystore de release (o Gradle **não** imprime o AVISO).
- [ ] Páginas do site no ar (privacidade, termos, apagar conta) e as URLs coladas no Console.
- [ ] Login Google funcionando com o SHA-1 da chave de assinatura da Play (não só a de debug).
- [ ] Testado no celular do João com uma segunda conta (os roteiros das fases 04–07 em `docs/PENDENCIAS-JOAO.md`).
- [ ] Logo do TMDB em `assets/tmdb/logo.svg` (a atribuição com logo é a forma pedida pelo TMDB; até lá o app mostra o selo de texto).

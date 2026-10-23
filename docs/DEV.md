# Como rodar · Plateia (fases 03–08)

Tudo no PowerShell, na raiz do repo. Flutter 3.44.8, Node ≥ 20, Deno 2 (`npm i -g deno`), Supabase CLI.

## App

```powershell
flutter pub get
dart run build_runner build          # só depois de mudar modelo freezed / provider @riverpod (os gerados estão no git)
flutter analyze                       # tem que ficar "No issues found"
flutter test                          # unitários + widget (sem rede)
```

### Sem backend (dados de amostra)

```powershell
flutter run -d emulator-5554 --dart-define=BACKEND=fixtures
```

10 títulos em `lib/dev/fixtures/fixture_data.dart` (busque "One Piece", "Oppenheimer", "Arcanjo", "Frieren"…). Login aceita qualquer e-mail com senha de 6+ caracteres ou o botão do Google. O log mostra as mesmas linhas das Edge Functions (`upstream_calls: 0` na segunda abertura). `BACKEND=fixtures` é recusado em build release.

Fase 04: quem loga já tem um diário de amostra (`lib/dev/fixtures/fixture_diary.dart`: 4 assistidos, 1 assistindo, 2 quero ver, 2 listas) e existem dois perfis de terceiros: `@foxer` (público) e `@camila` (privado). Até a busca de pessoas (fase 06) eles só são alcançáveis por código: nos testes de widget, `pumpScreen(tester, const ProfileScreen(username: 'camila'))`; no emulador, `GoRouter.of(context).push('/profile/camila')` de qualquer tela. Para simular o servidor recusando (interface otimista desfazendo): `fixtureOverrides(failWrites: true)`.

Fase 05 (importar a Netflix): a tela `/onboarding/import` (e `/import`, pelas Configurações) tem o botão extra "Usar CSV de exemplo (fixtures)" com um histórico sintético de 23 linhas (`lib/dev/fixtures/fixture_netflix_csv.dart`: 9 casam direto, One Piece vai à revisão como homônimo, "Duna" como parcial, trailer e "Star Wars: Episódio IV: …" sem candidato). O seletor de arquivo real também funciona no emulador: `adb push NetflixViewingHistory.csv /sdcard/Download/` e, no SAF, menu ☰ → Downloads. O backend de fixtures imita `import-match` com a mesma pontuação (`features/import_netflix/domain/matching_score.dart`) e as regras de idempotência das tabelas; o log mostra `{fn: import-match, …} items=13 high=9 medium=1 low=3` e `[import] … auto_match=69%`. Importar duas vezes avisa "Arquivo já importado em DD/MM/AAAA" e termina com "0 novos no diário".

Fase 06 (rede social): a tela de login ganhou "Entrar como (dados de amostra)" com `@foxer` (público), `@camila` (privado) e `@vini` (público); sair (Perfil → ⚙ → Sair) e entrar com outro mantém o que o anterior fez, porque a memória é do processo (`FixtureSocialStore`, `lib/dev/fixtures/fixture_social.dart`, que espelha os triggers do banco: privacidade no seguir, limpeza no bloqueio, contadores, notificações). Cena inicial: foxer ↔ camila se seguem, vini ↔ foxer se seguem, camila e vini curtiram/comentaram a review do foxer, foxer tem um check-in ativo. Rotas novas: `/feed` (aba), `/activity/:id`, `/search/users`, `/notifications`, `/follow-requests`, `/settings/blocked`, `/profile/:username/followers|following`, `/onboarding/follow` e `/u/:username` (link de convite, redireciona para o perfil). Para simular o servidor recusando (otimista + Desfazer): `fixtureOverrides(failWrites: true)`; para testar o feed em erro, `pumpScreen(..., feed: repositórioQueFalha)`. `pumpScreen` sobe as telas com `AppTheme.light()`: o tema dá largura mínima infinita a `FilledButton`/`OutlinedButton`, então um botão dentro de `Row` ou `ListTile.trailing` precisa de `minimumSize: Size(0, h)` (o teste estoura com "forces an infinite width" se esquecer).

Fase 07 (qual assinar): a aba **Assinar** (`/subscribe`) calcula a recomendação com o diário de amostra (o usuário por e-mail tem 8 "quero ver" + One Piece assistindo: HBO Max resolve 3, Netflix 2, Crunchyroll/Apple TV+/Paramount+ 1; `Furiosa` só aluguel; `Bebê Rena` entrou "sem dados" e passa a contar depois que o detalhe dele é aberto, como `title_sync` no banco). Entrando como `@foxer`, os títulos dos amigos entram com peso 0,3 (The Last of Us da @camila e Duna 2 do @vini, ambos na HBO Max) e desempatam contra a Netflix. Preços em `FixturePrices` (`lib/dev/fixtures/fixture_data.dart`, espelho do seed, todos "estimativa"; o do Paramount+ é de 01/08 de propósito, para mostrar o aviso de preço velho). **Meus streamings** (`/subscribe/mine`, também em Perfil → ⚙): quem entra já assina Netflix (renova em 10 dias) e mais um (Prime Video; o foxer, Crunchyroll); marcar/editar abre a folha (plano, preço que paga, data, lembrete) e grava otimista com Desfazer. O lembrete é `flutter_local_notifications` de verdade no emulador: o sino na barra ("Testar lembrete") dispara uma notificação na hora (pede `POST_NOTIFICATIONS` no Android 13+), e uma renovação marcada para daqui a menos de 3 dias agenda o lembrete para 1 minuto depois (`adb shell dumpsys alarm | grep watchlog` lista os alarmes). Nos testes de widget o agendador é `RecordingReminderScheduler` (`pumpScreen(..., scheduler: …)`) e o relógio da janela de 30 dias é fixado por `clockProvider.overrideWithValue(() => DateTime(2026, 10, 23))`. A função pura é `recommend()` em `lib/features/subscribe/domain/recommender.dart`; a conta à mão está em `test/features/subscribe/domain/recommender_test.dart`.

Fase 08 (polimento e release): tema escuro "Sala escura" (`lib/core/theme/app_theme.dart`, `docs/DESIGN.md`) com Fraunces + Manrope pelo `google_fonts` (baixadas na primeira abertura com rede; nos testes `AppTheme.dark(withGoogleFonts: false)`). Marca em `lib/core/branding/plateia_mark.dart`; ícone, splash e SVG saem de `flutter test tool/branding/render_branding_test.dart` → `dart run flutter_launcher_icons` → `dart run flutter_native_splash:create`. Skeletons em `lib/core/widgets/skeletons.dart` (`AsyncView(loading: …)`); `BackOrHomeButton` nas telas que podem ser raiz por deep link (perfil, título, atividade, lista). Preferências locais via `preferencesProvider` (`shared_preferences` no app, `MemoryPreferences` no `pumpScreen`). Onboarding com `OnboardingHeader` (3 passos) e a caixa de termos obrigatória no passo 1 (`terms_accepted_at`, migração `0006`). Logo do TMDB: salve `assets/tmdb/logo.svg` e o `TmdbBadge` passa a mostrá-lo. Release: `android/key.properties` (modelo `key.properties.example`); sem ele o release sai com a chave de debug e o Gradle avisa (o `flutter build` esconde o aviso: confira com `apksigner verify --print-certs`). Checklist da Play em `docs/RELEASE.md`; páginas públicas em `docs/site/`.

Ensaio com um CSV real, sem servidor (só a metade que roda no aparelho): `dart run tool/import_dry_run.dart research/NetflixViewingHistory.csv [--profile "Nome"] [--names]`.

### Com o projeto Supabase

```powershell
flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon ou publishable key> --dart-define=GOOGLE_WEB_CLIENT_ID=<client id web>
```

Sem `SUPABASE_URL`/`SUPABASE_ANON_KEY` o app abre na tela "Este build não está configurado" explicando o que falta (também em release; captura em `docs/capturas/fase08/release-sem-config.png`). Sem `GOOGLE_WEB_CLIENT_ID` o botão do Google mostra erro e o resto funciona.

### APK

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=… --dart-define=GOOGLE_WEB_CLIENT_ID=…         # APK de teste no celular
flutter build appbundle --release --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=… --dart-define=GOOGLE_WEB_CLIENT_ID=…   # AAB para a Play
flutter build apk --profile --dart-define=BACKEND=fixtures                                                                           # demonstração (é o plateia-fase08.apk)
```

Saída em `build/app/outputs/flutter-apk/` e `build/app/outputs/bundle/release/`. O mais novo vai para a Área de Trabalho; os antigos para `dist/` (fora do git). Tempo de abertura: `flutter run --profile --trace-startup --dart-define=BACKEND=fixtures -d emulator-5554` grava `build/start_up_info.json` (número da fase 08 na seção Decisões do `CLAUDE.md`).

## Banco

```powershell
npm run db:test              # Postgres 17 local: migrações 0001–0006 + checagem de RLS + tools/db/tests/*.sql (7 arquivos, ~7 s)
npm run db:test:keep         # idem, deixa o banco de pé em localhost:54329 até apertar Enter
npm run db:seed-dev:local    # com o banco de pé: 3 contas de teste + diários + follows no Postgres local (ensaio do seed)
npm run db:seed-dev:dry      # só imprime o plano do seed
npm run db:seed-dev          # seed no projeto real: lê SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY de tools/db/.env (fora do git); `-- --reset` apaga as contas
supabase db push             # só depois do db:test verde e do `supabase link`
```

## Edge Functions

```powershell
cd supabase/functions
deno task check              # tipa as 6 funções (baixa supabase-js do npm na primeira vez)
deno task test               # testes unitários dos handlers com fakes (30)
cd ../..
supabase functions deploy catalog-title --use-api    # idem para catalog-search, home-sections, import-match, providers-sync, account-delete
supabase secrets set TMDB_API_KEY=… RAPIDAPI_KEY=…
```

## Emulador

`lume34` (celular). Subir: `C:\Android\sdk\emulator\emulator.exe -avd lume34`. Logs do app: `adb logcat -s flutter`.

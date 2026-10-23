# Como rodar · Plateia (fases 03–05)

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

Ensaio com um CSV real, sem servidor (só a metade que roda no aparelho): `dart run tool/import_dry_run.dart research/NetflixViewingHistory.csv [--profile "Nome"] [--names]`.

### Com o projeto Supabase

```powershell
flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon ou publishable key> --dart-define=GOOGLE_WEB_CLIENT_ID=<client id web>
```

Sem `SUPABASE_URL`/`SUPABASE_ANON_KEY` o app abre numa tela "configuração ausente" explicando o que falta. Sem `GOOGLE_WEB_CLIENT_ID` o botão do Google mostra erro e o resto funciona.

### APK

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=… --dart-define=GOOGLE_WEB_CLIENT_ID=…   # produto
flutter build apk --profile --dart-define=BACKEND=fixtures                                                                     # demonstração (é o plateia-fase05.apk)
```

Saída em `build/app/outputs/flutter-apk/`. O mais novo vai para a Área de Trabalho; os antigos para `dist/` (fora do git).

## Banco

```powershell
npm run db:test              # Postgres 17 local: migrações 0001–0004 + checagem de RLS + tools/db/tests/*.sql (4 arquivos, ~8 s)
npm run db:test:keep         # idem, deixa o banco de pé em localhost:54329 até apertar Enter
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

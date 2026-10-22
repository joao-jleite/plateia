# Fase 03 — Base do app e catálogo
Modelo: Fable 5.1 · esforço xhigh

## Objetivo
App rodando com login e catálogo: buscar qualquer filme, série ou anime, ver o detalhe em PT-BR, ver onde ele está no Brasil e abrir o app oficial do streaming.

## Escopo
- Projeto Flutter criado nesta pasta, seguindo a `docs/ARQUITETURA.md`, com `git init`.
- Login por e-mail e por Google (Supabase Auth).
- Edge Functions de proxy das APIs (TMDB e a fonte escolhida na fase 01), com cache no Postgres. Nenhuma chave no app.
- Telas:
  - **Início:** em alta no Brasil e novidades por streaming.
  - **Busca.**
  - **Detalhe:** pôster, sinopse, elenco, temporadas e "Onde assistir", com o logo do streaming e um botão "Abrir na Netflix" (ou no streaming do título).
- **Sem link direto:** usar o plano B que a fase 01 definiu.
- **Abrir app externo no Android 11+:** declarar `<queries>` no manifesto (visibilidade de pacotes) e abrir com `LaunchMode.externalApplication`. Sem o `<queries>`, o `canLaunchUrl` responde falso e o app não consegue checar o que está instalado.
- Atribuição exigida pelas APIs na tela "Onde assistir".

## Restrições
- Cada título consultado de novo usa o cache e não gasta cota.
- Estados de carregando, vazio e erro em toda tela.

## Precisa do João
Rodar os `supabase secrets set` que você indicar e configurar o OAuth do Google no Google Cloud. Passe o passo a passo exato.

## Pronto quando
- No emulador: buscar "One Piece" → abrir o detalhe → ver onde assistir → o botão abre o app ou o site oficial.
- Abrir o mesmo título de novo não chama a API externa (mostre isso no log).
- `flutter analyze` limpo e testes de widget das telas principais.
- APK na Área de Trabalho e commit feito.

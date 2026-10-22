# Fase 01 — Validar as fontes de "onde assistir" no Brasil
Modelo: Fable 5.1 · esforço high

## Objetivo
Descobrir, com teste real e não lendo documentação, duas coisas:
- de onde vem a lista de streamings de cada título **no Brasil**;
- de onde vem o link que **abre o app oficial** no Android.

Todas as fases seguintes dependem dessa resposta. Ainda não há app nesta fase: só scripts de teste e um documento de decisão.

## O que testar
Amostra fixa de 20 títulos, misturando streamings e formatos. A disponibilidade muda; eles servem só de amostra.
- Netflix: Stranger Things, Round 6, Wandinha, Sintonia
- Max: The Last of Us, A Casa do Dragão
- Disney+: The Bear, Andor
- Prime Video: The Boys, Invencível
- Globoplay: Arcanjo Renegado
- Anime: One Piece, Frieren
- Filmes: Ainda Estou Aqui, Cidade de Deus, Divertida Mente 2, Duna: Parte Dois, Oppenheimer
- Outros: Ruptura (Apple TV+), Yellowstone (Paramount+)

Fontes a comparar:
1. **TMDB** `watch/providers` (região BR): cobertura, quais streamings aparecem e o que vem no campo de link.
2. **Watchmode:** o Brasil está em `/v1/regions`? O plano grátis devolve deep link de Android? Qual é a cota?
3. **Streaming Availability** (Movie of the Night, via RapidAPI): cobre o Brasil? Devolve deep link? Qual é a cota?
4. **Links abrem o app?** Para cada domínio de streaming, confira se `/.well-known/assetlinks.json` declara o pacote Android. Isso indica se o link https abre o app em vez do navegador. Confira também se há formato de link de busca usável como plano B.
5. **CSV da Netflix:** descreva o formato real (colunas, encoding, formato de data e padrões de título de série como ": Temporada 1:" e ": Parte 2:"), com exemplos anonimizados.

Para saber se o streaming informado está certo, compare 5 títulos com a página da JustWatch Brasil.

## Entregáveis
- `docs/decisoes-apis.md` com:
  - uma tabela fonte × (cobre BR, % da amostra com streaming certo, tem deep link, cota grátis, preço do plano comercial, termos que importam);
  - a fonte recomendada e o plano B;
  - o que o app faz quando não há link direto;
  - o formato do CSV.
- Scripts de teste em `research/` (Python standalone com venv), com tratamento de erro.
- Seção "Decisões" do `CLAUDE.md` atualizada.

## Restrições
- Não gastar mais de 20% da cota mensal de nenhuma API.
- `research/.env` e o CSV ficam fora do git (criar `.gitignore` já agora).
- Não raspar site de streaming. A JustWatch é só conferência manual de 5 títulos.

## Precisa do João
As três chaves grátis em `research/.env` e o CSV em `research/NetflixViewingHistory.csv`. Se faltar algo, faça o que der sem isso e liste o que ficou bloqueado.

## Pronto quando
O `docs/decisoes-apis.md` responde, com números da amostra:
- qual fonte usar;
- quanto ela custa quando o app virar comercial;
- o que acontece quando não houver link direto.

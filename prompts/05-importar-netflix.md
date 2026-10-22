# Fase 05 — Importar o histórico da Netflix
Modelo: Fable 5.1 · esforço xhigh

## Objetivo
O perfil nasce cheio. A pessoa sobe o `NetflixViewingHistory.csv`, o app casa cada linha com um título do TMDB, mostra só os casos duvidosos para revisão e grava tudo como "Assisti".

## O que torna isso difícil
- Uma série aparece uma vez por episódio, com títulos como "Série: Temporada 2: Nome do episódio", "Parte 1", "Minissérie" e "Volume". É preciso agrupar por série e por temporada.
- Data em formato BR ou US, dependendo da conta. O encoding e as aspas variam.
- Títulos traduzidos, homônimos (filme e série com o mesmo nome) e especiais.
- Um histórico pode passar de 5 mil linhas. Não pode travar o app nem estourar o limite de taxa do TMDB.

O formato real está descrito em `docs/decisoes-apis.md`.

## Escopo
- Upload do CSV no onboarding e também no perfil.
- Matching com nota de confiança. Os de alta confiança entram direto; os outros vão para uma tela de revisão com 2 ou 3 candidatos cada.
- Importação idempotente: importar o mesmo CSV duas vezes não duplica nada.
- O CSV não fica guardado em lugar nenhum; só o resultado.
- Ao final, um resumo: "312 títulos importados, 9 para revisar".

## Testes
- Testes unitários do parser e do matching, com casos sintéticos para cada padrão de título.
- O CSV real do João como fixture **anonimizada e fora do git**, ou reduzida a títulos sem dado pessoal.

## Pronto quando
- O CSV real do João importa com uma % de casamento automático medida e informada. A meta é ≥ 90%; se não bater, diga onde está o erro.
- Os duvidosos aparecem na tela de revisão.
- Rodar a importação duas vezes não duplica nada.
- APK na Área de Trabalho e commit feito.

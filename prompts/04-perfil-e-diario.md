# Fase 04 — Perfil e diário
Modelo: Fable 5.1 · esforço high

## Objetivo
A pessoa registra o que vê em no máximo 2 toques a partir do detalhe do título, e o perfil mostra isso de um jeito que dá vontade de mostrar.

## Escopo
- **Status:** Assisti (data, nota de 0,5 a 5, review curta com marcação de spoiler), Quero ver e Assistindo. Em série, guardar temporada e episódio atuais.
- **Listas:** criar, ordenar, pública ou privada.
- **Perfil:**
  - foto, @, bio;
  - grade de pôsteres e abas (Assisti / Quero ver / Listas / Reviews);
  - estatísticas: horas assistidas, por streaming, por gênero e por ano.
- **Privacidade:** perfil público ou privado, conforme a spec.

## Restrições
- A interface atualiza na hora (otimista) e desfaz com aviso se o servidor recusar.
- As regras de nota, spoiler e privacidade são as do `docs/SPEC.md`. Se encontrar um buraco, registre em "Decisões" antes de inventar.

## Pronto quando
- O fluxo completo funciona no emulador.
- Os testes de RLS provam que outro usuário não lê nem altera registro alheio e que o perfil privado não vaza.
- APK na Área de Trabalho e commit feito.

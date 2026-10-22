# Fase 07 — "Qual streaming assinar este mês"
Modelo: Fable 5.1 · esforço xhigh

## O que a fase 02 já decidiu
- Regras em `docs/SPEC.md` §5.9: fonte = meu "Quero ver" e "Assistindo" (peso 1) + títulos que amigos seguidos assistiram ou avaliaram ≥ 4 nos últimos 30 dias e não estão no meu diário (peso 0,3); só assinatura (`flatrate`/`ads`); plano `standard` por padrão, chave "aceito anúncios" troca para `ads`; combinação de 2 só se o segundo acrescenta ≥ 3 títulos e baixa o custo por título; empate = menor preço → já assino → ordem de exibição.
- Tabelas: `provider_prices` (preços por plano, `is_estimate`, `updated_at`), `user_subscriptions` (o que a pessoa assina, `renews_on`, `remind_before_renewal`), `title_availability` (única fonte de disponibilidade; sem cache = "sem dados").
- Os preços do seed são **estimativas** (`is_estimate = true`) até o João conferir pelo dashboard. A tela mostra a data de `updated_at` e a palavra "estimativa" enquanto a flag estiver ligada.
- Lembrete de cancelamento é notificação **local** (`flutter_local_notifications`), 3 dias antes de `renews_on`.

## Objetivo
Uma tela que olha o "Quero ver" da pessoa (e, com peso menor, o que os amigos estão vendo) e responde, com conta visível: "Este mês, assine a HBO Max: ela resolve 8 dos seus 12 títulos, por R$ 39,90".

Esse é o diferencial do app e o gancho dos anúncios: economizar com streaming sem perder o que se quer ver.

## Escopo
- Recomendador em `features/subscribe/domain/` como **função pura**: entrada = candidatos com peso + disponibilidade + preços + o que já assino; saída = ranking com, por streaming, títulos resolvidos, custo por título, o que fica de fora, e a frase final.
- Aba **Assinar** (`/subscribe`): a recomendação, a conta aberta ("Netflix resolve 3, HBO Max resolve 8"), aluguel/compra à parte, "sem dados" para título sem cache, data dos preços visível.
- **Meus streamings** (`/subscribe/mine`): marcar o que assino, plano, data de renovação; economia estimada no ano (assinar um por mês × 12 contra tudo o que marquei × 12).
- **Lembrete de cancelamento:** notificação local 3 dias antes de cada `renews_on` com `remind_before_renewal`; reagendar ao editar.
- Texto legível, sem jargão.

## Restrições
- Algoritmo sem dependência de interface, Supabase ou Flutter.
- Sem disponibilidade em cache para um título, "sem dados", nunca chute. Não disparar `catalog-title` em lote para preencher cache (cota).
- Preço editável só pelo João (dashboard); o app não escreve em `provider_prices`.

## Testes
Unitários com casos fixos e a conta escrita no teste: lista vazia; empate; título em vários streamings; título em nenhum; preço desatualizado (`updated_at` > 60 dias marca aviso); combinação de 2 que vale e que não vale; chave de anúncios.

## Pronto quando
- Com uma lista de teste de 12 títulos, a recomendação bate com a conta feita à mão (deixe a conta no teste).
- Preços com data (e "estimativa", se for o caso) visíveis; lembrete agendado aparece nas notificações do Android.
- `flutter analyze` limpo, APK na Área de Trabalho e commit feito.

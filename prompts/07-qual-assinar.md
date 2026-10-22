# Fase 07 — "Qual streaming assinar este mês"
Modelo: Fable 5.1 · esforço xhigh

## Objetivo
Uma tela que olha o "Quero ver" da pessoa (e, com peso menor, o que os amigos estão vendo) e responde, com conta visível: "Este mês, assine a Max: ela resolve 8 dos seus 12 títulos, por R$ X".

Esse é o diferencial do app e o gancho dos anúncios: economizar com streaming sem perder o que se quer ver.

## Escopo
- Para cada streaming: quantos títulos da lista ele resolve (só assinatura; aluguel e compra à parte), custo por título e o que fica de fora.
- Recomendar 1 streaming. Recomendar uma combinação de 2 só se ela for claramente melhor.
- Tabela de preços (`provider_prices`) editável pelo João, com plano com e sem anúncio e a **data da última atualização visível** na tela.
- Economia estimada no ano: assinar um por mês contra assinar todos os que a pessoa marcou que tem.
- **Lembrete de cancelamento:** a pessoa informa quando assinou e recebe uma notificação local 3 dias antes de renovar.
- Texto legível, sem jargão: "Netflix resolve 3, Max resolve 8".

## Restrições
- O algoritmo vive numa função pura, testável e sem dependência de interface.
- Sem disponibilidade em cache para um título, mostrar "sem dados" em vez de chutar.

## Testes
Testes unitários com casos fixos: lista vazia, empate, título em vários streamings, título em nenhum e preço desatualizado.

## Pronto quando
- Com uma lista de teste de 12 títulos, a recomendação bate com a conta feita à mão (deixe a conta escrita no teste).
- Preços com data visível.
- APK na Área de Trabalho e commit feito.

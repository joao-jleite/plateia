# Fase 02 — Spec e arquitetura
Modelo: Fable 5.1 · esforço xhigh · começar no modo de planejamento

## Objetivo
Transformar o `CLAUDE.md` e o `docs/decisoes-apis.md` numa especificação executável e no schema do banco, antes de qualquer tela. O João precisa conseguir ler e aprovar a spec em 10 minutos.

## O MVP serve a cinco jornadas
1. Cadastro, importação do CSV da Netflix e um perfil que já nasce cheio.
2. Buscar um título, ver onde ele está no Brasil e abrir o app oficial.
3. Registrar "assisti / quero ver / assistindo", com nota e review.
4. Seguir amigos e ver o feed deles.
5. Ver "qual streaming assinar este mês".

O que não serve a nenhuma dessas jornadas vai para a lista "depois".

## Entregáveis
- `docs/SPEC.md` com:
  - 2 personas;
  - as 5 jornadas passo a passo;
  - mapa de telas;
  - regras de negócio (escala de nota, spoiler, privacidade do perfil, o que entra no feed);
  - lista "fora do MVP".
- `supabase/migrations/0001_init.sql` com:
  - todas as tabelas: perfis, cache de títulos, cache de disponibilidade por título/região/streaming, registros do usuário, listas, follows, atividades, curtidas, comentários, bloqueios, denúncias, preços dos streamings;
  - **RLS em todas**, com um comentário curto explicando cada policy.
- `docs/ARQUITETURA.md` com:
  - estrutura de pastas do Flutter;
  - gerência de estado e navegação (escolher uma de cada e justificar em 3 linhas);
  - Edge Functions (quais são e o contrato de cada uma);
  - estratégia de cache e de cota da API;
  - como o feed é montado no começo e a partir de que escala isso muda.
- Nome do pacote Android definido (o João aprova).
- Backlog das fases 03 a 08 revisado com o que a fase 01 descobriu. Se a ordem ou o escopo de alguma fase mudar, edite o prompt dela.
- "Decisões" do `CLAUDE.md` atualizada.

## Restrições
- Solução de dev solo: nada de microserviço, fila ou infraestrutura que o Supabase não resolva sozinho.
- As tabelas sociais precisam suportar bloqueio e perfil privado desde o início. Remendar isso depois custa caro.

## Precisa do João
Um projeto Supabase de dev criado, a URL dele e a aprovação da spec.

## Pronto quando
- A migração aplica limpa: no Supabase local se houver Docker, senão no projeto de dev.
- O João aprovou o `SPEC.md`.

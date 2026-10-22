# Fase 06 — Rede social
Modelo: Fable 5.1 · esforço xhigh

## Objetivo
Ver o que os amigos estão assistindo e conversar sobre isso, com privacidade e segurança desde o primeiro dia.

## Escopo
- **Seguir:** relação assimétrica, como no Letterboxd. Perfil privado exige pedido de seguir.
- **Feed:** assistiu, deu nota, escreveu review, criou lista, importou o histórico. Agrupar eventos em rajada ("assistiu 6 episódios de The Bear").
- **Interações:** curtir e comentar. Review com spoiler aparece borrada até o toque.
- **"Assistindo agora":** check-in manual que expira sozinho.
- **Descobrir amigos:** busca por @, link de convite e compartilhar o perfil.
- **Bloquear e denunciar** usuário e conteúdo. A política de conteúdo gerado por usuário do Google Play exige isso.
- Notificações dentro do app (seguiu você, curtiu, comentou). Push fica para depois, se a spec não disser o contrário.

## Restrições
- Bloqueio vale nos dois sentidos: um não vê o outro em feed, busca, comentário nem perfil.
- Toda regra de visibilidade fica no banco (RLS), não só na interface.

## Testes
- Testes de RLS automatizados provando que:
  - bloqueado não vê;
  - conteúdo de perfil privado não vaza para quem não segue;
  - ninguém edita ou apaga o que não é seu.
- Usuários de teste criados por script de seed no projeto de dev.

## Pronto quando
- Dois usuários de teste seguem um ao outro, interagem no feed e um bloqueia o outro, com o comportamento certo nas duas pontas.
- Os testes de RLS passam.
- APK na Área de Trabalho e commit feito.

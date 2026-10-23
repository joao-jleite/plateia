# Design · Plateia (codinome) · fase 08 (2026-10-23)

Identidade visual própria, escura por padrão (app de filme, usado à noite, no sofá). Duas direções curtas; a **A** foi aplicada no app inteiro (decisão registrada no `CLAUDE.md`). Trocar para a B é mexer só em `lib/core/theme/app_theme.dart` e nas fontes.

## Direção A · "Sala escura" (aplicada)

A sala de cinema antes do filme: preto quente, uma faixa de luz dourada (a tela) e as fileiras da plateia. Dourado é a cor do destaque e da nota (as estrelas já eram âmbar); o resto é tom sobre tom.

| Papel | Cor | Uso |
|---|---|---|
| Fundo | `#0E0D12` | `scaffoldBackground`, splash, ícone |
| Superfície | `#17161D` | cartões, folhas, barra inferior |
| Superfície alta | `#22212A` / `#2B2A34` | chips, campos, skeleton |
| Primária (dourado) | `#F2B544` · texto sobre ela `#2A1D00` | botão principal, aba ativa, estrelas, links |
| Container primário | `#4A3406` · texto `#FFDFA3` | destaque discreto (cartão "Este mês, assine…") |
| Secundária (veludo) | `#E8899A` · container `#4E1F2A` | curtir, notificações, selo de spoiler |
| Terciária (sala) | `#6FD3BE` · container `#0F3F37` | "Assistindo agora", check-in, sucesso |
| Texto | `#F3EFE6` · secundário `#A9A49A` · outline `#7B7770` | contraste AA em todas as combinações acima (texto principal 16,9:1; secundário 7,8:1; dourado sobre fundo 10,6:1; texto escuro sobre dourado 9,0:1; outline 4,3:1 só em texto decorativo) |
| Erro | `#FF8A80` · container `#5C1F1B` | padrão Material |

Tipografia: **Fraunces** (serifa macia, só em display/headline/título de tela, peso 600) + **Manrope** (corpo, botões, rótulos). As duas vêm do `google_fonts`; sem rede o Android cai no Roboto sem quebrar layout. Escala: título de tela 22, seção 16/600, corpo 14/15, rótulos 12. Respeita a fonte do sistema até 1,3× (acima disso a interface trava em 1,3 para a grade e os botões não quebrarem).

Forma: raio 12 em cartões e campos, 999 em chips e no botão principal; botão com 48 de altura; elevação zero com borda sutil (`#2B2A34`) em vez de sombra. Transição entre telas: fade-forwards do Material 3 (discreta, sem deslizar tudo). Ícones `Icons.*_outlined` nas abas, preenchidos na ativa.

Ícone: quadrado `#0E0D12`, uma barra dourada arredondada no alto (a tela acesa) e três fileiras de assentos em curva abaixo, em marfim com opacidade decrescente para o fundo da sala; um assento da fileira do meio é dourado (a pessoa). Mesma marca no splash (`flutter_native_splash`) e no cabeçalho do login. Gerada por nós em `assets/branding/` (SVG escrito à mão + PNGs renderizados pelo `CustomPainter` do app); nada copiado de terceiros.

### Mock · Início
```
┌──────────────────────────────────────┐
│ Início                           🔔1 │  Fraunces 22 · fundo #0E0D12
│                                      │
│ ● Assistindo agora                   │  faixa terciária: avatares + título
│ [@camila · The Last of Us · 2h]      │
│                                      │
│ Em alta no Brasil                    │  Manrope 16/600
│ ▭▭ ▭▭ ▭▭ ▭▭ ▭▭ →                     │  pôsteres 120×180, raio 12
│ Duna 2  Oppen…  Furiosa              │  bodyMedium + ano em outline
│                                      │
│ Novidades na Netflix                 │
│ ▭▭ ▭▭ ▭▭ ▭▭ →                        │
│                                      │
│ Atualizado há 2 h · dados do TMDB    │  labelSmall outline
├──────────────────────────────────────┤
│ ⌂ Início  ⌕ Buscar  ≋ Feed  ▣ Assinar  ◯ Perfil │  barra #17161D, ativa dourada
└──────────────────────────────────────┘
```

### Mock · Detalhe do título
```
┌──────────────────────────────────────┐
│ ←  Duna: Parte Dois                  │
│ ┌──────┐  2024 · Filme · 2h46        │
│ │pôster│  ★★★★½  nota dos amigos 4,5 │  estrelas douradas
│ │      │  Ficção científica · Drama   │  chips raio 999, superfície alta
│ └──────┘  [ ✎ Registrar ]            │  botão primário dourado, 48 de altura
│                                      │
│ Sinopse… (3 linhas, "mais")          │
│                                      │
│ Onde assistir       Atualizado há 3 d│
│ ┌ [logo] HBO Max   assinatura ─────┐ │  cartão #17161D, borda #2B2A34
│ │                [ Abrir na HBO Max ]│ │  botão tonal (container secundário, veludo)
│ └──────────────────────────────────┘ │
│ ┌ [logo] Prime Video  aluguel R$ 9,90┐│
│ └──────────────────────────────────┘ │
│ [TMDB] Onde assistir: dados da        │  logo do TMDB se existir, senão selo
│        JustWatch via TMDB             │
└──────────────────────────────────────┘
```

### Mock · Perfil
```
┌──────────────────────────────────────┐
│ @foxer                      📊  ⚙  ⋮ │
│ (◯ foto)  Foxer                      │  Fraunces 20
│           @foxer · segue você        │  outline
│           "Anime e ficção. Embu."    │
│   128      12      4      56     61  │  titleMedium Manrope 700
│ Assistidos Reviews Listas Seguid. Seguindo│
│ [ ✎ Editar perfil ]                  │  outlined, 40 de altura
│ Assisti │ Quero ver │ Listas │ Reviews│  aba ativa com sublinhado dourado
│ Assistindo                           │
│ ▭ ▭ ▭ →                              │
│ ▭▭▭ ▭▭▭ ▭▭▭                          │  grade 3 colunas, raio 12
│ ▭▭▭ ▭▭▭ ▭▭▭                          │
│          [ Mostrar mais ]            │
└──────────────────────────────────────┘
Vazio: ícone 48 outline + "Nada assistido ainda" + "Abra um título e toque em
Registrar." + botão [ Buscar um título ] (sempre com uma ação).
```

## Direção B · "Neon de bairro" (não aplicada)

A fachada de locadora à noite: azul-preto frio, violeta elétrico e um ciano de letreiro. Mais "tech", mais perto do roxo que o app usava como semente nas fases 03–07.

| Papel | Cor |
|---|---|
| Fundo | `#0B0F1A` · superfície `#131A2A` · alta `#1C2436` |
| Primária | `#8B7CFF` (violeta) · texto `#140B3D` |
| Secundária | `#3EE0C9` (ciano) |
| Terciária | `#FF6FAE` (rosa de letreiro) |
| Texto | `#EEF1FF` · secundário `#9AA3BF` |

Tipografia: **Space Grotesk** (títulos, 600) + **Inter** (corpo). Raio 16 em tudo, chips quadrados com borda em ciano, sombras com brilho da cor primária nos botões. Mesmos mocks com os papéis trocados: a faixa "Assistindo agora" em ciano, o botão Registrar em violeta, as estrelas em rosa.

## Por que a A

1. É de cinema, não de software: preto quente + dourado lê como "sala", e as estrelas douradas que já existiam viram parte da identidade em vez de um corpo estranho.
2. Fica longe do Letterboxd (verde/laranja/azul sobre cinza-azulado) e do roxo genérico de template que o app carregava.
3. Contraste: dourado sobre `#0E0D12` dá 10,6:1 e o texto escuro sobre dourado 9,0:1; o violeta da B sobre fundo escuro fica em 5,9:1 e o texto sobre ele exige mais cuidado nos estados desabilitados.
4. Serifa só nos títulos dá o tom "crítica de cinema" do Rafael (persona) sem prejudicar a leitura rápida da Camila: tudo que se lê correndo (cartões, botões, feed) é Manrope.

Se o João preferir a B, a troca é `AppTheme` (paleta e `GoogleFonts.spaceGrotesk`/`inter`) e regenerar ícone e splash com `flutter test tool/branding/render_branding_test.dart && dart run flutter_launcher_icons && dart run flutter_native_splash:create`.

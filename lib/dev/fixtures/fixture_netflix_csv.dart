import 'dart:convert';
import 'dart:typed_data';

/// CSV de exemplo para o botão "Usar CSV de exemplo (fixtures)" da tela de
/// importar. Cobre os padrões de título contra o catálogo de amostra
/// (`fixture_data.dart`): séries por temporada/parte/arco, filme com ":",
/// homônimo (One Piece anime × live action), título fora do catálogo
/// ("Duna" só parcial), trailer e um "X: Y: Z" de uma linha só. Datas D/M/YY
/// com um dia > 12 para provar a ordem. Com BOM, como a Netflix exporta.
const sampleNetflixCsvText = '\u{FEFF}Title,Date\r\n'
    'Stranger Things: Temporada 4: Capítulo Nove: O Piggyback,15/07/24\r\n'
    'Stranger Things: Temporada 4: Capítulo Oito: Papai,14/07/24\r\n'
    'Stranger Things: Temporada 4: Capítulo Oito: Papai,13/07/24\r\n'
    'Stranger Things: Temporada 1: Capítulo Um: O Desaparecimento de Will Byers,02/01/23\r\n'
    'One Piece: East Blue: Eu sou Luffy! O homem que vai ser o Rei dos Piratas!,01/03/24\r\n'
    'One Piece: East Blue: O grande espadachim aparece! Roronoa Zoro,02/03/24\r\n'
    'One Piece: Alabasta: A luta final,10/06/24\r\n'
    'The Last of Us: Temporada 1: Quando Você Está Perdido na Escuridão,16/01/23\r\n'
    'The Last of Us: Temporada 1: Infectados,23/01/23\r\n'
    'The Last of Us: Temporada 1: Muito Tempo,30/01/23\r\n'
    'Frieren e a Jornada para o Além: Temporada 1: O Fim da Jornada,05/10/23\r\n'
    'Frieren e a Jornada para o Além: Temporada 1: Não Precisava Ser Magia,12/10/23\r\n'
    'Arcanjo Renegado: Temporada 1: Episódio 1,20/08/24\r\n'
    'Arcanjo Renegado: Temporada 1: Episódio 2,21/08/24\r\n'
    'O Urso: Temporada 1: Sistema,03/09/24\r\n'
    'Yellowstone: Temporada 1: Daybreak,11/11/23\r\n'
    'Oppenheimer,28/08/24\r\n'
    'Oppenheimer,29/08/24\r\n'
    'Duna: Parte Dois,30/08/24\r\n'
    'Duna,25/08/24\r\n'
    'Cidade de Deus,15/08/26\r\n'
    'Star Wars: Episódio IV: Uma Nova Esperança,04/05/24\r\n'
    'Trailer: Round 6,17/09/21\r\n';

Uint8List sampleNetflixCsvBytes() => Uint8List.fromList(utf8.encode(sampleNetflixCsvText));

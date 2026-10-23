import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/import_netflix/domain/matching_score.dart';

void main() {
  test('espelho da pontuação da função: parcelas e limiares', () {
    double s({MediaType? guess = MediaType.tv, int? year, String title = 'Stranger Things', int exact = 1, double pop = 300}) =>
        scoreCandidate(
          rawName: 'Stranger Things',
          guessedType: guess,
          year: year,
          title: title,
          originalTitle: title,
          mediaType: MediaType.tv,
          resultYear: 2016,
          popularity: pop,
          exactRelevantCount: exact,
        );
    expect(s(year: 2016), 1.0);
    expect(s(), 0.9, reason: 'sem ano: exato + tipo + único exato');
    expect(s(exact: 2), 0.8, reason: 'homônimo relevante tira o bônus');
    expect(s(guess: null), 0.7);
    expect(s(title: 'Stranger Things: Os Bastidores'), 0.5, reason: 'parcial + tipo');
    expect(s(title: 'Dark'), 0.2);
    expect(s(pop: 0.5), 0.8, reason: 'pouco popular não ganha o bônus de único');

    expect(confidenceFor([0.9]), 'high');
    expect(confidenceFor([0.9, 0.8]), 'medium');
    expect(confidenceFor([0.6]), 'medium');
    expect(confidenceFor([0.5]), 'low');
    expect(confidenceFor([]), 'low');
  });

  test('isExactName casa pelo original (anime)', () {
    expect(isExactName('ワンピース', title: 'One Piece', originalTitle: 'ワンピース'), isTrue);
    expect(isExactName('One Piece', title: 'One Piece: Especial'), isFalse);
  });
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/model/media_type.dart';
import '../../catalog/domain/catalog_models.dart';
import 'subscribe_models.dart';

part 'recommendation.freezed.dart';

/// De onde o título candidato veio (SPEC §J5.1): meu "Quero ver"/"Assistindo"
/// pesa 1; o que amigos seguidos assistiram ou avaliaram ≥ 4 nos últimos 30
/// dias (e não está no meu diário) pesa 0,3.
enum CandidateSource {
  mine,
  friends;

  double get weight => this == mine ? 1.0 : friendsWeight;

  static const friendsWeight = 0.3;
}

/// Um título na conta do recomendador.
@freezed
abstract class Candidate with _$Candidate {
  const Candidate._();

  const factory Candidate({
    required String titleId,
    required String name,
    required CandidateSource source,
    MediaType? mediaType,
    int? tmdbId,
    String? posterPath,

    /// `@` de quem assistiu/avaliou, quando a fonte é `friends`.
    String? friendUsername,
  }) = _Candidate;

  double get weight => source.weight;
  bool get isMine => source == CandidateSource.mine;
}

/// Oferta em cache (`title_availability`) já com a variante ("Netflix com
/// anúncios") resolvida para o streaming principal (`providers.parent_id`).
@freezed
abstract class CachedOffer with _$CachedOffer {
  const factory CachedOffer({required int providerId, required OfferType offerType}) = _CachedOffer;
}

/// Entrada do recomendador. Tudo o que ele precisa saber, sem Supabase nem
/// Flutter: a tela monta isto e lê a [Recommendation].
@freezed
abstract class RecommendInput with _$RecommendInput {
  const factory RecommendInput({
    required List<Candidate> candidates,

    /// titleId → ofertas em cache. **Chave ausente = sem dados** (o título
    /// nunca teve "onde assistir" consultado); lista vazia = consultado e não
    /// está em nenhum streaming.
    required Map<String, List<CachedOffer>> availability,

    /// Streamings destacados (`is_featured`), na ordem de exibição.
    required List<StreamingProvider> providers,
    required List<ProviderPrice> prices,

    /// Ids dos streamings que eu já assino (desempate e frase final).
    @Default(<int>{}) Set<int> mySubscriptions,

    /// Chave "aceito plano com anúncios": usa o preço `ads` quando existir.
    @Default(false) bool acceptAds,
    required DateTime now,
  }) = _RecommendInput;
}

/// A conta de um streaming: o que ele resolve e por quanto.
@freezed
abstract class ProviderScore with _$ProviderScore {
  const ProviderScore._();

  const factory ProviderScore({
    required StreamingProvider provider,
    required ProviderPrice price,

    /// Títulos que ele resolve (assinatura, com ou sem anúncios), meus primeiro.
    required List<Candidate> resolved,

    /// Soma dos pesos (meus 1 + amigos 0,3): é o que ordena o ranking.
    required double score,
    @Default(false) bool alreadySubscribed,

    /// `updated_at` do preço com mais de 60 dias.
    @Default(false) bool priceStale,
  }) = _ProviderScore;

  int get resolvedMine => resolved.where((c) => c.isMine).length;
  int get resolvedFriends => resolved.length - resolvedMine;

  /// Preço dividido pelo peso resolvido (meus 1, amigos 0,3). Com só títulos
  /// meus é a conta de cabeça (R$ 39,90 ÷ 8); com títulos de amigos o custo
  /// sobe um pouco, porque eles valem menos. Sem título, o preço inteiro.
  int get costPerTitleCents => score <= 0 ? price.priceCents : (price.priceCents / score).round();
}

/// Título em assinatura que ficou de fora da escolha, com onde ele está.
@freezed
abstract class LeftOutTitle with _$LeftOutTitle {
  const factory LeftOutTitle({required Candidate candidate, required List<StreamingProvider> providers}) = _LeftOutTitle;
}

/// Saída do recomendador (SPEC §5.9 e §J5).
@freezed
abstract class Recommendation with _$Recommendation {
  const Recommendation._();

  const factory Recommendation({
    /// Só quem resolve ≥ 1 título, do melhor para o pior.
    @Default(<ProviderScore>[]) List<ProviderScore> ranking,

    /// Streamings com preço que não resolvem nada (a tela lista os nomes).
    @Default(<StreamingProvider>[]) List<StreamingProvider> resolvingNothing,
    ProviderScore? best,

    /// Segundo streaming, só quando acrescenta ≥ 3 títulos e baixa o custo por título.
    ProviderScore? combo,
    @Default(<Candidate>[]) List<Candidate> comboAdded,

    /// Em assinatura, mas fora do(s) escolhido(s).
    @Default(<LeftOutTitle>[]) List<LeftOutTitle> leftOut,

    /// Só aluguel ou compra.
    @Default(<Candidate>[]) List<Candidate> rentOnly,

    /// Já dá para ver grátis (não precisa assinar nada).
    @Default(<Candidate>[]) List<Candidate> freeOnly,

    /// Só em streaming que não está na lista de preços.
    @Default(<Candidate>[]) List<Candidate> elsewhere,

    /// Cache consultado: em nenhum streaming no Brasil.
    @Default(<Candidate>[]) List<Candidate> unavailable,

    /// Sem cache de "onde assistir": nunca chutar.
    @Default(<Candidate>[]) List<Candidate> noData,
    @Default(0) int totalMine,
    @Default(0) int totalFriends,

    /// O `updated_at` mais recente entre os preços usados ("Preços de
    /// DD/MM/AAAA"); preço velho tem aviso próprio em [ProviderScore.priceStale].
    DateTime? pricesUpdatedAt,
    @Default(false) bool anyEstimate,

    /// Frase final, legível. Null só quando não há candidato nenhum.
    String? headline,
  }) = _Recommendation;

  bool get isEmpty => totalMine == 0 && totalFriends == 0;
  int get total => totalMine + totalFriends;
}

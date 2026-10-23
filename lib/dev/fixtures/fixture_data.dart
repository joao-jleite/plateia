// Dados de amostra do backend de desenvolvimento (`--dart-define=BACKEND=fixtures`).
// Só o que a fase 03 precisa para exercitar Busca → Detalhe → Onde assistir →
// botão. Ids do TMDB são reais; caminhos de pôster só os conferidos no CDN
// público (image.tmdb.org) em 22/10/2026, o resto fica null (placeholder).
// Streamings espelham o seed da migração 0001.

import '../../core/model/media_type.dart';
import '../../features/catalog/domain/catalog_models.dart';
import '../../features/subscribe/domain/subscribe_models.dart';

abstract final class FixtureProviders {
  static const netflix = StreamingProvider(
    id: 8, slug: 'netflix', name: 'Netflix', logoPath: '/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg',
    androidPackage: 'com.netflix.mediaclient', webDomain: 'www.netflix.com',
    searchUrlTemplate: 'https://www.netflix.com/search?q={q}', isFeatured: true, displayOrder: 1,
  );
  static const prime = StreamingProvider(
    id: 119, slug: 'prime', name: 'Prime Video', logoPath: '/emthp39XA2YScoYL1p0sdbAH2WA.jpg',
    androidPackage: 'com.amazon.avod.thirdpartyclient', webDomain: 'www.primevideo.com',
    searchUrlTemplate: 'https://www.primevideo.com/search?phrase={q}', isFeatured: true, displayOrder: 2,
  );
  // Logos do Disney+ e do Paramount+ conferidos no CDN público em 23/10/2026
  // (fase 08; os da fase 03 mostravam Apple TV e Filmbox+). No projeto real o
  // `providers-sync` grava o que o TMDB devolver.
  static const disney = StreamingProvider(
    id: 337, slug: 'disney', name: 'Disney+', logoPath: '/97yvRBw1GzX7fXprcF80er19ot.jpg',
    androidPackage: 'com.disney.disneyplus', webDomain: 'www.disneyplus.com',
    searchUrlTemplate: null, isFeatured: true, displayOrder: 3,
  );
  static const max = StreamingProvider(
    id: 1899, slug: 'max', name: 'HBO Max', logoPath: '/jbe4gVSfRlbPTdESXhEKpornsfu.jpg',
    androidPackage: 'com.wbd.stream', webDomain: 'play.hbomax.com',
    searchUrlTemplate: 'https://play.hbomax.com/search?q={q}', isFeatured: true, displayOrder: 4,
  );
  static const globoplay = StreamingProvider(
    id: 307, slug: 'globoplay', name: 'Globoplay',
    androidPackage: 'com.globo.globotv', webDomain: 'globoplay.globo.com',
    searchUrlTemplate: 'https://globoplay.globo.com/busca/?q={q}', isFeatured: true, displayOrder: 5,
  );
  static const apple = StreamingProvider(
    id: 350, slug: 'apple', name: 'Apple TV+',
    androidPackage: 'com.apple.atve.androidtv.appletv', webDomain: 'tv.apple.com',
    searchUrlTemplate: 'https://tv.apple.com/br/search?term={q}', isFeatured: true, displayOrder: 6,
  );
  static const paramount = StreamingProvider(
    id: 531, slug: 'paramount', name: 'Paramount+', logoPath: '/h5DcR0J2EESLitnhR8xLG1QymTE.jpg',
    androidPackage: 'com.cbs.app', webDomain: 'www.paramountplus.com',
    searchUrlTemplate: 'https://www.paramountplus.com/br/search/?q={q}', isFeatured: true, displayOrder: 7,
  );
  static const crunchyroll = StreamingProvider(
    id: 283, slug: 'crunchyroll', name: 'Crunchyroll', logoPath: '/mXeC4TrcgdU6ltE9bCBCEORwSQR.jpg',
    androidPackage: 'com.crunchyroll.crunchyroid', webDomain: 'www.crunchyroll.com',
    searchUrlTemplate: 'https://www.crunchyroll.com/pt-br/search?q={q}', isFeatured: true, displayOrder: 8,
  );

  /// Variante que agrupa no principal na interface.
  static const netflixAds = StreamingProvider(
    id: 1796, name: 'Netflix com anúncios', logoPath: '/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg', parentId: 8,
  );

  static const all = [netflix, prime, disney, max, globoplay, apple, paramount, crunchyroll, netflixAds];
  static Map<int, StreamingProvider> get byId => {for (final p in all) p.id: p};
}

/// Um título de amostra com a disponibilidade que a Edge Function devolveria.
class FixtureTitle {
  const FixtureTitle({required this.title, required this.availability, this.linksStatus = 'ok', this.providersCached = true});

  final Title title;
  final List<Availability> availability;
  final String linksStatus;

  /// `false` = "onde assistir" nunca foi consultado para este título (como um
  /// título que entrou pela importação da Netflix e ainda não foi aberto): a
  /// aba Assinar mostra "sem dados" até alguém abrir o detalhe (fase 07).
  final bool providersCached;

  CatalogItem get item => CatalogItem(
        tmdbId: title.tmdbId,
        mediaType: title.mediaType,
        title: title.title,
        year: title.year,
        posterPath: title.posterPath,
        isAnime: title.isAnime,
      );
}

final _fetched = DateTime(2026, 10, 22, 9, 0);

Availability _offer(StreamingProvider p, OfferType type, {String? link, int? price}) => Availability(
      providerId: p.id,
      offerType: type,
      deepLink: link,
      deepLinkSource: link == null ? null : 'motn',
      priceCents: price,
      fetchedAt: _fetched,
      linkFetchedAt: link == null ? null : _fetched,
      provider: p,
    );

final fixtureTitles = <FixtureTitle>[
  // O caso do "Pronto quando": busca "One Piece" → detalhe → Netflix com link direto.
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000037854',
      tmdbId: 37854,
      mediaType: MediaType.tv,
      title: 'One Piece',
      originalTitle: 'ワンピース',
      overview:
          'Monkey D. Luffy quer ser o Rei dos Piratas. Com um corpo de borracha e uma tripulação improvável, ele cruza a Grand Line atrás do One Piece, o tesouro deixado por Gol D. Roger.',
      posterPath: '/cMD9Ygz11zjJzAovURpO75Qg7rT.jpg',
      releaseDate: DateTime(1999, 10, 20),
      year: 1999,
      genres: const ['Animação', 'Action & Adventure', 'Comédia'],
      isAnime: true,
      episodeRunTime: 24,
      numberOfSeasons: 22,
      numberOfEpisodes: 1140,
      seasons: [
        Season(seasonNumber: 1, name: 'East Blue', episodeCount: 61, airDate: DateTime(1999, 10, 20)),
        Season(seasonNumber: 2, name: 'Entrada na Grand Line', episodeCount: 16, airDate: DateTime(2001, 3, 21)),
        Season(seasonNumber: 21, name: 'Wano', episodeCount: 195, airDate: DateTime(2019, 7, 7)),
        Season(seasonNumber: 22, name: 'Egghead', episodeCount: 62, airDate: DateTime(2024, 1, 7)),
      ],
      castTop: const [
        CastMember(name: 'Mayumi Tanaka', character: 'Monkey D. Luffy (voz)'),
        CastMember(name: 'Kazuya Nakai', character: 'Roronoa Zoro (voz)'),
        CastMember(name: 'Akemi Okamura', character: 'Nami (voz)'),
        CastMember(name: 'Kappei Yamaguchi', character: 'Usopp (voz)'),
        CastMember(name: 'Hiroaki Hirata', character: 'Sanji (voz)'),
      ],
      status: 'Returning Series',
      voteAverage: 8.7,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.netflix, OfferType.flatrate, link: 'https://www.netflix.com/title/80107103'),
      _offer(FixtureProviders.netflixAds, OfferType.ads, link: 'https://www.netflix.com/title/80107103'),
      _offer(FixtureProviders.crunchyroll, OfferType.flatrate, link: 'https://www.crunchyroll.com/pt-br/series/GRMG8ZQZR/one-piece'),
      _offer(FixtureProviders.crunchyroll, OfferType.ads),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000111110',
      tmdbId: 111110,
      mediaType: MediaType.tv,
      title: 'One Piece',
      originalTitle: 'One Piece',
      overview:
          'Versão live-action: Luffy e os Chapéus de Palha partem em busca do maior tesouro do mundo.',
      releaseDate: DateTime(2023, 8, 31),
      year: 2023,
      genres: const ['Action & Adventure', 'Comédia', 'Drama'],
      numberOfSeasons: 2,
      numberOfEpisodes: 16,
      episodeRunTime: 60,
      seasons: [
        Season(seasonNumber: 1, name: 'Temporada 1', episodeCount: 8, airDate: DateTime(2023, 8, 31)),
        Season(seasonNumber: 2, name: 'Temporada 2', episodeCount: 8, airDate: DateTime(2026, 3, 10)),
      ],
      castTop: const [
        CastMember(name: 'Iñaki Godoy', character: 'Monkey D. Luffy'),
        CastMember(name: 'Mackenyu', character: 'Roronoa Zoro'),
        CastMember(name: 'Emily Rudd', character: 'Nami'),
      ],
      status: 'Returning Series',
      voteAverage: 8.2,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.netflix, OfferType.flatrate, link: 'https://www.netflix.com/title/80217863'),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000066732',
      tmdbId: 66732,
      mediaType: MediaType.tv,
      title: 'Stranger Things',
      overview: 'Hawkins, anos 80: um garoto some e sua turma descobre forças sobrenaturais e um laboratório secreto.',
      posterPath: '/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
      releaseDate: DateTime(2016, 7, 15),
      year: 2016,
      genres: const ['Drama', 'Sci-Fi & Fantasy', 'Mistério'],
      numberOfSeasons: 5,
      numberOfEpisodes: 42,
      episodeRunTime: 55,
      castTop: const [CastMember(name: 'Millie Bobby Brown', character: 'Eleven'), CastMember(name: 'Finn Wolfhard', character: 'Mike Wheeler')],
      status: 'Ended',
      voteAverage: 8.6,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.netflix, OfferType.flatrate, link: 'https://www.netflix.com/title/80057281'),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000100088',
      tmdbId: 100088,
      mediaType: MediaType.tv,
      title: 'The Last of Us',
      overview: 'Vinte anos após uma pandemia fúngica, Joel atravessa os EUA escoltando Ellie, que pode ser a chave da cura.',
      posterPath: '/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
      releaseDate: DateTime(2023, 1, 15),
      year: 2023,
      genres: const ['Drama', 'Sci-Fi & Fantasy'],
      numberOfSeasons: 2,
      numberOfEpisodes: 16,
      episodeRunTime: 55,
      castTop: const [CastMember(name: 'Pedro Pascal', character: 'Joel'), CastMember(name: 'Bella Ramsey', character: 'Ellie')],
      status: 'Returning Series',
      voteAverage: 8.6,
      fetchedAt: _fetched,
    ),
    // Link da MOTN vindo como play.max.com: o app normaliza para play.hbomax.com.
    availability: [
      _offer(FixtureProviders.max, OfferType.flatrate, link: 'https://play.max.com/show/urn:hbo:series:GYdGMQQ7H8kgGvwEAAAAK'),
      _offer(FixtureProviders.prime, OfferType.buy, price: 5990),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000136315',
      tmdbId: 136315,
      mediaType: MediaType.tv,
      title: 'O Urso',
      originalTitle: 'The Bear',
      overview: 'Carmy, um jovem chef da alta gastronomia, volta a Chicago para tocar a lanchonete da família.',
      posterPath: '/sHFlbKS3WLqMnp9t2ghADIJFnuQ.jpg',
      releaseDate: DateTime(2022, 6, 23),
      year: 2022,
      genres: const ['Comédia', 'Drama'],
      numberOfSeasons: 4,
      numberOfEpisodes: 38,
      episodeRunTime: 30,
      status: 'Returning Series',
      voteAverage: 8.3,
      fetchedAt: _fetched,
    ),
    // Disney+ sem link e sem busca: botão "Abrir o Disney+".
    availability: [_offer(FixtureProviders.disney, OfferType.flatrate)],
    linksStatus: 'not_found',
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000095557',
      tmdbId: 95557,
      mediaType: MediaType.tv,
      title: 'Arcanjo Renegado',
      overview: 'Mikhael, policial do BOPE, tenta deixar a corporação enquanto a corrupção e a violência no Rio o puxam de volta.',
      releaseDate: DateTime(2020, 2, 7),
      year: 2020,
      genres: const ['Action & Adventure', 'Drama', 'Crime'],
      numberOfSeasons: 4,
      numberOfEpisodes: 32,
      episodeRunTime: 50,
      status: 'Returning Series',
      voteAverage: 7.9,
      fetchedAt: _fetched,
    ),
    // Globoplay: nenhuma fonte dá o id do título lá → "Buscar no Globoplay".
    availability: [_offer(FixtureProviders.globoplay, OfferType.flatrate)],
    linksStatus: 'not_found',
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000209867',
      tmdbId: 209867,
      mediaType: MediaType.tv,
      title: 'Frieren e a Jornada para o Além',
      originalTitle: '葬送のフリーレン',
      overview: 'Depois de derrotar o Rei Demônio, a maga elfa Frieren vê seus companheiros humanos envelhecerem e parte numa nova jornada.',
      posterPath: '/dqZENchTd7lp5zht7BdlqM7RBhD.jpg',
      releaseDate: DateTime(2023, 9, 29),
      year: 2023,
      genres: const ['Animação', 'Drama', 'Sci-Fi & Fantasy'],
      isAnime: true,
      numberOfSeasons: 2,
      numberOfEpisodes: 28,
      episodeRunTime: 24,
      status: 'Returning Series',
      voteAverage: 8.8,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.crunchyroll, OfferType.flatrate, link: 'https://www.crunchyroll.com/pt-br/series/GG5H5XQ0D/frieren-beyond-journeys-end'),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000872585',
      tmdbId: 872585,
      mediaType: MediaType.movie,
      title: 'Oppenheimer',
      overview: 'A história do físico J. Robert Oppenheimer e do Projeto Manhattan, que criou a bomba atômica.',
      posterPath: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      releaseDate: DateTime(2023, 7, 20),
      year: 2023,
      genres: const ['Drama', 'História'],
      runtimeMinutes: 181,
      castTop: const [CastMember(name: 'Cillian Murphy', character: 'J. Robert Oppenheimer'), CastMember(name: 'Emily Blunt', character: 'Kitty Oppenheimer')],
      status: 'Released',
      voteAverage: 8.1,
      fetchedAt: _fetched,
    ),
    // Só aluguel e compra, com preço: chips mostram o valor.
    availability: [
      _offer(FixtureProviders.apple, OfferType.rent, price: 1490),
      _offer(FixtureProviders.apple, OfferType.buy, price: 3990),
      _offer(FixtureProviders.prime, OfferType.rent, price: 1490),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000693134',
      tmdbId: 693134,
      mediaType: MediaType.movie,
      title: 'Duna: Parte Dois',
      originalTitle: 'Dune: Part Two',
      overview: 'Paul Atreides se une aos Fremen para vingar a família e evitar um futuro terrível que só ele enxerga.',
      posterPath: '/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
      releaseDate: DateTime(2024, 2, 27),
      year: 2024,
      genres: const ['Ficção científica', 'Aventura'],
      runtimeMinutes: 167,
      status: 'Released',
      voteAverage: 8.2,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.max, OfferType.flatrate, link: 'https://play.hbomax.com/movie/urn:hbo:movie:GYutKkwXfDMEOwQEAAAAW'),
      _offer(FixtureProviders.apple, OfferType.buy, price: 4990),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000073586',
      tmdbId: 73586,
      mediaType: MediaType.tv,
      title: 'Yellowstone',
      overview: 'A família Dutton luta para manter o maior rancho dos EUA contra incorporadoras, uma reserva indígena e o parque nacional.',
      posterPath: '/peNC0eyc3TQJa6x4TdKcBPNP4t0.jpg',
      releaseDate: DateTime(2018, 6, 20),
      year: 2018,
      genres: const ['Western', 'Drama'],
      numberOfSeasons: 5,
      numberOfEpisodes: 53,
      episodeRunTime: 50,
      status: 'Ended',
      voteAverage: 8.2,
      fetchedAt: _fetched,
    ),
    availability: [_offer(FixtureProviders.paramount, OfferType.flatrate)],
    linksStatus: 'quota',
  ),
  // Título sem disponibilidade: estado vazio da seção Onde assistir.
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000000598',
      tmdbId: 598,
      mediaType: MediaType.movie,
      title: 'Cidade de Deus',
      overview: 'Buscapé cresce numa favela do Rio e narra duas décadas de violência pelas lentes da sua câmera.',
      releaseDate: DateTime(2002, 8, 30),
      year: 2002,
      genres: const ['Drama', 'Crime'],
      runtimeMinutes: 130,
      status: 'Released',
      voteAverage: 8.4,
      fetchedAt: _fetched,
    ),
    availability: const [],
    linksStatus: 'not_found',
  ),
  // ---- fase 07: títulos para a aba Assinar ter uma conta de verdade ----------
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000076331',
      tmdbId: 76331,
      mediaType: MediaType.tv,
      title: 'Succession',
      overview: 'Os Roy disputam o controle do conglomerado de mídia da família enquanto o patriarca Logan decide quem o sucede.',
      releaseDate: DateTime(2018, 6, 3),
      year: 2018,
      genres: const ['Drama'],
      numberOfSeasons: 4,
      numberOfEpisodes: 39,
      episodeRunTime: 60,
      status: 'Ended',
      voteAverage: 8.3,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.max, OfferType.flatrate, link: 'https://play.hbomax.com/show/urn:hbo:series:GWoD5-AWuOgLDwwEAAAFd'),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000111803',
      tmdbId: 111803,
      mediaType: MediaType.tv,
      title: 'The White Lotus',
      overview: 'Hóspedes e funcionários de um resort de luxo se enredam ao longo de uma semana que termina em morte.',
      releaseDate: DateTime(2021, 7, 11),
      year: 2021,
      genres: const ['Comédia', 'Drama', 'Mistério'],
      numberOfSeasons: 3,
      numberOfEpisodes: 21,
      episodeRunTime: 60,
      status: 'Returning Series',
      voteAverage: 7.9,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.max, OfferType.flatrate, link: 'https://play.hbomax.com/show/urn:hbo:series:GYJ6hLwnbhgKlMwEAAAIR'),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000095396',
      tmdbId: 95396,
      mediaType: MediaType.tv,
      title: 'Ruptura',
      originalTitle: 'Severance',
      overview: 'Funcionários da Lumon aceitam separar cirurgicamente as memórias do trabalho das da vida pessoal.',
      releaseDate: DateTime(2022, 2, 17),
      year: 2022,
      genres: const ['Drama', 'Mistério', 'Sci-Fi & Fantasy'],
      numberOfSeasons: 2,
      numberOfEpisodes: 19,
      episodeRunTime: 50,
      status: 'Returning Series',
      voteAverage: 8.4,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.apple, OfferType.flatrate, link: 'https://tv.apple.com/br/show/ruptura/umc.cmc.1srk2goyh2q2zdxcx605w8vtx'),
    ],
  ),
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000194764',
      tmdbId: 194764,
      mediaType: MediaType.tv,
      title: 'Pinguim',
      originalTitle: 'The Penguin',
      overview: 'Depois da queda de Carmine Falcone, Oz Cobb tenta tomar o submundo de Gotham.',
      releaseDate: DateTime(2024, 9, 19),
      year: 2024,
      genres: const ['Crime', 'Drama'],
      numberOfSeasons: 1,
      numberOfEpisodes: 8,
      episodeRunTime: 60,
      status: 'Ended',
      voteAverage: 8.5,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.max, OfferType.flatrate, link: 'https://play.hbomax.com/show/urn:hbo:series:GZuQzRQfQJ4PDwwEAAACy'),
    ],
  ),
  // Entrou no diário sem ninguém abrir o detalhe: sem cache de "onde assistir"
  // → a aba Assinar mostra "sem dados" até o detalhe ser aberto.
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000241259',
      tmdbId: 241259,
      mediaType: MediaType.tv,
      title: 'Bebê Rena',
      originalTitle: 'Baby Reindeer',
      overview: 'Um comediante em início de carreira é perseguido por uma mulher a quem ofereceu uma xícara de chá.',
      releaseDate: DateTime(2024, 4, 11),
      year: 2024,
      genres: const ['Drama', 'Crime'],
      numberOfSeasons: 1,
      numberOfEpisodes: 7,
      episodeRunTime: 32,
      status: 'Ended',
      voteAverage: 7.9,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.netflix, OfferType.flatrate, link: 'https://www.netflix.com/title/81219887'),
    ],
    providersCached: false,
  ),
  // Só aluguel e compra: aparece "à parte" na aba Assinar.
  FixtureTitle(
    title: Title(
      id: 'f1a0b2c3-0000-4000-8000-000000786892',
      tmdbId: 786892,
      mediaType: MediaType.movie,
      title: 'Furiosa: Uma Saga Mad Max',
      originalTitle: 'Furiosa: A Mad Max Saga',
      overview: 'Sequestrada do Lugar Verde, a jovem Furiosa cruza a Terra Devastada entre o senhor da guerra Dementus e o Immortan Joe.',
      releaseDate: DateTime(2024, 5, 22),
      year: 2024,
      genres: const ['Ação', 'Aventura', 'Ficção científica'],
      runtimeMinutes: 148,
      status: 'Released',
      voteAverage: 7.6,
      fetchedAt: _fetched,
    ),
    availability: [
      _offer(FixtureProviders.prime, OfferType.rent, price: 1490),
      _offer(FixtureProviders.apple, OfferType.buy, price: 4990),
    ],
  ),
];

/// Preços de referência da aba Assinar: espelham o seed de `provider_prices`
/// (migração 0001), todos **estimativa** (`isEstimate`) até o João conferir.
/// O do Paramount+ está propositalmente velho (agosto) para a tela mostrar o
/// aviso de preço com mais de 60 dias.
abstract final class FixturePrices {
  static final updatedAt = DateTime(2026, 10, 22, 9, 0);
  static final staleAt = DateTime(2026, 8, 1, 9, 0);

  static ProviderPrice _p(int providerId, PricePlan plan, String label, int cents, {DateTime? at}) => ProviderPrice(
        providerId: providerId,
        plan: plan,
        planLabel: label,
        priceCents: cents,
        isEstimate: true,
        updatedAt: at ?? updatedAt,
      );

  static final all = <ProviderPrice>[
    _p(8, PricePlan.ads, 'Padrão com anúncios', 2090),
    _p(8, PricePlan.standard, 'Padrão', 4490),
    _p(8, PricePlan.premium, 'Premium', 5990),
    _p(119, PricePlan.standard, 'Prime (mensal)', 1990),
    _p(337, PricePlan.ads, 'Padrão com anúncios', 2790),
    _p(337, PricePlan.standard, 'Padrão', 4390),
    _p(337, PricePlan.premium, 'Premium', 6690),
    _p(1899, PricePlan.ads, 'Básico com anúncios', 2990),
    _p(1899, PricePlan.standard, 'Padrão', 3990),
    _p(1899, PricePlan.premium, 'Platinum', 5590),
    _p(307, PricePlan.standard, 'Padrão', 2490),
    _p(350, PricePlan.standard, 'Apple TV+', 2190),
    _p(531, PricePlan.standard, 'Padrão', 1990, at: staleAt),
    _p(283, PricePlan.standard, 'Fan', 1699),
    _p(283, PricePlan.premium, 'Mega Fan', 2299),
  ];
}

HomeSections fixtureHomeSections() {
  CatalogItem item(int tmdbId) => fixtureTitles.firstWhere((t) => t.title.tmdbId == tmdbId).item;
  return HomeSections(
    fetchedAt: DateTime.now().subtract(const Duration(hours: 2)),
    sections: [
      HomeSection(key: 'trending_all', title: 'Em alta no Brasil', items: [
        item(37854), item(100088), item(693134), item(136315), item(209867), item(872585), item(95557),
      ]),
      HomeSection(key: 'new_on_8', title: 'Novidades na Netflix', items: [item(111110), item(37854), item(66732)]),
      HomeSection(key: 'new_on_1899', title: 'Novidades na HBO Max', items: [item(100088), item(693134)]),
      HomeSection(key: 'new_on_337', title: 'Novidades no Disney+', items: [item(136315)]),
      HomeSection(key: 'new_on_307', title: 'Novidades no Globoplay', items: [item(95557)]),
      HomeSection(key: 'new_on_283', title: 'Novidades na Crunchyroll', items: [item(209867), item(37854)]),
      HomeSection(key: 'new_on_531', title: 'Novidades no Paramount+', items: [item(73586)]),
      const HomeSection(key: 'new_on_119', title: 'Novidades no Prime Video', items: []),
      const HomeSection(key: 'new_on_350', title: 'Novidades na Apple TV+', items: []),
    ],
  );
}

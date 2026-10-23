import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Caminho do logo oficial do TMDB. Claude não baixa arquivo de terceiros: o
/// João salva o SVG azul de themoviedb.org/about/logos-attribution aqui e o
/// app passa a mostrá-lo sozinho (docs/PENDENCIAS-JOAO.md). Enquanto o arquivo
/// não existe, fica o selo de texto "TMDB".
const tmdbLogoAsset = 'assets/tmdb/logo.svg';

/// `true` quando `assets/tmdb/logo.svg` está empacotado no app.
final tmdbLogoAvailableProvider = FutureProvider<bool>((ref) async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().contains(tmdbLogoAsset);
  } catch (_) {
    return false;
  }
});

/// Marca do TMDB para a atribuição obrigatória: logo oficial se existir, senão
/// um selo de texto. [height] é a altura do logo (o selo acompanha).
class TmdbBadge extends ConsumerWidget {
  const TmdbBadge({super.key, this.height = 14});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLogo = ref.watch(tmdbLogoAvailableProvider).value ?? false;
    final scheme = Theme.of(context).colorScheme;
    if (hasLogo) {
      return Semantics(
        label: 'TMDB',
        image: true,
        child: SvgPicture.asset(tmdbLogoAsset, height: height, fit: BoxFit.contain),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: height * 0.6, vertical: height * 0.25),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'TMDB',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: height * 0.8, color: scheme.onSecondaryContainer, letterSpacing: 0.5),
      ),
    );
  }
}

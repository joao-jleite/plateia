import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema "Sala escura" (docs/DESIGN.md, direção A): preto quente, dourado como
/// cor de destaque e de nota, Fraunces nos títulos e Manrope no resto.
///
/// [withGoogleFonts] = false deixa a tipografia no Roboto: é o que os testes
/// de widget usam (o `google_fonts` tentaria baixar a fonte e o `HttpClient`
/// do flutter_test devolve 400). No app a fonte é baixada uma vez e fica em
/// cache no aparelho; sem rede o Android cai no Roboto sem quebrar o layout.
abstract final class AppTheme {
  // Paleta (docs/DESIGN.md). Contraste AA conferido para cada par usado.
  static const background = Color(0xFF0E0D12);
  static const surface = Color(0xFF17161D);
  static const surfaceHigh = Color(0xFF22212A);
  static const surfaceHighest = Color(0xFF2B2A34);
  static const gold = Color(0xFFF2B544);
  static const onGold = Color(0xFF2A1D00);
  static const goldContainer = Color(0xFF4A3406);
  static const onGoldContainer = Color(0xFFFFDFA3);
  static const velvet = Color(0xFFE8899A);
  static const velvetContainer = Color(0xFF4E1F2A);
  static const teal = Color(0xFF6FD3BE);
  static const tealContainer = Color(0xFF0F3F37);
  static const ivory = Color(0xFFF3EFE6);
  static const ivoryMuted = Color(0xFFA9A49A);
  static const outline = Color(0xFF938F87);
  static const outlineVariant = Color(0xFF2B2A34);

  /// Semente para o tema claro (só por completude; o app abre escuro).
  static const seed = gold;

  static ThemeData dark({bool withGoogleFonts = true}) => _build(_darkScheme, withGoogleFonts);

  static ThemeData light({bool withGoogleFonts = true}) => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        withGoogleFonts,
      );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: gold,
    onPrimary: onGold,
    primaryContainer: goldContainer,
    onPrimaryContainer: onGoldContainer,
    secondary: velvet,
    onSecondary: Color(0xFF3A0E17),
    secondaryContainer: velvetContainer,
    onSecondaryContainer: Color(0xFFFFD9DF),
    tertiary: teal,
    onTertiary: Color(0xFF00382E),
    tertiaryContainer: tealContainer,
    onTertiaryContainer: Color(0xFFBFF2E6),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF4A0400),
    errorContainer: Color(0xFF5C1F1B),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: background,
    onSurface: ivory,
    onSurfaceVariant: ivoryMuted,
    surfaceDim: Color(0xFF0A090D),
    surfaceBright: Color(0xFF34333D),
    surfaceContainerLowest: Color(0xFF0A090D),
    surfaceContainerLow: Color(0xFF131218),
    surfaceContainer: surface,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ivory,
    onInverseSurface: background,
    inversePrimary: Color(0xFF7A5600),
    surfaceTint: gold,
  );

  static ThemeData _build(ColorScheme scheme, bool withGoogleFonts) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = _textTheme(base.textTheme, scheme, withGoogleFonts);
    final shape12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final buttonText = text.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2);

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      // Transição discreta entre telas (Material 3): fade com leve deslize,
      // em vez de arrastar a tela inteira.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: scheme.surfaceContainer,
        shape: shape12.copyWith(side: BorderSide(color: scheme.outlineVariant)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.error, width: 1.5)),
      ),
      // Botões: 48 de altura e largura mínima padrão (64). Botão de formulário
      // ocupa a largura toda porque o pai estica (`CrossAxisAlignment.stretch`
      // ou `Expanded`), não pelo tema: a largura infinita no tema empilhava os
      // botões dos diálogos e estourava dentro de `Row` (fase 06).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outline),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 40), textStyle: buttonText),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape12,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        subtitleTextStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: scheme.primary,
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        dividerColor: scheme.outlineVariant,
        labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: text.labelLarge,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary, linearTrackColor: scheme.surfaceContainerHighest),
      popupMenuTheme: PopupMenuThemeData(color: scheme.surfaceContainerHigh, shape: shape12),
      badgeTheme: BadgeThemeData(backgroundColor: scheme.secondary, textColor: scheme.onSecondary),
    );
  }

  /// Manrope no corpo e Fraunces (serifa, peso 600) do título de tela para cima.
  static TextTheme _textTheme(TextTheme base, ColorScheme scheme, bool withGoogleFonts) {
    final body = withGoogleFonts ? GoogleFonts.manropeTextTheme(base) : base;
    TextStyle? heading(TextStyle? s, {double? size, double? height}) {
      final style = (s ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        fontSize: size ?? s?.fontSize,
        height: height,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      );
      return withGoogleFonts ? GoogleFonts.fraunces(textStyle: style) : style;
    }

    return body
        .copyWith(
          displayLarge: heading(body.displayLarge),
          displayMedium: heading(body.displayMedium),
          displaySmall: heading(body.displaySmall, size: 34, height: 1.1),
          headlineLarge: heading(body.headlineLarge),
          headlineMedium: heading(body.headlineMedium, size: 26, height: 1.15),
          headlineSmall: heading(body.headlineSmall, size: 22, height: 1.2),
          titleLarge: heading(body.titleLarge, size: 22, height: 1.25),
          titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0),
          titleSmall: body.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          bodyLarge: body.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
          bodyMedium: body.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
          labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}

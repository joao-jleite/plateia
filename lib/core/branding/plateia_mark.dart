import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A marca do Plateia (docs/DESIGN.md): a tela acesa (barra dourada) e três
/// fileiras de assentos em curva; um assento da fileira do meio é dourado (a
/// pessoa). Geometria num quadrado de 1024, escalada para o tamanho pedido.
///
/// É a mesma geometria em três lugares: aqui (splash e login), nos PNGs do
/// ícone/splash do Android e no `assets/branding/plateia_mark.svg`, todos
/// gerados por `tool/branding/render_branding_test.dart`.
class PlateiaMark extends StatelessWidget {
  const PlateiaMark({super.key, this.size = 96, this.withBackground = false});

  final double size;

  /// Pinta o fundo escuro arredondado por trás (ícone legado / cartão).
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Plateia',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: PlateiaMarkPainter(withBackground: withBackground),
      ),
    );
  }
}

/// Um assento da plateia, em coordenadas do quadrado de 1024.
class Seat {
  const Seat(this.cx, this.cy, this.color);

  final double cx;
  final double cy;
  final Color color;
}

/// Geometria pura (sem Flutter além de `Color`/`Rect`): o renderer do SVG e o
/// painter leem daqui.
abstract final class PlateiaGeometry {
  static const double canvas = 1024;
  static const double cornerRadius = 220;

  static const Rect screen = Rect.fromLTWH(312, 322, 400, 60);
  static const double screenRadius = 16;
  static const Rect glow = Rect.fromLTWH(284, 294, 456, 116);
  static const double glowRadius = 40;
  static final Color glowColor = AppTheme.gold.withValues(alpha: 0.12);

  static const double seatWidth = 62;
  static const double seatHeight = 46;
  static const double seatRadius = 14;
  static const double seatGap = 22;

  /// Fileiras (do fundo para a frente): quantos assentos, y do centro e opacidade.
  static const rows = [(count: 4, y: 500.0, alpha: 0.92), (count: 5, y: 590.0, alpha: 0.72), (count: 6, y: 680.0, alpha: 0.50)];

  /// Posição (fileira, índice) do assento dourado.
  static const highlighted = (row: 1, index: 2);

  static List<Seat> seats() {
    final out = <Seat>[];
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final width = row.count * seatWidth + (row.count - 1) * seatGap;
      final startX = (canvas - width) / 2 + seatWidth / 2;
      final half = width / 2;
      for (var i = 0; i < row.count; i++) {
        final cx = startX + i * (seatWidth + seatGap);
        // Fileira em curva: as pontas sobem um pouco (-14 no máximo).
        final dx = (cx - canvas / 2) / half;
        final cy = row.y - 14 * dx * dx;
        final isGold = r == highlighted.row && i == highlighted.index;
        out.add(Seat(cx, cy, isGold ? AppTheme.gold : AppTheme.ivory.withValues(alpha: row.alpha)));
      }
    }
    return out;
  }
}

class PlateiaMarkPainter extends CustomPainter {
  const PlateiaMarkPainter({this.withBackground = false, this.contentScale = 1});

  final bool withBackground;

  /// Amplia a marca em volta do centro (1,3 na camada do ícone adaptativo,
  /// que o Android recorta em círculo: a marca em 1,0 ficava miúda).
  final double contentScale;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / PlateiaGeometry.canvas;
    canvas.save();
    canvas.translate((size.width - size.shortestSide) / 2, (size.height - size.shortestSide) / 2);
    canvas.scale(scale);

    if (withBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, PlateiaGeometry.canvas, PlateiaGeometry.canvas), const Radius.circular(PlateiaGeometry.cornerRadius)),
        Paint()..color = AppTheme.background,
      );
    }

    if (contentScale != 1) {
      const c = PlateiaGeometry.canvas / 2;
      canvas.translate(c, c);
      canvas.scale(contentScale);
      canvas.translate(-c, -c);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(PlateiaGeometry.glow, const Radius.circular(PlateiaGeometry.glowRadius)),
      Paint()..color = PlateiaGeometry.glowColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(PlateiaGeometry.screen, const Radius.circular(PlateiaGeometry.screenRadius)),
      Paint()..color = AppTheme.gold,
    );

    final paint = Paint();
    for (final seat in PlateiaGeometry.seats()) {
      paint.color = seat.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(seat.cx, seat.cy), width: PlateiaGeometry.seatWidth, height: PlateiaGeometry.seatHeight),
          const Radius.circular(PlateiaGeometry.seatRadius),
        ),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PlateiaMarkPainter oldDelegate) =>
      oldDelegate.withBackground != withBackground || oldDelegate.contentScale != contentScale;
}

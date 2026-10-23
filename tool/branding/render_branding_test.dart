// Gera os arquivos da marca a partir da geometria do app (uma fonte só):
//   assets/branding/plateia_mark.svg        marca em SVG (escrita à mão, pela geometria)
//   assets/branding/icon_legacy.png         1024, com fundo (ícone pré-Android 8)
//   assets/branding/icon_foreground.png     1024, sem fundo (camada do ícone adaptativo)
//   assets/branding/splash_mark.png         512, sem fundo (splash pré-Android 12)
//   assets/branding/splash_android12.png    1152, sem fundo (splash do Android 12+)
//
// Roda como teste de widget porque `Picture.toImage` precisa do motor do Flutter:
//   flutter test tool/branding/render_branding_test.dart
// Depois: `dart run flutter_launcher_icons` e `dart run flutter_native_splash:create`.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/branding/plateia_mark.dart';
import 'package:watchlog/core/theme/app_theme.dart';

Future<void> _png(String path, int size, {required bool withBackground, double contentScale = 1}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  PlateiaMarkPainter(withBackground: withBackground, contentScale: contentScale).paint(canvas, Size.square(size.toDouble()));
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
}

String _hex(Color c) {
  final argb = c.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

String _opacity(Color c) => (c.a).toStringAsFixed(2);

String _svg() {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<!-- Marca do Plateia. Gerada por tool/branding/render_branding_test.dart a partir de lib/core/branding/plateia_mark.dart. -->')
    ..writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">')
    ..writeln('  <rect width="1024" height="1024" rx="${PlateiaGeometry.cornerRadius.toInt()}" fill="${_hex(AppTheme.background)}"/>')
    ..writeln('  <rect x="${PlateiaGeometry.glow.left.toInt()}" y="${PlateiaGeometry.glow.top.toInt()}" width="${PlateiaGeometry.glow.width.toInt()}" height="${PlateiaGeometry.glow.height.toInt()}" rx="${PlateiaGeometry.glowRadius.toInt()}" fill="${_hex(AppTheme.gold)}" fill-opacity="${_opacity(PlateiaGeometry.glowColor)}"/>')
    ..writeln('  <rect x="${PlateiaGeometry.screen.left.toInt()}" y="${PlateiaGeometry.screen.top.toInt()}" width="${PlateiaGeometry.screen.width.toInt()}" height="${PlateiaGeometry.screen.height.toInt()}" rx="${PlateiaGeometry.screenRadius.toInt()}" fill="${_hex(AppTheme.gold)}"/>');
  for (final seat in PlateiaGeometry.seats()) {
    final x = (seat.cx - PlateiaGeometry.seatWidth / 2).toStringAsFixed(1);
    final y = (seat.cy - PlateiaGeometry.seatHeight / 2).toStringAsFixed(1);
    b.writeln('  <rect x="$x" y="$y" width="${PlateiaGeometry.seatWidth.toInt()}" height="${PlateiaGeometry.seatHeight.toInt()}" rx="${PlateiaGeometry.seatRadius.toInt()}" fill="${_hex(seat.color)}" fill-opacity="${_opacity(seat.color)}"/>');
  }
  b.writeln('</svg>');
  return b.toString();
}

void main() {
  testWidgets('renderiza a marca em SVG e PNG', (tester) async {
    await tester.runAsync(() async {
      const dir = 'assets/branding';
      await Directory(dir).create(recursive: true);
      await File('$dir/plateia_mark.svg').writeAsString(_svg(), flush: true);
      await _png('$dir/icon_legacy.png', 1024, withBackground: true);
      // camada do adaptativo: o Android mostra só o círculo central (66%); 1,3 enche sem cortar
      await _png('$dir/icon_foreground.png', 1024, withBackground: false, contentScale: 1.3);
      await _png('$dir/splash_mark.png', 512, withBackground: false);
      await _png('$dir/splash_android12.png', 1152, withBackground: false);
      expect(File('$dir/icon_legacy.png').lengthSync(), greaterThan(1000));
    });
  });
}

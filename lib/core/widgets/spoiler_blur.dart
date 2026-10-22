import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Texto marcado como spoiler aparece borrado até a pessoa tocar em
/// "Mostrar spoiler" (SPEC §5.6). Sem spoiler, só devolve o filho.
class SpoilerBlur extends StatefulWidget {
  const SpoilerBlur({super.key, required this.hasSpoiler, required this.child});

  final bool hasSpoiler;
  final Widget child;

  @override
  State<SpoilerBlur> createState() => _SpoilerBlurState();
}

class _SpoilerBlurState extends State<SpoilerBlur> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasSpoiler || _revealed) return widget.child;
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      // Sem clip: o chip "Mostrar spoiler" é mais alto que uma review de uma linha.
      clipBehavior: Clip.none,
      children: [
        // ExcludeSemantics: o leitor de tela não deve ler o spoiler escondido.
        ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7, tileMode: TileMode.decal),
              child: widget.child,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: scheme.surface.withValues(alpha: 0.35),
            child: InkWell(
              onTap: () => setState(() => _revealed = true),
              child: Center(
                child: Chip(
                  avatar: Icon(Icons.visibility_off_outlined, size: 16, color: scheme.onSecondaryContainer),
                  label: const Text('Mostrar spoiler'),
                  backgroundColor: scheme.secondaryContainer,
                  labelStyle: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

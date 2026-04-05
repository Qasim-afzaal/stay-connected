import 'package:flutter/material.dart';

/// Platform logo + optional name for app bars (matches home / drawer where applicable).
class PlatformAppBarTitle extends StatelessWidget {
  const PlatformAppBarTitle({
    super.key,
    this.label,
    required this.iconAsset,
    this.iconSize = 26,
    this.iconOnly = false,
    /// Passed to [Image.asset]; some bundled PNGs use non-1.0 scale (e.g. TikTok).
    this.imageScale,
    /// In dark mode, draws a light circle behind the icon so dark logos stay visible.
    this.padIconOnDark = false,
  });

  final String? label;
  final String iconAsset;
  final double iconSize;
  final bool iconOnly;
  final double? imageScale;
  final bool padIconOnDark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget logoImage({double? side}) {
      final s = side ?? iconSize;
      return Image.asset(
        iconAsset,
        width: s,
        height: s,
        scale: imageScale ?? 1.0,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          final c = Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black87;
          return Icon(Icons.public, size: s, color: c);
        },
      );
    }

    Widget icon = logoImage();
    if (isDark && padIconOnDark) {
      final inner = (iconSize - 8).clamp(16.0, iconSize);
      icon = Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: logoImage(side: inner),
      );
    }

    if (iconOnly) {
      return icon;
    }
    final text = label ?? '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

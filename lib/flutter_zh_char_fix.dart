import 'dart:io';

import 'package:flutter/material.dart';
import 'package:is_zh/is_zh.dart';

/// Font families that keep Simplified Chinese glyphs consistent on Windows.
///
/// The first installed family is used for every CJK character the theme's
/// primary font does not cover.
const List<String> simplifiedChineseFontFallback = <String>[
  'Microsoft YaHei UI',
  'Microsoft YaHei',
  'DengXian',
  'SimHei',
];

/// Font families that keep Traditional Chinese glyphs consistent on Windows.
const List<String> traditionalChineseFontFallback = <String>[
  'Microsoft JhengHei UI',
  'Microsoft JhengHei',
  'MingLiU',
  'PMingLiU',
];

/// Returns a font fallback chain that fixes mixed Chinese/Japanese glyphs.
///
/// On Windows, SkParagraph resolves CJK glyphs one by one, so Chinese text can
/// mix Japanese and Chinese fonts (and therefore glyph shapes and weights) in a
/// single line. See https://github.com/flutter/flutter/issues/103811.
///
/// The locale is read from [context] with the `is_zh` package, so [context]
/// must be below a `Localizations` widget (for example `MaterialApp.builder`).
///
/// Traditional Chinese locales get the zh-Hant chain; every other Chinese
/// locale gets the zh-Hans chain, including a bare `zh` locale. Returns `null`
/// on non-Windows platforms and for non-Chinese locales.
List<String>? chineseFontFallback(BuildContext context) {
  if (!Platform.isWindows || !isZh(context)) {
    return null;
  }
  return isZhTraditional(context)
      ? traditionalChineseFontFallback
      : simplifiedChineseFontFallback;
}

/// Applies [chineseFontFallback] to the current theme.
///
/// Put it in `MaterialApp.builder`, the first context that has a resolved
/// locale:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ChineseFontFallback(child: child!),
/// )
/// ```
class ChineseFontFallback extends StatelessWidget {
  const ChineseFontFallback({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fallback = chineseFontFallback(context);
    if (fallback == null) {
      return child;
    }
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamilyFallback: fallback),
        primaryTextTheme: theme.primaryTextTheme.apply(
          fontFamilyFallback: fallback,
        ),
      ),
      child: child,
    );
  }
}

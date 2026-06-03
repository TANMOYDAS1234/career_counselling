import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'language_controller.dart';
import 'translation_controller.dart';

/// Drop-in replacement for [Text] that renders [data] translated into the
/// currently-selected language. English is shown verbatim; other languages are
/// fetched on demand and cached (see [TranslationController]).
class TranslatedText extends ConsumerWidget {
  const TranslatedText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    // Rebuild when the cache updates.
    ref.watch(translationProvider);
    final shown =
        lang == 'en' ? data : ref.read(translationProvider.notifier).resolve(data);
    return Text(
      shown,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

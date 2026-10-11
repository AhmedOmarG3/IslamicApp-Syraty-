import 'package:flutter/painting.dart';

/// A single highlighted ayah on the Mushaf surface.
///
/// Used for the saved bookmark / last-read verse, the verse currently being
/// recited by the audio player, and the verse the user just tapped.
/// The renderer resolves these by `(surah, verse)` — the page is not needed
/// because only the verses of the page being built are ever queried.
class MushafHighlight {
  /// Surah number (1..114).
  final int surah;

  /// Ayah number within [surah].
  final int verseNumber;

  /// Background color painted behind the ayah's glyphs.
  final Color color;

  const MushafHighlight({
    required this.surah,
    required this.verseNumber,
    required this.color,
  });

  /// Key used to index highlights in the per-page lookup map.
  static int keyFor(int surah, int verseNumber) => (surah << 10) | verseNumber;

  int get key => keyFor(surah, verseNumber);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MushafHighlight &&
          other.surah == surah &&
          other.verseNumber == verseNumber &&
          other.color == color;

  @override
  int get hashCode => Object.hash(surah, verseNumber, color);

  @override
  String toString() =>
      'MushafHighlight(surah: $surah, verse: $verseNumber, color: $color)';
}

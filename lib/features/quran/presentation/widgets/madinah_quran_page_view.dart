import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart' as qcf;
import 'package:siraty/features/quran/presentation/widgets/mushaf_highlight.dart';

/// Printed Madinah Mushaf page proportions.
///
/// The QCF page fonts carry fixed glyph advances, so the printed line breaks
/// only reproduce when the font size stays proportional to the page width.
/// That ratio is [_pageWidthPerFontSize] — the single value to tune by eye
/// against a printed Mushaf. The line-height factor is then derived from it so
/// that exactly [_linesPerPage] lines fill a page of [_pageAspectRatio].
const double _pageWidthPerFontSize = 17.0;
const int _linesPerPage = 15;

/// Basmala glyphs, taken from the page-1 QCF font exactly as the printed
/// Mushaf draws them. Emitted before the first verse of every surah except
/// Al-Fatihah (whose basmala is part of verse 1) and At-Tawbah (which has none).
const String _basmalaGlyphs = ' ﱁ  ﱂﱃﱄ\n';

/// A hair space inserted after the first glyph of a page, matching the printed
/// Mushaf's optical margin.
const String _pageStartHairSpace = '\u200A';

/// Authentic 15-line Madinah Mushaf reader backed by the King Fahd Complex
/// per-page QCF fonts bundled with `qcf_quran`.
///
/// A page renders as one justified glyph run per page font, which is what
/// reproduces the printed layout. Line breaks come from the Mushaf data itself
/// (explicit newlines in each verse's QCF glyph string), not from text
/// wrapping, so the 15-line page survives any screen size.
///
/// All Quran features live outside this widget: it only draws the page and
/// reports which ayah was tapped.
class MadinahQuranPageView extends StatelessWidget {
  final PageController pageController;
  final ValueChanged<int>? onPageChanged;
  final List<MushafHighlight> highlights;

  /// Optional per-page chrome. Both receive the 1-based page number and scroll
  /// with the page, so the juz/surah strip and page number stay in sync while
  /// swiping.
  final Widget Function(BuildContext context, int pageNumber)? topBarBuilder;
  final Widget Function(BuildContext context, int pageNumber)? bottomBarBuilder;

  final Color pageBackgroundColor;
  final Color textColor;
  final Color verseNumberColor;
  final Color basmalaColor;

  /// Colour of the surah name inside the header plate. The plate itself is a
  /// fixed-colour gold image, so this needs to stay dark in every theme.
  final Color headerTextColor;

  /// Ayah gestures. A text span carries a single recognizer, so when both are
  /// supplied [onTap] wins — which is what the reader page wants anyway.
  final void Function(int surahNumber, int verseNumber)? onTap;
  final void Function(int surahNumber, int verseNumber)? onLongPress;

  final int quranPagesCount;
  final bool isFullScreen;
  final ScrollPhysics? physics;

  const MadinahQuranPageView({
    super.key,
    required this.pageController,
    this.isFullScreen = false,
    this.onPageChanged,
    this.highlights = const [],
    this.topBarBuilder,
    this.bottomBarBuilder,
    this.pageBackgroundColor = const Color(0xFFFAF7EE),
    this.textColor = const Color(0xFF000000),
    this.verseNumberColor = const Color(0xFF8B4513),
    this.basmalaColor = const Color(0xFF000000),
    this.headerTextColor = const Color(0xFF000000),
    this.onTap,
    this.onLongPress,
    this.quranPagesCount = 604,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: pageBackgroundColor,
        child: PageView.builder(
          controller: pageController,
          physics: physics ?? const BouncingScrollPhysics(),
          itemCount: quranPagesCount,
          onPageChanged: (index) => onPageChanged?.call(index + 1),
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            return Column(
              children: [
                if (topBarBuilder != null) topBarBuilder!(context, pageNumber),
                Expanded(
                  child: _MushafQcfPage(
                    pageNumber: pageNumber,
                    isFullScreen: isFullScreen,
                    highlights: highlights,
                    textColor: textColor,
                    verseNumberColor: verseNumberColor,
                    basmalaColor: basmalaColor,
                    headerTextColor: headerTextColor,
                    onTap: onTap,
                    onLongPress: onLongPress,
                  ),
                ),
                if (bottomBarBuilder != null)
                  bottomBarBuilder!(context, pageNumber),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page structure
// ---------------------------------------------------------------------------

/// One item in a page's flowing glyph run.
sealed class _PageBlock {
  const _PageBlock();
}

/// The ornate surah header plate, which occupies a line of the printed page.
class _HeaderBlock extends _PageBlock {
  final int surah;
  const _HeaderBlock(this.surah);
}

/// The basmala line opening a surah, also a line of the printed page.
class _BasmalaBlock extends _PageBlock {
  const _BasmalaBlock();
}

class _VerseBlock extends _PageBlock {
  final int surah;
  final int verse;

  /// The verse's glyphs, without the trailing verse-number glyph.
  final String glyphs;

  /// The single QCF glyph that draws this verse's number in its medallion.
  final String numberGlyph;

  /// Whether the printed line ends after this verse's number.
  final bool lineBreakAfter;

  const _VerseBlock({
    required this.surah,
    required this.verse,
    required this.glyphs,
    required this.numberGlyph,
    required this.lineBreakAfter,
  });
}

// ---------------------------------------------------------------------------
// Page rendering
// ---------------------------------------------------------------------------

class _MushafQcfPage extends StatefulWidget {
  final int pageNumber;
  final bool isFullScreen;
  final List<MushafHighlight> highlights;
  final Color textColor;
  final Color verseNumberColor;
  final Color basmalaColor;
  final Color headerTextColor;
  final void Function(int surahNumber, int verseNumber)? onTap;
  final void Function(int surahNumber, int verseNumber)? onLongPress;

  const _MushafQcfPage({
    required this.pageNumber,
    this.isFullScreen = false,
    required this.highlights,
    required this.textColor,
    required this.verseNumberColor,
    required this.basmalaColor,
    required this.headerTextColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<_MushafQcfPage> createState() => _MushafQcfPageState();
}

class _MushafQcfPageState extends State<_MushafQcfPage> {
  /// One recognizer per ayah, reused across rebuilds and disposed with the
  /// page. The closures read `widget.onTap` at call time, so they stay current
  /// as the parent rebuilds (audio ticks rebuild this page often).
  final Map<int, GestureRecognizer> _recognizers = {};

  /// The page's glyph layout. Independent of colors, so it is built once per
  /// page rather than on every rebuild — reading the Mushaf data means a linear
  /// scan per verse, which is not something to repeat on every audio tick.
  List<_PageBlock>? _blocks;
  int? _blocksPageNumber;

  /// Cached height from normal mode.
  /// When entering fullscreen mode, this height is preserved so the Quran text
  /// stays at the exact same size and does NOT stretch ("لا يمط").
  double? _lastNormalHeight;
  double? _lastWidth;

  @override
  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  GestureRecognizer? _recognizerFor(int surah, int verse) {
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
    if (onTap == null && onLongPress == null) return null;

    return _recognizers.putIfAbsent(MushafHighlight.keyFor(surah, verse), () {
      if (onTap != null) {
        return TapGestureRecognizer()
          ..onTap = () => widget.onTap?.call(surah, verse);
      }
      return LongPressGestureRecognizer()
        ..onLongPress = () => widget.onLongPress?.call(surah, verse);
    });
  }

  List<_PageBlock> _buildBlocks(int pageNumber) {
    final List<_PageBlock> blocks = [];

    for (final range in qcf.getPageData(pageNumber)) {
      final int surah = int.parse(range['surah'].toString());
      final int start = int.parse(range['start'].toString());
      final int end = int.parse(range['end'].toString());

      if (start == 1) {
        blocks.add(_HeaderBlock(surah));
        if (surah != 1 && surah != 9) blocks.add(const _BasmalaBlock());
      }

      for (int verse = start; verse <= end; verse++) {
        // The raw QCF string is `<glyphs>[<number glyph>]` with a trailing
        // newline when the verse ends a printed line. Splitting it here is the
        // same cut `getVerseQCF`/`getVerseNumberQCF` make, but reads the data
        // once instead of three times.
        final String raw = qcf.getVerseQCF(surah, verse);
        final bool lineBreakAfter = raw.endsWith('\n');
        final int numberIndex = raw.length - (lineBreakAfter ? 2 : 1);

        blocks.add(
          _VerseBlock(
            surah: surah,
            verse: verse,
            glyphs: raw.substring(0, numberIndex),
            numberGlyph: raw.substring(numberIndex, numberIndex + 1),
            lineBreakAfter: lineBreakAfter,
          ),
        );
      }
    }

    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    if (_blocks == null || _blocksPageNumber != widget.pageNumber) {
      _blocks = _buildBlocks(widget.pageNumber);
      _blocksPageNumber = widget.pageNumber;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;

        // Reset cached normal height if width/orientation changes
        if (_lastWidth != null && (_lastWidth! - availableWidth).abs() > 1.0) {
          _lastNormalHeight = null;
        }
        _lastWidth = availableWidth;

        // In normal mode, use the full available height between top and bottom chrome
        // so the 15 lines fill the page beautifully without empty gaps above/below.
        if (!widget.isFullScreen) {
          _lastNormalHeight = availableHeight;
        }

        // In fullscreen mode, keep the EXACT same height as in normal mode
        // so the text NEVER stretches ("لا يمط"), leaving clean, quiet margins above and below.
        final double pageHeight = widget.isFullScreen
            ? (_lastNormalHeight ?? (availableHeight - 94.0).clamp(100.0, availableHeight))
            : availableHeight;

        // Ensure aspect ratio doesn't exceed screen limits in landscape mode
        double pageWidth = availableWidth;
        final double maxWidthForLandscape = pageHeight * 0.75;
        if (pageWidth > maxWidthForLandscape) {
          pageWidth = maxWidthForLandscape;
        }

        final double fontSize = pageWidth / _pageWidthPerFontSize;
        // Derive line height directly from available page height so all 15 lines fill the height
        final double lineHeight = (pageHeight - 6.0) / _linesPerPage;
        final double lineHeightFactor = lineHeight / fontSize;

        return Center(
          child: SizedBox(
            width: pageWidth,
            height: pageHeight,
            // Safety net: if a page ever wraps to an extra line, shrink
            // uniformly rather than overflow. Line breaks themselves never move.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: pageWidth,
                height: pageHeight,
                child: _buildPageText(
                  fontSize,
                  pageWidth,
                  lineHeight,
                  lineHeightFactor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageText(
    double fontSize,
    double pageWidth,
    double lineHeight,
    double lineHeightFactor,
  ) {
    final String pageFont =
        'QCF_P${widget.pageNumber.toString().padLeft(3, '0')}';

    final Map<int, Color> highlightColors = {
      for (final highlight in widget.highlights) highlight.key: highlight.color,
    };

    final List<InlineSpan> spans = [];
    bool seenFirstVerse = false;
    for (final block in _blocks!) {
      switch (block) {
        case _HeaderBlock(:final surah):
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _SurahHeaderFrame(
                surahNumber: surah,
                width: pageWidth,
                height: lineHeight,
                textColor: widget.headerTextColor,
              ),
            ),
          );
        case _BasmalaBlock():
          spans.add(
            TextSpan(
              text: _basmalaGlyphs,
              style: TextStyle(
                fontFamily: 'QCF_P001',
                package: 'qcf_quran',
                fontSize: fontSize,
                height: lineHeightFactor,
                color: widget.basmalaColor,
              ),
            ),
          );
        case _VerseBlock():
          spans.add(
            _buildVerse(
              block,
              pageFont,
              highlightColors,
              isPageStart: !seenFirstVerse,
            ),
          );
          seenFirstVerse = true;
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      locale: const Locale('ar'),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: pageFont,
        package: 'qcf_quran',
        fontSize: fontSize,
        height: lineHeightFactor,
        color: widget.textColor,
      ),
    );
  }

  InlineSpan _buildVerse(
    _VerseBlock block,
    String pageFont,
    Map<int, Color> highlightColors, {
    required bool isPageStart,
  }) {
    final Color? highlight =
        highlightColors[MushafHighlight.keyFor(block.surah, block.verse)];

    // Optical nudge on the very first glyph of the page, as in the printed
    // Mushaf and in both of the package's own renderers.
    final String glyphs = isPageStart && block.glyphs.length > 1
        ? '${block.glyphs.substring(0, 1)}$_pageStartHairSpace'
            '${block.glyphs.substring(1)}'
        : block.glyphs;

    return TextSpan(
      text: glyphs,
      recognizer: _recognizerFor(block.surah, block.verse),
      style: highlight == null ? null : TextStyle(backgroundColor: highlight),
      children: [
        TextSpan(
          text: block.numberGlyph,
          style: TextStyle(
            fontFamily: pageFont,
            package: 'qcf_quran',
            color: widget.verseNumberColor,
            backgroundColor: highlight,
          ),
        ),
        // The line break printed after this verse's number. Without it the
        // page collapses to a handful of very long lines.
        if (block.lineBreakAfter) const TextSpan(text: '\n'),
      ],
    );
  }
}

/// The ornate gold surah header from the printed Mushaf: the `mainframe` plate
/// with the surah name set in the `surahname` glyph font.
class _SurahHeaderFrame extends StatelessWidget {
  final int surahNumber;
  final double width;
  final double height;
  final Color textColor;

  const _SurahHeaderFrame({
    required this.surahNumber,
    required this.width,
    required this.height,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image(
            image:
                const AssetImage('assets/mainframe.png', package: 'qcf_quran'),
            width: width,
            height: height,
            fit: BoxFit.fill,
          ),
          Text(
            'surah${surahNumber.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontFamily: 'surahname',
              package: 'qcf_quran',
              fontSize: height * 0.62,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

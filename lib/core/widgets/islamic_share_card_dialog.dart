import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/colors.dart';
import 'islamic_ornament_painter.dart';

enum ShareCardType { ayah, hadith, zikr, dua }

enum ShareCardTheme { emerald, midnight, parchment }

class IslamicShareCardDialog extends StatefulWidget {
  final ShareCardType type;
  final String contentText;
  final String title;
  final String? subtitle;
  final String? source;
  final String? extraNote;

  const IslamicShareCardDialog({
    super.key,
    required this.type,
    required this.contentText,
    required this.title,
    this.subtitle,
    this.source,
    this.extraNote,
  });

  static void show(
    BuildContext context, {
    required ShareCardType type,
    required String contentText,
    required String title,
    String? subtitle,
    String? source,
    String? extraNote,
  }) {
    showDialog(
      context: context,
      builder: (_) => IslamicShareCardDialog(
        type: type,
        contentText: contentText,
        title: title,
        subtitle: subtitle,
        source: source,
        extraNote: extraNote,
      ),
    );
  }

  @override
  State<IslamicShareCardDialog> createState() => _IslamicShareCardDialogState();
}

class _IslamicShareCardDialogState extends State<IslamicShareCardDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;
  ShareCardTheme _activeTheme = ShareCardTheme.emerald;

  String get _typeBadge {
    switch (widget.type) {
      case ShareCardType.ayah:
        return 'آيَةٌ قُرْآنِيَّةٌ مُبَارَكَةٌ';
      case ShareCardType.hadith:
        return 'حَدِيثٌ نَبَوِيٌّ شَرِيفٌ';
      case ShareCardType.zikr:
        return 'ذِكْرٌ وَتَسْبِيحٌ';
      case ShareCardType.dua:
        return 'دُعَاءٌ مَأْثُورٌ';
    }
  }

  Future<void> _exportAndShare() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    HapticFeedback.lightImpact();

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Render at ultra high resolution (3.5x pixel ratio) for crisp printing & social media
      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/siraty_${widget.type.name}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      if (mounted) {
        Navigator.pop(context);
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'image/png')],
        );
      }
    } catch (e) {
      debugPrint('Error exporting Islamic share card: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.92,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Selector Bar
              _buildThemeSelector(),

              SizedBox(height: 12.h),

              // The RepaintBoundary capturing the luxurious handcrafted Islamic card
              RepaintBoundary(
                key: _cardKey,
                child: _buildHandcraftedCard(),
              ),

              SizedBox(height: 16.h),

              // Action Buttons (Export & Close)
              _buildActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A15).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeChip('الزمرد الملكي', ShareCardTheme.emerald, const Color(0xFF133E31)),
          SizedBox(width: 8.w),
          _buildThemeChip('الليل الأندلسي', ShareCardTheme.midnight, const Color(0xFF142233)),
          SizedBox(width: 8.w),
          _buildThemeChip('المخطوطة العتيقة', ShareCardTheme.parchment, const Color(0xFFF3E7D0)),
        ],
      ),
    );
  }

  Widget _buildThemeChip(String label, ShareCardTheme theme, Color sampleColor) {
    final isSelected = _activeTheme == theme;
    return GestureDetector(
      onTap: () => setState(() => _activeTheme = theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGold : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sampleColor,
                border: Border.all(
                  color: isSelected ? const Color(0xFF141C18) : Colors.white70,
                  width: 1.2,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 11.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF141C18) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandcraftedCard() {
    List<Color> gradientColors;
    Color textColor;
    Color subTextColor;
    Color goldAccent;
    Color badgeBg;

    switch (_activeTheme) {
      case ShareCardTheme.emerald:
        gradientColors = const [
          Color(0xFF163E32),
          Color(0xFF0F2C23),
          Color(0xFF091C16),
        ];
        textColor = const Color(0xFFFAF7EE);
        subTextColor = const Color(0xFFC7DFD6);
        goldAccent = const Color(0xFFE2B86E);
        badgeBg = const Color(0xFFE2B86E).withValues(alpha: 0.14);
        break;

      case ShareCardTheme.midnight:
        gradientColors = const [
          Color(0xFF1B2838),
          Color(0xFF111C28),
          Color(0xFF091018),
        ];
        textColor = const Color(0xFFFAF8F2);
        subTextColor = const Color(0xFFD0DCDE);
        goldAccent = const Color(0xFFE8C88A);
        badgeBg = const Color(0xFFE8C88A).withValues(alpha: 0.14);
        break;

      case ShareCardTheme.parchment:
        gradientColors = const [
          Color(0xFFFAF4E7),
          Color(0xFFF1E3C7),
          Color(0xFFE5D2AE),
        ];
        textColor = const Color(0xFF22160C);
        subTextColor = const Color(0xFF4A3622);
        goldAccent = const Color(0xFF9E7B34);
        badgeBg = const Color(0xFF9E7B34).withValues(alpha: 0.14);
        break;
    }

    // Adaptive font sizing based on length of content
    final textLength = widget.contentText.length;
    final double contentFontSize = textLength > 280
        ? 15.sp
        : textLength > 150
            ? 16.5.sp
            : 18.5.sp;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: IslamicOrnamentPainter(
          primaryGold: goldAccent,
          borderWidth: 1.2,
          cornerSize: 22.r,
          showCornerFlourishes: true,
          showInnerBorder: true,
          showArch: true,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),

              // Bismillah in authentic calligraphic font
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                ),
              ),

              SizedBox(height: 10.h),

              // Type Badge Cartouche
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: goldAccent.withValues(alpha: 0.45),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _typeBadge,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Main Quran / Hadith Content (Flexible & Responsive)
              Text(
                widget.type == ShareCardType.ayah
                    ? '﴿ ${widget.contentText} ﴾'
                    : widget.contentText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: widget.type == ShareCardType.ayah ? 'AmiriQuran' : 'Amiri',
                  fontSize: contentFontSize,
                  height: 1.85,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),

              // Subtitle / Reference / Narrator if present
              if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: goldAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: goldAccent.withValues(alpha: 0.28),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                    ),
                  ),
                ),
              ],

              // Extra Note / Benefit / Explanation
              if (widget.extraNote != null && widget.extraNote!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: goldAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: goldAccent.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    widget.extraNote!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      height: 1.5,
                      color: subTextColor,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // Rosette Divider
              IslamicRosetteDivider(goldColor: goldAccent, height: 16.h),

              SizedBox(height: 12.h),

              // Footer: Source and App Signature Watermark
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Source
                  Expanded(
                    child: Text(
                      widget.source ?? widget.title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                  ),

                  // App Watermark Signature
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 12.r, color: goldAccent),
                      SizedBox(width: 4.w),
                      Text(
                        'تطبيق سيرتي',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: goldAccent.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportAndShare,
          icon: _isExporting
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF141C18),
                  ),
                )
              : const Icon(Icons.share_rounded, size: 18),
          label: Text(
            _isExporting ? 'جارٍ التصدير...' : 'مشاركة كبطاقة فاخرة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: const Color(0xFF141C18),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 4,
          ),
        ),
        SizedBox(width: 12.w),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF1E4B3D).withValues(alpha: 0.85),
            padding: EdgeInsets.all(10.r),
          ),
        ),
      ],
    );
  }
}

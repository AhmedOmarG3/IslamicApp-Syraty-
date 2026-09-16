class DailyAyahModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String verseText;

  const DailyAyahModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.verseText,
  });
}

class DailyAyahService {
  static const List<DailyAyahModel> _curatedVerses = [
    DailyAyahModel(
      surahNumber: 20,
      surahName: 'طه',
      ayahNumber: 114,
      verseText:
          'فَتَعَٰلَى ٱللَّهُ ٱلۡمَلِكُ ٱلۡحَقُّۗ وَلَا تَعۡجَلۡ بِٱلۡقُرۡءَانِ مِن قَبۡلِ أَن يُقۡضَىٰٓ إِلَيۡكَ وَحۡيُهُۥۖ وَقُل رَّبِّ زِدۡنِي عِلۡمٗا',
    ),
    DailyAyahModel(
      surahNumber: 94,
      surahName: 'الشرح',
      ayahNumber: 6,
      verseText:
          'إِنَّ مَعَ ٱلۡعُسۡرِ يُسۡرٗا',
    ),
    DailyAyahModel(
      surahNumber: 2,
      surahName: 'البقرة',
      ayahNumber: 186,
      verseText:
          'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌۖ أُجِيبُ دَعۡوَةَ ٱلدَّاعِ إِذَا دَعَانِۖ فَلۡيَسۡتَجِيبُواْ لِي وَلۡيُؤۡمِنُواْ بِي لَعَلَّهُمۡ يَرۡشُدُونَ',
    ),
    DailyAyahModel(
      surahNumber: 25,
      surahName: 'الفرقان',
      ayahNumber: 58,
      verseText:
          'وَتَوَكَّلۡ عَلَى ٱلۡحَيِّ ٱلَّذِي لَا يَمُوتُ وَسَبِّحۡ بِحَمۡدِهِۦۚ وَكَفَىٰ بِهِۦ بِذُنُوبِ عِبَادِهِۦ خَبِيرًا',
    ),
    DailyAyahModel(
      surahNumber: 13,
      surahName: 'الرعد',
      ayahNumber: 28,
      verseText:
          'ٱلَّذِينَ ءَامَنُواْ وَتَطۡمَئِنُّ قُلُوبُهُم بِذِكۡرِ ٱللَّهِۗ أَلَا بِذِكۡرِ ٱللَّهِ تَطۡمَئِنُّ ٱلۡقُلُوبُ',
    ),
    DailyAyahModel(
      surahNumber: 52,
      surahName: 'الطور',
      ayahNumber: 48,
      verseText:
          'وَٱصۡبِرۡ لِحُكۡمِ رَبِّكَ فَإِنَّكَ بِأَعۡيُنِنَاۖ وَسَبِّحۡ بِحَمۡدِ رَبِّكَ حِينَ تَقُومُ',
    ),
    DailyAyahModel(
      surahNumber: 39,
      surahName: 'الزمر',
      ayahNumber: 53,
      verseText:
          '۞قُلۡ يَٰعِبَادِيَ ٱلَّذِينَ أَسۡرَفُواْ عَلَىٰٓ أَنفُسِهِمۡ لَا تَقۡنَطُواْ مِن رَّحۡمَةِ ٱللَّهِۚ إِنَّ ٱللَّهَ يَغۡفِرُ ٱلذُّنُوبَ جَمِيعًاۚ إِنَّهُۥ هُوَ ٱلۡغَفُورُ ٱلرَّحِيمُ',
    ),
    DailyAyahModel(
      surahNumber: 65,
      surahName: 'الطلاق',
      ayahNumber: 2,
      verseText:
          'فَإِذَا بَلَغۡنَ أَجَلَهُنَّ فَأَمۡسِكُوهُنَّ بِمَعۡرُوفٍ أَوۡ فَارِقُوهُنَّ بِمَعۡرُوفٖ وَأَشۡهِدُواْ ذَوَيۡ عَدۡلٖ مِّنكُمۡ وَأَقِيمُواْ ٱلشَّهَٰدَةَ لِلَّهِۚ ذَٰلِكُمۡ يُوعَظُ بِهِۦ مَن كَانَ يُؤۡمِنُ بِٱللَّهِ وَٱلۡيَوۡمِ ٱلۡأٓخِرِۚ وَمَن يَتَّقِ ٱللَّهَ يَجۡعَل لَّهُۥ مَخۡرَجٗا',
    ),
    DailyAyahModel(
      surahNumber: 2,
      surahName: 'البقرة',
      ayahNumber: 152,
      verseText:
          'فَٱذۡكُرُونِيٓ أَذۡكُرۡكُمۡ وَٱشۡكُرُواْ لِي وَلَا تَكۡفُرُونِ',
    ),
    DailyAyahModel(
      surahNumber: 40,
      surahName: 'غافر',
      ayahNumber: 60,
      verseText:
          'وَقَالَ رَبُّكُمُ ٱدۡعُونِيٓ أَسۡتَجِبۡ لَكُمۡۚ إِنَّ ٱلَّذِينَ يَسۡتَكۡبِرُونَ عَنۡ عِبَادَتِي سَيَدۡخُلُونَ جَهَنَّمَ دَاخِرِينَ',
    ),
    DailyAyahModel(
      surahNumber: 3,
      surahName: 'آل عمران',
      ayahNumber: 173,
      verseText:
          'ٱلَّذِينَ قَالَ لَهُمُ ٱلنَّاسُ إِنَّ ٱلنَّاسَ قَدۡ جَمَعُواْ لَكُمۡ فَٱخۡشَوۡهُمۡ فَزَادَهُمۡ إِيمَٰنٗا وَقَالُواْ حَسۡبُنَا ٱللَّهُ وَنِعۡمَ ٱلۡوَكِيلُ',
    ),
    DailyAyahModel(
      surahNumber: 2,
      surahName: 'البقرة',
      ayahNumber: 286,
      verseText:
          'لَا يُكَلِّفُ ٱللَّهُ نَفۡسًا إِلَّا وُسۡعَهَاۚ لَهَا مَا كَسَبَتۡ وَعَلَيۡهَا مَا ٱكۡتَسَبَتۡۗ رَبَّنَا لَا تُؤَاخِذۡنَآ إِن نَّسِينَآ أَوۡ أَخۡطَأۡنَاۚ رَبَّنَا وَلَا تَحۡمِلۡ عَلَيۡنَآ إِصۡرٗا كَمَا حَمَلۡتَهُۥ عَلَى ٱلَّذِينَ مِن قَبۡلِنَاۚ رَبَّنَا وَلَا تُحَمِّلۡنَا مَا لَا طَاقَةَ لَنَا بِهِۦۖ وَٱعۡفُ عَنَّا وَٱغۡفِرۡ لَنَا وَٱرۡحَمۡنَآۚ أَنتَ مَوۡلَىٰنَا فَٱنصُرۡنَا عَلَى ٱلۡقَوۡمِ ٱلۡكَٰفِرِينَ',
    ),
    DailyAyahModel(
      surahNumber: 7,
      surahName: 'الأعراف',
      ayahNumber: 156,
      verseText:
          '۞وَٱكۡتُبۡ لَنَا فِي هَٰذِهِ ٱلدُّنۡيَا حَسَنَةٗ وَفِي ٱلۡأٓخِرَةِ إِنَّا هُدۡنَآ إِلَيۡكَۚ قَالَ عَذَابِيٓ أُصِيبُ بِهِۦ مَنۡ أَشَآءُۖ وَرَحۡمَتِي وَسِعَتۡ كُلَّ شَيۡءٖۚ فَسَأَكۡتُبُهَا لِلَّذِينَ يَتَّقُونَ وَيُؤۡتُونَ ٱلزَّكَوٰةَ وَٱلَّذِينَ هُم بِـَٔايَٰتِنَا يُؤۡمِنُونَ',
    ),
    DailyAyahModel(
      surahNumber: 11,
      surahName: 'هود',
      ayahNumber: 88,
      verseText:
          'قَالَ يَٰقَوۡمِ أَرَءَيۡتُمۡ إِن كُنتُ عَلَىٰ بَيِّنَةٖ مِّن رَّبِّي وَرَزَقَنِي مِنۡهُ رِزۡقًا حَسَنٗاۚ وَمَآ أُرِيدُ أَنۡ أُخَالِفَكُمۡ إِلَىٰ مَآ أَنۡهَىٰكُمۡ عَنۡهُۚ إِنۡ أُرِيدُ إِلَّا ٱلۡإِصۡلَٰحَ مَا ٱسۡتَطَعۡتُۚ وَمَا تَوۡفِيقِيٓ إِلَّا بِٱللَّهِۚ عَلَيۡهِ تَوَكَّلۡتُ وَإِلَيۡهِ أُنِيبُ',
    ),
    DailyAyahModel(
      surahNumber: 19,
      surahName: 'مريم',
      ayahNumber: 64,
      verseText:
          'وَمَا نَتَنَزَّلُ إِلَّا بِأَمۡرِ رَبِّكَۖ لَهُۥ مَا بَيۡنَ أَيۡدِينَا وَمَا خَلۡفَنَا وَمَا بَيۡنَ ذَٰلِكَۚ وَمَا كَانَ رَبُّكَ نَسِيّٗا',
    ),
    DailyAyahModel(
      surahNumber: 3,
      surahName: 'آل عمران',
      ayahNumber: 159,
      verseText:
          'فَبِمَا رَحۡمَةٖ مِّنَ ٱللَّهِ لِنتَ لَهُمۡۖ وَلَوۡ كُنتَ فَظًّا غَلِيظَ ٱلۡقَلۡبِ لَٱنفَضُّواْ مِنۡ حَوۡلِكَۖ فَٱعۡفُ عَنۡهُمۡ وَٱسۡتَغۡفِرۡ لَهُمۡ وَشَاوِرۡهُمۡ فِي ٱلۡأَمۡرِۖ فَإِذَا عَزَمۡتَ فَتَوَكَّلۡ عَلَى ٱللَّهِۚ إِنَّ ٱللَّهَ يُحِبُّ ٱلۡمُتَوَكِّلِينَ',
    ),
    DailyAyahModel(
      surahNumber: 65,
      surahName: 'الطلاق',
      ayahNumber: 7,
      verseText:
          'لِيُنفِقۡ ذُو سَعَةٖ مِّن سَعَتِهِۦۖ وَمَن قُدِرَ عَلَيۡهِ رِزۡقُهُۥ فَلۡيُنفِقۡ مِمَّآ ءَاتَىٰهُ ٱللَّهُۚ لَا يُكَلِّفُ ٱللَّهُ نَفۡسًا إِلَّا مَآ ءَاتَىٰهَاۚ سَيَجۡعَلُ ٱللَّهُ بَعۡدَ عُسۡرٖ يُسۡرٗا',
    ),
    DailyAyahModel(
      surahNumber: 21,
      surahName: 'الأنبياء',
      ayahNumber: 87,
      verseText:
          'وَذَا ٱلنُّونِ إِذ ذَّهَبَ مُغَٰضِبٗا فَظَنَّ أَن لَّن نَّقۡدِرَ عَلَيۡهِ فَنَادَىٰ فِي ٱلظُّلُمَٰتِ أَن لَّآ إِلَٰهَ إِلَّآ أَنتَ سُبۡحَٰنَكَ إِنِّي كُنتُ مِنَ ٱلظَّـٰلِمِينَ',
    ),
    DailyAyahModel(
      surahNumber: 2,
      surahName: 'البقرة',
      ayahNumber: 153,
      verseText:
          'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُواْ ٱسۡتَعِينُواْ بِٱلصَّبۡرِ وَٱلصَّلَوٰةِۚ إِنَّ ٱللَّهَ مَعَ ٱلصَّـٰبِرِينَ',
    ),
    DailyAyahModel(
      surahNumber: 3,
      surahName: 'آل عمران',
      ayahNumber: 8,
      verseText:
          'رَبَّنَا لَا تُزِغۡ قُلُوبَنَا بَعۡدَ إِذۡ هَدَيۡتَنَا وَهَبۡ لَنَا مِن لَّدُنكَ رَحۡمَةًۚ إِنَّكَ أَنتَ ٱلۡوَهَّابُ',
    ),
    DailyAyahModel(
      surahNumber: 16,
      surahName: 'النحل',
      ayahNumber: 128,
      verseText:
          'إِنَّ ٱللَّهَ مَعَ ٱلَّذِينَ ٱتَّقَواْ وَّٱلَّذِينَ هُم مُّحۡسِنُونَ',
    ),
    DailyAyahModel(
      surahNumber: 59,
      surahName: 'الحشر',
      ayahNumber: 23,
      verseText:
          'هُوَ ٱللَّهُ ٱلَّذِي لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡمَلِكُ ٱلۡقُدُّوسُ ٱلسَّلَٰمُ ٱلۡمُؤۡمِنُ ٱلۡمُهَيۡمِنُ ٱلۡعَزِيزُ ٱلۡجَبَّارُ ٱلۡمُتَكَبِّرُۚ سُبۡحَٰنَ ٱللَّهِ عَمَّا يُشۡرِكُونَ',
    ),
    DailyAyahModel(
      surahNumber: 67,
      surahName: 'الملك',
      ayahNumber: 1,
      verseText:
          'تَبَٰرَكَ ٱلَّذِي بِيَدِهِ ٱلۡمُلۡكُ وَهُوَ عَلَىٰ كُلِّ شَيۡءٖ قَدِيرٌ',
    ),
    DailyAyahModel(
      surahNumber: 93,
      surahName: 'الضحى',
      ayahNumber: 5,
      verseText:
          'وَلَسَوۡفَ يُعۡطِيكَ رَبُّكَ فَتَرۡضَىٰٓ',
    ),
    DailyAyahModel(
      surahNumber: 2,
      surahName: 'البقرة',
      ayahNumber: 255,
      verseText:
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ',
    ),
    DailyAyahModel(
      surahNumber: 14,
      surahName: 'إبراهيم',
      ayahNumber: 7,
      verseText:
          'وَإِذۡ تَأَذَّنَ رَبُّكُمۡ لَئِن شَكَرۡتُمۡ لَأَزِيدَنَّكُمۡۖ وَلَئِن كَفَرۡتُمۡ إِنَّ عَذَابِي لَشَدِيدٞ',
    ),
    DailyAyahModel(
      surahNumber: 8,
      surahName: 'الأنفال',
      ayahNumber: 46,
      verseText:
          'وَأَطِيعُواْ ٱللَّهَ وَرَسُولَهُۥ وَلَا تَنَٰزَعُواْ فَتَفۡشَلُواْ وَتَذۡهَبَ رِيحُكُمۡۖ وَٱصۡبِرُوٓاْۚ إِنَّ ٱللَّهَ مَعَ ٱلصَّـٰبِرِينَ',
    ),
    DailyAyahModel(
      surahNumber: 28,
      surahName: 'القصص',
      ayahNumber: 24,
      verseText:
          'فَسَقَىٰ لَهُمَا ثُمَّ تَوَلَّىٰٓ إِلَى ٱلظِّلِّ فَقَالَ رَبِّ إِنِّي لِمَآ أَنزَلۡتَ إِلَيَّ مِنۡ خَيۡرٖ فَقِيرٞ',
    ),
    DailyAyahModel(
      surahNumber: 55,
      surahName: 'الرحمن',
      ayahNumber: 60,
      verseText:
          'هَلۡ جَزَآءُ ٱلۡإِحۡسَٰنِ إِلَّا ٱلۡإِحۡسَٰنُ',
    ),
    DailyAyahModel(
      surahNumber: 108,
      surahName: 'الكوثر',
      ayahNumber: 1,
      verseText:
          'إِنَّآ أَعۡطَيۡنَٰكَ ٱلۡكَوۡثَرَ',
    ),
  ];

  /// Returns today's Ayah deterministically based on date (rotates at midnight every day)
  static DailyAyahModel getDailyAyah([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    // Unique day index counting days from fixed epoch date
    final dayIndex = DateTime(targetDate.year, targetDate.month, targetDate.day)
        .difference(DateTime(2024, 1, 1))
        .inDays;
    final safeIndex = dayIndex.abs() % _curatedVerses.length;
    return _curatedVerses[safeIndex];
  }

  /// Local-calendar day key (year * 366 + day of year) used to detect
  /// day rollover on the native widget side. Must stay in sync with the
  /// equivalent calculation in AyahWidgetProvider.kt.
  static int getDayKey([DateTime? date]) {
    final now = date ?? DateTime.now();
    final dayOfYear = DateTime(now.year, now.month, now.day)
            .difference(DateTime(now.year, 1, 1))
            .inDays +
        1;
    return now.year * 366 + dayOfYear;
  }

  static List<DailyAyahModel> getAllCuratedVerses() => _curatedVerses;
}

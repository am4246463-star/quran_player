/// كائن واحد يمثّل سورة واحدة من القرآن الكريم.
///
/// مسؤوليته الوحيدة: حفظ معلومات السورة، وتوفير مسار ملفّها الصوتي.
/// لا يعرف شيئًا عن الواجهة أو التشغيل — هذا عمل الطبقات الأخرى.
class Surah {
  /// رقم السورة في المصحف (1 إلى 114).
  final int number;

  /// الاسم العربي، مثل: "الفاتحة".
  final String arabicName;

  /// الاسم بالإنجليزية (نقل صوتي)، مثل: "Al-Fatihah".
  /// يُستخدم للبحث بالحروف اللاتينية.
  final String englishName;

  /// مُنشئ (constructor). كلمة const تعني أنه يمكن إنشاء كائنات ثابتة
  /// من هذا النوع وقت الترجمة، فيُوفّر الذاكرة والوقت.
  const Surah({
    required this.number,
    required this.arabicName,
    required this.englishName,
  });

  /// المسار الكامل للملف الصوتي داخل أصول التطبيق.
  ///
  /// الفكرة: نأخذ رقم السورة، ونضيف له أصفارًا بادئة حتى يصبح طوله 3 خانات،
  /// لأن ملفاتنا مسماة 001.mp3 … 114.mp3.
  ///
  /// مثال:
  ///   number = 1   -> "assets/audio/001.mp3"
  ///   number = 36  -> "assets/audio/036.mp3"
  ///   number = 114 -> "assets/audio/114.mp3"
  String get audioAssetPath {
    // padLeft(3, '0') يعني: أضف أصفارًا إلى يسار النص حتى يبلغ طوله 3.
    final paddedNumber = number.toString().padLeft(3, '0');
    return 'assets/audio/$paddedNumber.mp3';
  }
}

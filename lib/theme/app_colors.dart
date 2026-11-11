import 'package:flutter/material.dart';

/// ألوان التطبيق في مكان واحد. أي شاشة أو widget تحتاج لونًا
/// تُشير إلى هنا، لا تُعرّفه مباشرة. تغيير اللون في سطر واحد يؤثر
/// في التطبيق كله.
class AppColors {
  // منشئ خاص فارغ — يمنع إنشاء كائنات من هذا الصنف.
  // فائدته: هذا الملف مجرد "حاوية ثوابت"، ولا معنى لإنشاء نسخة منه.
  AppColors._();

  // === الأخضر الزمردي (اللون الأساسي) ===
  static const Color emerald = Color(0xFF1B5E4A);
  static const Color emeraldDark = Color(0xFF0E3B2E);

  // === الذهبي (لمسات صغيرة فقط) ===
  static const Color gold = Color(0xFFC9A961);

  // === خلفيات ===
  static const Color offWhite = Color(0xFFF7F5EF);

  // === نصوص ===
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// يبني الثيمات. الآن الثيم الفاتح فقط. الثيم الداكن في الخطوة 8.
///
/// لماذا نستخرج الثيم من main.dart؟
///  - main.dart يجب أن يبقى صغيرًا وواضحًا.
///  - تجميع منطق التصميم هنا يسهّل تعديله دون لمس الملفات الأخرى.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    // ColorScheme.fromSeed يولّد نظام ألوان كاملًا من لون واحد.
    // هذا مبدأ Material 3: لون بذرة واحد + ذكاء يبني التوافق.
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.offWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.emeraldDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.emeraldDark),
      ),
    );
  }
}

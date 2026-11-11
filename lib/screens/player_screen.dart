import 'package:flutter/material.dart';

import '../data/surah_data.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_progress_bar.dart';
import '../widgets/audio_service_scope.dart';

/// شاشة المشغّل الكاملة. تُفتح من الشريط الصغير بـ fullscreenDialog.
///
/// StatelessWidget: كل حالة العرض تأتي من AudioServiceScope.
/// عند notifyListeners يُعاد بناؤها تلقائيًا.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioServiceScope.of(context);
    final number = audio.currentSurahNumber;
    final theme = Theme.of(context);

    if (number == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('لا توجد سورة قيد التشغيل')),
      );
    }

    final surah = surahList.firstWhere((s) => s.number == number);

    return Scaffold(
      appBar: AppBar(title: const Text('قيد التشغيل')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // === منطقة العرض الرئيسية ===
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SurahBadge(number: number),
                      const SizedBox(height: 24),
                      Text(
                        surah.arabicName,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.emeraldDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.englishName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === شريط التقدّم ===
              const AudioProgressBar(),
              const SizedBox(height: 16),

              // === أزرار التحكم الرئيسية ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 42,
                    tooltip: 'السابق',
                    onPressed: audio.previous,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  const SizedBox(width: 20),
                  _PlayPauseButton(
                    isPlaying: audio.isPlaying,
                    onPressed: audio.togglePlayPause,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 42,
                    tooltip: 'التالي',
                    onPressed: audio.next,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // === التكرار + السرعة ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'تكرار السورة',
                    onPressed: audio.toggleRepeat,
                    icon: Icon(
                      Icons.repeat,
                      color: audio.repeatEnabled ? AppColors.emerald : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  _SpeedSelector(
                    currentSpeed: audio.speed,
                    onChanged: audio.setSpeed,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// دائرة كبيرة برقم السورة — بديل عصري عن صورة الغلاف.
class _SurahBadge extends StatelessWidget {
  const _SurahBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.emerald, AppColors.emeraldDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// زر التشغيل/الإيقاف الكبير. استخدمنا Container دائريًا بدلًا من
/// IconButton.filled لتوافق أوسع مع إصدارات Flutter.
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.emerald,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// قائمة منسدلة لسرعة القراءة.
class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({required this.currentSpeed, required this.onChanged});

  final double currentSpeed;
  final ValueChanged<double> onChanged;

  static const List<double> _speeds = [1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: currentSpeed,
      onSelected: onChanged,
      tooltip: 'سرعة القراءة',
      itemBuilder: (context) => [
        for (final s in _speeds)
          PopupMenuItem(value: s, child: Text('${s}x')),
      ],
      // PopupMenuButton يلفّ child في InkWell — فيظهر تأثير اللمس تلقائيًا.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed, size: 20, color: AppColors.emerald),
            const SizedBox(width: 6),
            Text(
              '${currentSpeed}x',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

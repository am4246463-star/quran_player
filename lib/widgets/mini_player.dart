import 'package:flutter/material.dart';

import '../data/surah_data.dart';
import '../screens/player_screen.dart';
import '../services/audio_player_service.dart';
import '../theme/app_colors.dart';
import 'audio_service_scope.dart';

/// شريط صغير أسفل الشاشة يظهر فقط عندما تكون هناك سورة قيد التشغيل.
/// النقر عليه يفتح شاشة المشغّل الكاملة.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioServiceScope.of(context);
    final number = audio.currentSurahNumber;

    // إن لم تكن هناك سورة → لا نعرض شيئًا.
    if (number == null) return const SizedBox.shrink();

    final surah = surahList.firstWhere((s) => s.number == number);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const PlayerScreen(),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniProgressLine(audio: audio),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          surah.arabicName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.emeraldDark,
                          ),
                        ),
                        Text(
                          audio.isPlaying ? 'قيد التشغيل' : 'متوقف مؤقتًا',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'السابق',
                    onPressed: audio.previous,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    tooltip: audio.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                    onPressed: audio.togglePlayPause,
                    iconSize: 32,
                    icon: Icon(
                      audio.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.emerald,
                    ),
                  ),
                  IconButton(
                    tooltip: 'التالي',
                    onPressed: audio.next,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط تقدّم رفيع جدًا في أعلى الشريط الصغير.
/// وُضع في widget منفصل حتى لا يُعاد بناء بقية الشريط كلما
/// تغيّر موقع التشغيل (~5 مرات في الثانية).
class _MiniProgressLine extends StatelessWidget {
  const _MiniProgressLine({required this.audio});

  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: StreamBuilder<Duration>(
        stream: audio.positionStream,
        builder: (context, snapshot) {
          final total = audio.duration.inMilliseconds;
          final pos = snapshot.data?.inMilliseconds ?? 0;
          final value = total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;
          return LinearProgressIndicator(
            value: value,
            minHeight: 2,
            backgroundColor: Colors.transparent,
          );
        },
      ),
    );
  }
}

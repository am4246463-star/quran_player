import 'package:flutter/material.dart';

import '../models/surah.dart';
import '../theme/app_colors.dart';

/// صف واحد في قائمة السور. عرض فقط — لا منطق، لا استدعاءات للخدمة.
///
/// مسؤوليته: عرض سورة واحدة بشكل جميل، وتغيير مظهرها عندما تكون
/// هي السورة الجاري تشغيلها.
class SurahListItem extends StatelessWidget {
  const SurahListItem({
    super.key,
    required this.surah,
    required this.isCurrentlyPlaying,
    required this.isPlaying,
    required this.onTap,
  });

  final Surah surah;

  /// هل هذه السورة هي التي ينتظرها المستخدم أو يشغّلها الآن؟
  final bool isCurrentlyPlaying;

  /// هل التشغيل جارٍ الآن (true) أم متوقف مؤقتًا (false)؟
  /// تُستخدم فقط عندما isCurrentlyPlaying = true.
  final bool isPlaying;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // عندما تكون السورة قيد التشغيل: نضع خلفية زمردية شفافة وحدودًا خفيفة.
    // Otherwise شفاف تمامًا — لا يُشتت.
    final bgColor = isCurrentlyPlaying
        ? AppColors.emerald.withValues(alpha: 0.08)
        : Colors.transparent;
    final borderColor = isCurrentlyPlaying
        ? AppColors.emerald.withValues(alpha: 0.3)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          // InkWell يعطي تأثير "موجة" (ripple) عند اللمس — ضروري للإحساس بالتفاعل.
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                _NumberBadge(
                  number: surah.number,
                  highlighted: isCurrentlyPlaying,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.arabicName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrentlyPlaying
                              ? AppColors.emerald
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        surah.englishName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                // أيقونة صغيرة على اليسار (في RTL):
                //  - للسورة الجارية: معادل الصوت أثناء التشغيل، أو "إيقاف".
                //  - لغيرها: سهم تشغيل خفيف للدلالة على أنه قابل للنقر.
                _buildTrailingIcon(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingIcon(ThemeData theme) {
    if (isCurrentlyPlaying) {
      return Icon(
        isPlaying ? Icons.graphic_eq : Icons.pause_circle_outline,
        color: AppColors.emerald,
        size: 26,
      );
    }
    return Icon(
      Icons.play_circle_outline,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      size: 24,
    );
  }
}

/// دائرة رقم السورة في بداية الصف (على اليمين في RTL).
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.highlighted});

  final int number;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted
            ? AppColors.emerald
            : theme.colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: highlighted
              ? Colors.white
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

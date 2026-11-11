import 'package:flutter/material.dart';

import 'audio_service_scope.dart';

/// شريط تقدّم قابل للسحب مع الوقت الحالي/الكلي.
///
/// **لماذا StatefulWidget؟** لأن السحب يحتاج حالة محلية (`_dragValue`)
/// كي لا يقفز مؤشر السلايدر أثناء السحب كلما وصل تحديث من البثّ.
///
/// **لماذا StreamBuilder؟** الموقع يتغيّر ~5 مرات/ثانية. لو استخدمنا
/// notifyListeners لإعادة بناء الشاشة كاملة 5 مرات/ثانية، سيتلكأ
/// التطبيق. StreamBuilder يُعيد بناء هذا الـ widget فقط.
class AudioProgressBar extends StatefulWidget {
  const AudioProgressBar({super.key});

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  /// قيمة السحب الحالية أثناء ضغط المستخدم على السلايدر.
  /// null = لا سحب جارٍ، نستخدم موقع التشغيل من البثّ.
  double? _dragValue;

  /// يحوّل مدة إلى صيغة "m:ss" أو "mm:ss".
  String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم الـ scope هنا (بدلًا من تمرير audio من الأب) كي يبقى هذا
    // الـ widget مستقلًا: يكفي وضعُه في الشجرة، فيجد الخدمة بنفسه.
    final audio = AudioServiceScope.of(context);
    final theme = Theme.of(context);

    // نقرأ المدة من الخدمة. تتغيّر عبر notifyListeners حين يكتمل
    // تحميل الملف، فتُعيد بناء هذا الـ widget ويُحدَّث max السلايدر.
    final duration = audio.duration;
    final totalMs = duration.inMilliseconds;

    return StreamBuilder<Duration>(
      stream: audio.positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final rawPosition = snapshot.data ?? Duration.zero;
        // نقيّد الموقع داخل حدود المدة — بعض الحزم تتجاوز قليلًا
        // في آخر لحظة، وهذا يُسبّب خطأ slider "value out of range".
        final posMs = totalMs > 0
            ? rawPosition.inMilliseconds.clamp(0, totalMs)
            : 0;

        // إذا كان المستخدم يسحب، اعرض قيمة السحب. وإلا اعرض الموقع الفعلي.
        final displayMs = _dragValue?.toInt() ?? posMs;
        final maxValue = totalMs > 0 ? totalMs.toDouble() : 1.0;
        final enabled = totalMs > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: displayMs.toDouble().clamp(0.0, maxValue),
              max: maxValue,
              onChangeStart:
                  enabled ? (v) => setState(() => _dragValue = v) : null,
              onChanged:
                  enabled ? (v) => setState(() => _dragValue = v) : null,
              onChangeEnd: enabled
                  ? (v) {
                      // seek الفعلي عند رفع الإصبع فقط — يمنع ضجيج طلبات
                      // متتالية أثناء السحب.
                      audio.seek(Duration(milliseconds: v.toInt()));
                      setState(() => _dragValue = null);
                    }
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // في RTL: الأول يظهر يمينًا (الوقت الحالي)،
                  // والثاني يسارًا (المدة الكلية). هذا يتوافق مع اتجاه
                  // السلايدر في RTL.
                  Text(
                    _format(Duration(milliseconds: displayMs)),
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(_format(duration), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

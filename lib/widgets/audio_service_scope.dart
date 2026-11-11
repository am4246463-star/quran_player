import 'package:flutter/widgets.dart';

import '../services/audio_player_service.dart';

/// يوفّر AudioPlayerService لكل شجرة الواجهة تحته، ويعيد بناء
/// المستمعين تلقائيًا عند notifyListeners().
///
/// الاستخدام من أي شاشة:
///   final audio = AudioServiceScope.of(context);
///   await audio.playSurah(1);
class AudioServiceScope extends InheritedNotifier<AudioPlayerService> {
  const AudioServiceScope({
    required AudioPlayerService service,
    required super.child,
    super.key,
  }) : super(notifier: service);

  /// يبحث عن أقرب AudioServiceScope أعلى الشجرة ويعيد خدمته.
  /// assert يفشل بسرعة في وضع debug إن نسينا تغليف الشجرة.
  static AudioPlayerService of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AudioServiceScope>();
    assert(
      scope != null,
      'AudioServiceScope.of() called without an ancestor AudioServiceScope',
    );
    return scope!.notifier!;
  }
}

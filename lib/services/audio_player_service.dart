import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/surah_data.dart';

/// خدمة واحدة تدير تشغيل الصوت في التطبيق كله.
/// الواجهة لا تعرف عن just_audio شيئًا — تتكلّم مع هذه الفئة فقط.
///
/// ترث ChangeNotifier كي تُخطر الواجهة عند تغيّر الحالة.
/// موقع التشغيل (positionStream) منفصل عن notifyListeners
/// لأسباب الأداء — يتغيّر ~5 مرات/ثانية.
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  // ====== الحالة الحالية ======
  int? _currentSurahNumber;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  bool _repeatEnabled = false;
  String? _errorMessage;

  /// عدّاد يزداد في كل مرة يُضبط فيها خطأ جديد. الواجهة تقارنه
  /// لتعرف أنها يجب أن تعرض SnackBar (لأن نفس الخطأ قد يتكرر بنفس
  /// النص في السورة نفسها، فلا يكفي مقارنة النص).
  int _errorTick = 0;

  // ====== الاشتراكات ======
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _eventSub;

  // ====== Getters للقراءة فقط ======
  int? get currentSurahNumber => _currentSurahNumber;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  double get speed => _speed;
  bool get repeatEnabled => _repeatEnabled;
  String? get errorMessage => _errorMessage;
  int get errorTick => _errorTick;

  /// بثّ موقع التشغيل. يستخدمه شريط التقدّم فقط.
  Stream<Duration> get positionStream => _player.positionStream;

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    // 1) حالة التشغيل.
    _playerStateSub = _player.playerStateStream.listen(
      (state) {
        if (state.processingState == ProcessingState.completed) {
          _handleCompletion();
          return;
        }

        final newIsPlaying = state.playing;
        if (newIsPlaying != _isPlaying) {
          _isPlaying = newIsPlaying;
          notifyListeners();
        }
      },
      onError: (Object e) {
        _errorMessage = 'حدث خطأ أثناء التشغيل';
        _errorTick++;
        _isPlaying = false;
        _currentSurahNumber = null;
        _duration = Duration.zero;
        notifyListeners();
      },
    );

    // 2) مدة الملف الصوتي.
    _durationSub = _player.durationStream.listen((d) {
      if (d != null && d != _duration) {
        _duration = d;
        notifyListeners();
      }
    });

    // 3) أخطاء مستوى المشغّل (ملف مفقود/تالف/صيغة غير مدعومة).
    _eventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        _errorMessage = 'تعذّر قراءة الملف الصوتي';
        _errorTick++;
        _isPlaying = false;
        _currentSurahNumber = null;
        _duration = Duration.zero;
        notifyListeners();
      },
    );
  }

  /// يشغّل السورة المطلوبة من البداية.
  Future<void> playSurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      _errorMessage = 'رقم السورة غير صالح';
      _errorTick++;
      notifyListeners();
      return;
    }

    try {
      _errorMessage = null;

      final surah = surahList.firstWhere((s) => s.number == surahNumber);
      await _player.setAsset(surah.audioAssetPath);
      await _player.setSpeed(_speed);

      // نحدّث السورة الجارية فقط بعد نجاح التحميل.
      _currentSurahNumber = surahNumber;

      await _player.play();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'تعذّر تشغيل السورة رقم $surahNumber';
      _errorTick++;
      _isPlaying = false;
      // المهم: نصفر السورة الجارية. المشغّل الآن بلا مصدر صالح،
      // فإبقاء السورة القديمة "جارية" في الواجهة يعني أن الضغط عليها
      // لاحقًا سيستدعي togglePlayPause بدل playSurah، فلا شيء يحدث.
      _currentSurahNumber = null;
      _duration = Duration.zero;
      notifyListeners();
    }
  }

  /// زر التشغيل/الإيقاف.
  Future<void> togglePlayPause() async {
    // حماية: لا نفعّل شيئًا إن لم تكن هناك سورة محددة.
    if (_currentSurahNumber == null) return;

    if (_player.playing) {
      await _player.pause();
      return;
    }

    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  /// الانتقال للسورة التالية.
  Future<void> next() async {
    if (_currentSurahNumber == null) return;
    final nextNum = _currentSurahNumber! + 1;
    if (nextNum > 114) return;
    await playSurah(nextNum);
  }

  /// العودة للسورة السابقة.
  Future<void> previous() async {
    if (_currentSurahNumber == null) return;
    final prevNum = _currentSurahNumber! - 1;
    if (prevNum < 1) return;
    await playSurah(prevNum);
  }

  /// القفز إلى موضع معيّن.
  Future<void> seek(Duration position) => _player.seek(position);

  /// تغيير سرعة القراءة.
  Future<void> setSpeed(double newSpeed) async {
    if (newSpeed <= 0) return;
    _speed = newSpeed;
    await _player.setSpeed(newSpeed);
    notifyListeners();
  }

  /// يقلب وضع التكرار.
  void toggleRepeat() {
    _repeatEnabled = !_repeatEnabled;
    notifyListeners();
  }

  /// يوقف التشغيل ويعيد الحالة الأولى.
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentSurahNumber = null;
    _duration = Duration.zero;
    notifyListeners();
  }

  /// عند انتهاء السورة الحالية.
  Future<void> _handleCompletion() async {
    if (_currentSurahNumber == null) return;

    if (_repeatEnabled) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    final nextNum = _currentSurahNumber! + 1;
    if (nextNum <= 114) {
      await playSurah(nextNum);
    } else {
      _isPlaying = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _eventSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

import '../data/surah_data.dart';
import '../models/surah.dart';
import '../widgets/audio_service_scope.dart';
import '../widgets/mini_player.dart';
import '../widgets/surah_list_item.dart';

/// الشاشة الرئيسية: قائمة السور الـ114 مع بحث فوري.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// آخر قيمة errorTick عُرضت للمستخدم. نستخدمها لتفادي عرض SnackBar
  /// نفسه أكثر من مرة.
  int _lastShownErrorTick = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> _getFilteredSurahs() {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return surahList;

    final lower = trimmed.toLowerCase();
    return surahList.where((s) {
      return s.arabicName.contains(trimmed) ||
          s.englishName.toLowerCase().contains(lower);
    }).toList();
  }

  void _onSurahTap(Surah surah, bool isCurrent, bool isPlaying) {
    final audio = AudioServiceScope.of(context);

    if (isCurrent) {
      audio.togglePlayPause();
    } else {
      audio.playSurah(surah.number);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = AudioServiceScope.of(context);

    // ====== عرض رسالة الخطأ عند وصول خطأ جديد ======
    if (audio.errorTick > _lastShownErrorTick) {
      _lastShownErrorTick = audio.errorTick;
      final message = audio.errorMessage;
      if (message != null) {
        // addPostFrameCallback: ScaffoldMessenger يحتاج الشجرة مبنية
        // بالفعل. لا يمكن استدعاؤه مباشرة أثناء build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.of(context);

          // (1) مسح الطابور: أي SnackBar سابق (ظاهر أو منتظر) يُزال فورًا.
          // هذا يمنع تراكم الرسائل عند ظهور أخطاء متتالية سريعة.
          messenger.clearSnackBars();

          // (2) عرض الجديد بمهلة 3 ثوانٍ. كتابة duration صراحةً تضمن أن
          // SnackBarAction لا يُعطّل المهلة التلقائية (بعض الإصدارات تفعل).
          messenger.showSnackBar(
            SnackBar(
              duration: const Duration(
                seconds: 3,
              ), // SnackBar Disappearing TimeOut.
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'حسنًا',
                textColor: Colors.white,
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                },
              ),
            ),
          );
        });
      }
    }
    // ================================================

    final surahs = _getFilteredSurahs();

    return Scaffold(
      appBar: AppBar(title: const Text('القرآن الكريم')),
      bottomNavigationBar: const MiniPlayer(),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: surahs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];
                      final isCurrent =
                          audio.currentSurahNumber == surah.number;

                      return SurahListItem(
                        surah: surah,
                        isCurrentlyPlaying: isCurrent,
                        isPlaying: isCurrent && audio.isPlaying,
                        onTap: () =>
                            _onSurahTap(surah, isCurrent, audio.isPlaying),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'لم نعثر على سورة تطابق "${_query.trim()}"',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ============================================================================
// 1. SCREEN: MENING FANLARIM (Subjects List)
// ============================================================================
class MLPSubjectsListScreen extends StatefulWidget {
  const MLPSubjectsListScreen({
    super.key,
    this.onBack,
    this.onSelectSubject,
    this.onNavTabSelected,
  });

  final VoidCallback? onBack;
  final void Function(String subjectName)? onSelectSubject;
  final void Function(int navIndex)? onNavTabSelected;

  @override
  State<MLPSubjectsListScreen> createState() => _MLPSubjectsListScreenState();
}

class _MLPSubjectsListScreenState extends State<MLPSubjectsListScreen> {
  int _filterIndex = 0; // 0: Joriy semestr, 1: Barchasi, 2: Sevimlilar ⭐
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showSearchField = false;

  final List<Map<String, dynamic>> _allSubjects = [
    {
      'title': 'Chiziqli algebra',
      'subtitle': '4 ta mavzu • 3 vazifa • 1 test',
      'progress': 0.72,
      'percent': '72%',
      'icon': 'Σ',
      'isSigma': true,
      'isFavorite': true,
      'color': const Color(0xFFA855F7),
      'isSelected': true,
    },
    {
      'title': 'Diskret tuzilmalar',
      'subtitle': '0 ta mavzu • 0 vazifa • 0 test',
      'progress': 0.0,
      'percent': '0%',
      'icon': '☊',
      'isFavorite': false,
      'color': const Color(0xFF536DFE),
      'isSelected': false,
    },
    {
      'title': 'Dasturlash (Flutter)',
      'subtitle': '8 ta mavzu • 6 vazifa • 2 test',
      'progress': 0.45,
      'percent': '45%',
      'icon': '</>',
      'isCode': true,
      'isFavorite': true,
      'color': const Color(0xFF00E5FF),
      'isSelected': false,
    },
    {
      'title': 'Ingliz tili',
      'subtitle': '6 ta mavzu • 4 vazifa • 1 test',
      'progress': 0.60,
      'percent': '60%',
      'icon': '🇬🇧',
      'isFavorite': false,
      'color': const Color(0xFF818CF8),
      'isSelected': false,
    },
    {
      'title': 'Texnik chizma',
      'subtitle': '10 ta mavzu • 8 vazifa • 3 test',
      'progress': 0.90,
      'percent': '90%',
      'icon': '⚙️',
      'isFavorite': false,
      'color': const Color(0xFF22C55E),
      'isSelected': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSubjects {
    var list = _allSubjects;
    if (_filterIndex == 2) {
      list = list.where((s) => s['isFavorite'] == true).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) => (s['title'] as String).toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mening fanlarim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Fanlar (3-semestr)',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showSearchField = !_showSearchField),
                    icon: const Icon(CupertinoIcons.search, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            if (_showSearchField)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13182E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF242C4C)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Fanni qidirish...',
                      hintStyle: TextStyle(color: Color(0xFF64748B)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

            // Filter Tabs Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _filterPill(0, 'Joriy semestr'),
                  const SizedBox(width: 8),
                  _filterPill(1, 'Barchasi'),
                  const SizedBox(width: 8),
                  _filterPill(2, 'Sevimliilar ⭐'),
                ],
              ),
            ),

            // Subjects List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                itemCount: _filteredSubjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = _filteredSubjects[index];
                  final isSel = s['isSelected'] == true;
                  return _buildSubjectCard(s, isSel);
                },
              ),
            ),

            // "+ Fan qo'shish" Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yangi fan qo‘shish oynasi')),
                  );
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x447C3AED),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Fan qo‘shish',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(int index, String label) {
    final active = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: active
              ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
              : null,
          color: active ? null : const Color(0xFF14192F),
          border: Border.all(
            color: active ? const Color(0xFFC084FC) : const Color(0xFF242C4C),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> s, bool isSelected) {
    final progress = s['progress'] as double;
    final color = s['color'] as Color;

    return InkWell(
      onTap: () => widget.onSelectSubject?.call(s['title'] as String),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? const Color(0xFF1A1338) : const Color(0xFF10152B),
          border: Border.all(
            color: isSelected ? const Color(0xFFA855F7) : const Color(0xFF1E2845),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x33A855F7),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Subject Icon Squircle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
                          : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                    ),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC084FC) : const Color(0xFF334155),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      s['icon'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: s['isCode'] == true ? 15 : 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s['subtitle'] as String,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Percentage
                Text(
                  s['percent'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2640),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. SCREEN: CHIZIQLI ALGEBRA (Subject Detail Screen)
// ============================================================================
class MLPSubjectDetailScreen extends StatefulWidget {
  const MLPSubjectDetailScreen({
    super.key,
    this.subjectName = 'Chiziqli algebra',
    this.onBack,
    this.onSelectTopic,
    this.onStartChallenge,
  });

  final String subjectName;
  final VoidCallback? onBack;
  final void Function(String topicName)? onSelectTopic;
  final VoidCallback? onStartChallenge;

  @override
  State<MLPSubjectDetailScreen> createState() => _MLPSubjectDetailScreenState();
}

class _MLPSubjectDetailScreenState extends State<MLPSubjectDetailScreen> {
  int _activeModuleTab = 0; // 0: Darslar, 1: Vazifalar, 2: Testlar, 3: Materiallar

  final List<Map<String, dynamic>> _topics = [
    {
      'title': '1. Determinant ta’rifi',
      'duration': 'Video dars (12:40)',
      'isCompleted': true,
      'isCurrent': false,
      'isLocked': false,
    },
    {
      'title': '2. Determinant xossalari',
      'duration': 'Video • 10:17',
      'isCompleted': false,
      'isCurrent': true,
      'isLocked': false,
    },
    {
      'title': '3. Minor va kofaktor',
      'duration': 'Video • 14:03',
      'isCompleted': false,
      'isCurrent': false,
      'isLocked': true,
    },
    {
      'title': '4. Amaliy misollar',
      'duration': 'Video • 11:26',
      'isCompleted': false,
      'isCurrent': false,
      'isLocked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      widget.subjectName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.info_circle, color: Colors.white, size: 22),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            // Main Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Subject Header with Wave and 72% Ring
                    _buildHeroHeader(),
                    const SizedBox(height: 16),

                    // 4 Module Sub-tabs (Darslar, Vazifalar, Testlar, Materiallar)
                    _buildModuleTabsRow(),
                    const SizedBox(height: 16),

                    // White Topics Card
                    _buildTopicsCard(),
                    const SizedBox(height: 16),

                    // Bottom "Keyingi vazifa" Action Card
                    _buildNextTaskCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171B38), Color(0xFF0F142A)],
        ),
        border: Border.all(color: const Color(0xFF26335C)),
      ),
      child: Row(
        children: [
          // Sigma Squircle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
            ),
            child: const Center(
              child: Text(
                'Σ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Credits
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Chiziqli algebra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Mavzu: Matritsalar',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Kredit: 4  |  Semestr: 2',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Circular 72% Progress Ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 0.72,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFF1E2848),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '72%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTabsRow() {
    final modules = [
      ('Darslar', CupertinoIcons.play_circle_fill),
      ('Vazifalar', CupertinoIcons.doc_text),
      ('Testlar', CupertinoIcons.check_mark_circled),
      ('Materiallar', CupertinoIcons.folder),
    ];

    return Row(
      children: List.generate(modules.length, (i) {
        final active = _activeModuleTab == i;
        final m = modules[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
            child: InkWell(
              onTap: () => setState(() => _activeModuleTab = i),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: active ? const Color(0xFF8B5CF6) : const Color(0xFF13182E),
                  border: Border.all(
                    color: active ? const Color(0xFFC084FC) : const Color(0xFF222B48),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      m.$2,
                      color: active ? Colors.white : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.$1,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopicsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Mavzular (4)" | "Barchasini ko'rish ->"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mavzular (4)',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'Barchasini ko‘rish',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(CupertinoIcons.arrow_right, color: Color(0xFF7C3AED), size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Topics
          for (var i = 0; i < _topics.length; i++) ...[
            _buildTopicTile(_topics[i]),
            if (i < _topics.length - 1)
              const Divider(color: Color(0xFFF1F5F9), height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildTopicTile(Map<String, dynamic> t) {
    final isDone = t['isCompleted'] == true;
    final isCur = t['isCurrent'] == true;
    final isLocked = t['isLocked'] == true;

    return InkWell(
      onTap: isLocked ? null : () => widget.onSelectTopic?.call(t['title'] as String),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? const Color(0xFFDCFCE7)
                    : (isCur ? const Color(0xFFEDE9FE) : const Color(0xFFF1F5F9)),
              ),
              child: Icon(
                isDone
                    ? CupertinoIcons.play_arrow_solid
                    : (isCur ? CupertinoIcons.play_arrow_solid : CupertinoIcons.lock_fill),
                color: isDone
                    ? const Color(0xFF16A34A)
                    : (isCur ? const Color(0xFF7C3AED) : const Color(0xFF94A3B8)),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),

            // Topic name & duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['title'] as String,
                    style: TextStyle(
                      color: isLocked ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t['duration'] as String,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing status indicator
            if (isDone)
              const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22)
            else if (isCur)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 14),
              )
            else
              const Icon(CupertinoIcons.lock, color: Color(0xFFCBD5E1), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildNextTaskCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.track_changes_rounded, color: Color(0xFF7C3AED), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Keyingi vazifa',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Determinant mavzusi bo‘yicha mini-test',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: widget.onStartChallenge,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Boshlash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(CupertinoIcons.arrow_right, color: Colors.white, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. SCREEN: DARS: DETERMINANT (Video Lesson & Interactive Materials View)
// ============================================================================
class MLPLessonVideoScreen extends StatefulWidget {
  const MLPLessonVideoScreen({
    super.key,
    this.lessonTitle = 'Dars: Determinant',
    this.onBack,
    this.onStartTest,
  });

  final String lessonTitle;
  final VoidCallback? onBack;
  final VoidCallback? onStartTest;

  @override
  State<MLPLessonVideoScreen> createState() => _MLPLessonVideoScreenState();
}

class _MLPLessonVideoScreenState extends State<MLPLessonVideoScreen> {
  int _activeTab = 0; // 0: Dars tafsiloti, 1: Qaydlar, 2: Savollar (12)
  bool _isPlaying = true;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      widget.lessonTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? const Color(0xFF00E5FF) : Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Video Player Card
            _buildVideoPlayerCard(),

            // Interactive Tabs & Details Sheet
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Tabs: Dars tafsiloti | Qaydlar | Savollar (12)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        children: [
                          _tabPill(0, 'Dars tafsiloti'),
                          const SizedBox(width: 8),
                          _tabPill(1, 'Qaydlar'),
                          const SizedBox(width: 8),
                          _tabPill(2, 'Savollar (12)'),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),

                    // Tab Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Lesson Heading & Description
                            const Text(
                              'Determinant ta’rifi',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Bu darsda determinant tushunchasi, uning formulasi va oddiy misollar orqali hisoblash usuli ko‘rib chiqiladi.',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 1. Dars materiallari (PDF)
                            _materialTile(
                              icon: CupertinoIcons.doc_text,
                              title: 'Dars materiallari (PDF)',
                              trailing: const Icon(Icons.download_rounded, color: Color(0xFF64748B)),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('PDF yuklanmoqda...')),
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // 2. Amaliy misollar (3 ta)
                            _materialTile(
                              icon: Icons.code,
                              title: 'Amaliy misollar (3 ta)',
                              trailing: const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
                              onTap: () {},
                            ),
                            const SizedBox(height: 10),

                            // 3. Mini-test (5 savol) with +50 XP
                            _materialTile(
                              icon: Icons.assignment_turned_in_outlined,
                              title: 'Mini-test (5 savol)',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDE9FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '+50 XP',
                                      style: TextStyle(
                                        color: Color(0xFF7C3AED),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
                                ],
                              ),
                              onTap: widget.onStartTest,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Fixed Action: "✔ Mini-testni boshlash"
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: InkWell(
                        onTap: widget.onStartTest,
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x446D28D9),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Mini-testni boshlash',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF242C4C)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Blackboard / Math representation
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Teacher avatar
                    Container(
                      width: 90,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.person_solid, color: Color(0xFF94A3B8), size: 54),
                    ),
                    const SizedBox(width: 16),

                    // Chalkboard matrix formulas
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'A = [ [2, 1], [3, 4] ]',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'det(A) = 2 · 4 - 1 · 3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '= 8 - 3 = 5',
                            style: TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Play / Pause button overlay
            GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Bottom Player controls bar
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: Row(
                children: [
                  Icon(
                    _isPlaying ? CupertinoIcons.pause : CupertinoIcons.play,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '04:16 / 12:34',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const Spacer(),
                  const Text(
                    '1.0x',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Icon(CupertinoIcons.fullscreen, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabPill(int index, String label) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? const Color(0xFF7C3AED) : const Color(0xFFF1F5F9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _materialTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/mlp_campus_entry.dart';

/// Pixel-perfect 1:1 Implementation of the MLP Campus Dashboard
class MLPCampusDashboard extends StatefulWidget {
  const MLPCampusDashboard({
    super.key,
    this.prefs,
    this.onNavigateSubject,
    this.onNavigateQuiz,
    this.onNavigateMission,
    this.onNavigateRewards,
    this.onNavigateProfile,
    this.onNavigateSchedule,
    this.onNavigateCourses,
  });

  final SharedPreferences? prefs;
  final void Function(String subjectName)? onNavigateSubject;
  final VoidCallback? onNavigateQuiz;
  final VoidCallback? onNavigateMission;
  final VoidCallback? onNavigateRewards;
  final VoidCallback? onNavigateProfile;
  final VoidCallback? onNavigateSchedule;
  final VoidCallback? onNavigateCourses;

  @override
  State<MLPCampusDashboard> createState() => _MLPCampusDashboardState();
}

class _MLPCampusDashboardState extends State<MLPCampusDashboard> {
  int _activeNavIndex = 0; // 0: Asosiy, 1: Fanlar, 2: Dars jadvali, 3: Kurslar, 4: Profil

  String get _universityName {
    final saved = widget.prefs?.getString(MLPCampusEntry.universityKey);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved.trim();
    }
    return 'FarDU';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: Stack(
        children: [
          // Background cosmic glow
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _DashboardBackdrop()),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top App Header
                _buildTopHeader(),

                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('screen_1_home'),
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Greeting & Level card row
                        _buildGreetingRow(),
                        const SizedBox(height: 18),

                        // 4 Quick Action cards row
                        _buildQuickActionsRow(),
                        const SizedBox(height: 18),

                        // "Bugungi darslar" Card
                        _buildTodayScheduleCard(),
                        const SizedBox(height: 16),

                        // Two bottom cards: "Bugungi vazifa" & "Haftalik progress"
                        _buildBottomCardsRow(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildFloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. TOP HEADER (Logo, Title, Bell with Badge, Profile Avatar)
  // =========================================================================
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          // MLP Campus Squircle Logo
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00E5FF), Color(0xFF7C3AED), Color(0xFFE040FB)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4400E5FF),
                  blurRadius: 10,
                  offset: Offset(-2, -2),
                ),
                BoxShadow(
                  color: Color(0x559333EA),
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: const RadialGradient(
                  center: Alignment(0.4, -0.4),
                  radius: 1.1,
                  colors: [Color(0xFF221142), Color(0xFF06091E)],
                ),
              ),
              child: CustomPaint(painter: _MiniMMark()),
            ),
          ),
          const SizedBox(width: 10),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'MLP Campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Universitet ta\'lim platformasi',
                  style: TextStyle(
                    color: Color(0xFF9AA3C2),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Notification Bell Button with Red '1' Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _circleGlassButton(
                icon: CupertinoIcons.bell,
                onTap: () => _showNotificationsDialog(context),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Profile Avatar Button
          _circleGlassButton(
            icon: CupertinoIcons.person_fill,
            onTap: () {
              if (widget.onNavigateProfile != null) {
                widget.onNavigateProfile!();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _circleGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF161C33).withValues(alpha: 0.85),
            border: Border.all(
              color: const Color(0xFF283256),
              width: 1.0,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. GREETING & LEVEL CARD ROW
  // =========================================================================
  Widget _buildGreetingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Salom, Aziz!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$_universityName • 2-semestr',
                style: const TextStyle(
                  color: Color(0xFF9AA3C2),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Right: Level 4 Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1438), Color(0xFF130D28)],
            ),
            border: Border.all(
              color: const Color(0xFF3B2568),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x338B5CF6),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden Crown in Circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF33205E),
                  border: Border.all(
                    color: const Color(0xFF6B3BAE),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Text('👑', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),

              // Level, XP & Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lv. 4',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '1 250 / 2 000 XP',
                    style: TextStyle(
                      color: Color(0xFF9AA3C2),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 105,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1E4C),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 105 * 0.625,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. FOUR QUICK ACTION CARDS
  // =========================================================================
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        // 1. "Mening fanlarim" (Highlighted / Light card)
        Expanded(
          child: _quickActionCard(
            title: 'Mening\nfanlarim',
            icon: CupertinoIcons.book,
            isLight: true,
            onTap: () {
              if (widget.onNavigateSubject != null) {
                widget.onNavigateSubject!('Chiziqli algebra');
              }
            },
          ),
        ),
        const SizedBox(width: 8),

        // 2. "Vazifalar" (with Badge 3)
        Expanded(
          child: _quickActionCard(
            title: 'Vazifalar',
            subtitle: 'ProofQuest',
            icon: CupertinoIcons.doc_checkmark,
            badgeCount: 3,
            onTap: () {
              if (widget.onNavigateMission != null) {
                widget.onNavigateMission!();
              }
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. "Quiz Arena"
        Expanded(
          child: _quickActionCard(
            title: 'Quiz Arena',
            icon: Icons.sports_esports_rounded,
            onTap: () {
              if (widget.onNavigateQuiz != null) {
                widget.onNavigateQuiz!();
              }
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. "Mukofotlar"
        Expanded(
          child: _quickActionCard(
            title: 'Mukofotlar',
            icon: Icons.card_giftcard_rounded,
            onTap: () {
              if (widget.onNavigateRewards != null) {
                widget.onNavigateRewards!();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    bool isLight = false,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isLight
                ? const Color(0xFFF1F3FB)
                : const Color(0xFF13182E).withValues(alpha: 0.9),
            border: Border.all(
              color: isLight ? Colors.white : const Color(0xFF222B48),
              width: 1.0,
            ),
            boxShadow: isLight
                ? const [
                    BoxShadow(
                      color: Color(0x33A855F7),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isLight ? const Color(0xFF6D28D9) : Colors.white,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isLight
                            ? const Color(0xFF1E1B4B)
                            : Colors.white,
                        fontSize: 12,
                        fontWeight:
                            isLight ? FontWeight.w800 : FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Optional badge (e.g. '3')
              if (badgeCount != null)
                Positioned(
                  top: -2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 4. "BUGUNGI DARSLAR" SCHEDULE CARD
  // =========================================================================
  Widget _buildTodayScheduleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Icon + "Bugungi darslar" | "Seshanba, 3 noyabr"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF0F172A),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Bugungi darslar',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF64748B),
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Seshanba, 3 noyabr',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Class 1: Kompyuter tarmoqlari (Cyan indicator)
          _scheduleClassItem(
            time: '08:00 – 09:20',
            subject: 'Kompyuter tarmoqlari',
            typeAndTeacher: 'Ma’ruza  •  SUYUMOV J. Y.',
            room: '8A-214',
            accentColor: const Color(0xFF38BDF8),
            onTap: () => widget.onNavigateSubject?.call('Kompyuter tarmoqlari'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Class 2: Elektronika va sxemalar (Purple indicator)
          _scheduleClassItem(
            time: '09:30 – 10:50',
            subject: 'Elektronika va sxemalar',
            typeAndTeacher: 'Laboratoriya  •  RAXMONOV B. E.',
            room: '8A-117',
            accentColor: const Color(0xFFA855F7),
            onTap: () => widget.onNavigateSubject?.call('Elektronika va sxemalar'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Class 3: Ma'lumotlar bazasi (Green indicator)
          _scheduleClassItem(
            time: '11:00 – 12:20',
            subject: 'Ma’lumotlar bazasi',
            typeAndTeacher: 'Amaliy  •  BURXONOVA M. M.',
            room: '8A-115',
            accentColor: const Color(0xFF22C55E),
            onTap: () => widget.onNavigateSubject?.call('Ma’lumotlar bazasi'),
          ),
        ],
      ),
    );
  }

  Widget _scheduleClassItem({
    required String time,
    required String subject,
    required String typeAndTeacher,
    required String room,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Vertical Colored Accent Bar
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),

            // Time
            SizedBox(
              width: 90,
              child: Text(
                time,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Subject & Teacher details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    typeAndTeacher,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Location Room Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: Color(0xFF6366F1),
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    room,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. TWO BOTTOM CARDS: "BUGUNGI VAZIFA" & "HAFTALIK PROGRESS"
  // =========================================================================
  Widget _buildBottomCardsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: "Bugungi vazifa"
        Expanded(
          flex: 14,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Target icon + "Bugungi vazifa" | "Chiziqli algebra"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.track_changes_rounded,
                          color: Color(0xFF7C3AED),
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Bugungi vazifa',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Chiziqli algebra',
                        style: TextStyle(
                          color: Color(0xFF6D28D9),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Task item with checklist icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '1. Determinant mavzusi\nbo‘yicha mini-test',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer row: Clock "~ 15 daqiqa" | Button "Bajarish ->"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF64748B),
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '~ 15 daqiqa',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.onNavigateQuiz != null) {
                          widget.onNavigateQuiz!();
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x446D28D9),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bajarish',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.arrow_right,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Right: "Haftalik progress"
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Bar chart + "Haftalik progress"
                const Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFF7C3AED),
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Haftalik progress',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stat: "3 / 5 vazifa"
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '3 / 5 ',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: 'vazifa',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Progress bar with 60%
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '60%',
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 6. FLOATING BOTTOM NAVIGATION BAR
  // =========================================================================
  Widget _buildFloatingBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1426).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF1E2845),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomNavItem(
                index: 0,
                label: 'Asosiy',
                icon: Icons.home_rounded,
                onTap: () => setState(() => _activeNavIndex = 0),
              ),
              _bottomNavItem(
                index: 1,
                label: 'Fanlar',
                icon: Icons.menu_book_rounded,
                onTap: () {
                  setState(() => _activeNavIndex = 1);
                  widget.onNavigateSubject?.call('Chiziqli algebra');
                },
              ),
              _bottomNavItem(
                index: 2,
                label: 'Dars jadvali',
                icon: Icons.calendar_today_rounded,
                onTap: () {
                  setState(() => _activeNavIndex = 2);
                  widget.onNavigateSchedule?.call();
                },
              ),
              _bottomNavItem(
                index: 3,
                label: 'Kurslar',
                icon: Icons.play_circle_outline_rounded,
                onTap: () {
                  setState(() => _activeNavIndex = 3);
                  widget.onNavigateCourses?.call();
                },
              ),
              _bottomNavItem(
                index: 4,
                label: 'Profil',
                icon: Icons.person_outline_rounded,
                onTap: () {
                  setState(() => _activeNavIndex = 4);
                  widget.onNavigateProfile?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required int index,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final active = _activeNavIndex == index;

    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x667C3AED),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bildirishnomalar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in,
                  color: Color(0xFFA855F7),
                ),
              ),
              title: const Text(
                'Yangi topshiriq biriktirildi',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: const Text(
                'Determinant mavzusi bo‘yicha mini-testni bajaring',
                style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12),
              ),
              trailing: const Text(
                'Bugun',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// CUSTOM PAINTERS: Cosmic Backdrop & Mini 'M' Icon
// =========================================================================
class _DashboardBackdrop extends CustomPainter {
  const _DashboardBackdrop();

  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF090D1E));

    // Top subtle purple atmosphere
    c.drawCircle(
      Offset(s.width * 0.5, s.height * 0.05),
      s.width * 0.8,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF7C3AED).withValues(alpha: 0.20),
            const Color(0xFF7C3AED).withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(s.width * 0.5, s.height * 0.05),
            radius: s.width * 0.8,
          ),
        ),
    );

    // Bottom-right cyan glow
    c.drawCircle(
      Offset(s.width * 0.9, s.height * 0.9),
      s.width * 0.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.12),
            const Color(0xFF00E5FF).withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(s.width * 0.9, s.height * 0.9),
            radius: s.width * 0.6,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(_DashboardBackdrop old) => false;
}

class _MiniMMark extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Path()
      ..moveTo(s.width * 0.24, s.height * 0.68)
      ..lineTo(s.width * 0.36, s.height * 0.32)
      ..quadraticBezierTo(
        s.width * 0.38,
        s.height * 0.26,
        s.width * 0.42,
        s.height * 0.34,
      )
      ..lineTo(s.width * 0.51, s.height * 0.53)
      ..quadraticBezierTo(
        s.width * 0.54,
        s.height * 0.59,
        s.width * 0.57,
        s.height * 0.53,
      )
      ..lineTo(s.width * 0.66, s.height * 0.34)
      ..quadraticBezierTo(
        s.width * 0.70,
        s.height * 0.26,
        s.width * 0.72,
        s.height * 0.32,
      )
      ..lineTo(s.width * 0.76, s.height * 0.68);

    c.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_MiniMMark old) => false;
}

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ============================================================================
// MLP QUIZ ARENA: 5-SCREEN COMPLETE FLOW
// 1. Bosh sahifa
// 2. Qo'shilish (Lobbi)
// 3. Jonli savol
// 4. Natijalar (Podium)
// 5. Tahlil va rivojlanish
// ============================================================================

class MLPQuizArenaFlow extends StatefulWidget {
  const MLPQuizArenaFlow({
    super.key,
    this.initialStep = 0,
    this.onBackToDashboard,
    this.onNavigateLesson,
  });

  final int initialStep;
  final VoidCallback? onBackToDashboard;
  final void Function(String subjectName)? onNavigateLesson;

  @override
  State<MLPQuizArenaFlow> createState() => _MLPQuizArenaFlowState();
}

class _MLPQuizArenaFlowState extends State<MLPQuizArenaFlow> {
  late int _step; // 0: Home, 1: Lobby, 2: Question, 3: Results, 4: Analysis

  // Lobby state
  String _pin = '739528';
  int _lobbyTab = 0; // 0: PIN, 1: QR

  // Question state
  int? _selectedAnswer; // 2 is correct (C: BFS yoki DFS)
  int _timerSeconds = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep.clamp(0, 4);
    if (_step == 2) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goTo(int step) {
    _timer?.cancel();
    setState(() {
      _step = step;
      if (step == 2) {
        _selectedAnswer = null;
        _timerSeconds = 15;
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_step) {
            0 => _buildScreen1Home(),
            1 => _buildScreen2Lobby(),
            2 => _buildScreen3LiveQuestion(),
            3 => _buildScreen4ResultsPodium(),
            _ => _buildScreen5Analysis(),
          },
        ),
      ),
    );
  }

  // =========================================================================
  // 1. BOSH SAHIFA: Asosiy imkoniyatlar va bugungi turnir
  // =========================================================================
  Widget _buildScreen1Home() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBackToDashboard,
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Spacer(),
              const Text('9:41', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header with Golden Trophy
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E143E), Color(0xFF120E2C)],
                    ),
                    border: Border.all(color: const Color(0xFF38236E)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x338B5CF6),
                        blurRadius: 18,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Quiz Arena',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Jonli viktorina va tezkor\nbilim sinovi',
                              style: TextStyle(
                                color: Color(0xFF9AA3C2),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Golden Trophy in pedestal
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF33205E),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66FFB800),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🏆', style: TextStyle(fontSize: 38)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3 Action Buttons
                _actionMenuTile(
                  icon: CupertinoIcons.number,
                  title: 'PIN bilan qo‘shilish',
                  onTap: () => _goTo(1),
                ),
                const SizedBox(height: 10),
                _actionMenuTile(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'QR orqali kirish',
                  onTap: () => _goTo(1),
                ),
                const SizedBox(height: 10),
                _actionMenuTile(
                  icon: Icons.bar_chart_rounded,
                  title: 'Mening o‘yinlarim',
                  onTap: () => _goTo(3),
                ),
                const SizedBox(height: 18),

                // "Fanlar" Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Fanlar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Barchasi >',
                      style: TextStyle(
                        color: Color(0xFF9AA3C2),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3 Subject Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _subjectPill('Diskret matematika', true),
                      const SizedBox(width: 8),
                      _subjectPill('Chiziqli algebra', false),
                      const SizedBox(width: 8),
                      _subjectPill('Ma’lumotlar bazasi', false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // "Bugungi turnir" Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF141933),
                    border: Border.all(color: const Color(0xFF26335C)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_today_rounded, color: Color(0xFF8B5CF6), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Bugungi turnir',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Text('🏆', style: TextStyle(fontSize: 22)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 26),
                        child: Text(
                          'Diskret matematika',
                          style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: const [
                            Icon(Icons.people_alt_outlined, color: Color(0xFF64748B), size: 16),
                            SizedBox(width: 4),
                            Text('124 talaba', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                            SizedBox(width: 16),
                            Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 16),
                            SizedBox(width: 4),
                            Text('Bugun, 16:00', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bottom Action: "Qo'shilish"
                _gradientButton('Qo‘shilish', () => _goTo(1)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. QO'SHILISH (LOBBI): PIN / QR va Kutish xonasi
  // =========================================================================
  Widget _buildScreen2Lobby() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _goTo(0),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text(
                  'O‘yinga qo‘shilish',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PIN / QR Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141933),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _toggleTab(0, 'PIN', CupertinoIcons.number),
                      ),
                      Expanded(
                        child: _toggleTab(1, 'QR', Icons.qr_code_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // "O'yin PIN-kodini kiriting"
                const Center(
                  child: Text(
                    'O‘yin PIN-kodini kiriting',
                    style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),

                // 6 Pin Digit Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final char = i < _pin.length ? _pin[i] : '';
                    return Container(
                      width: 42,
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13182E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3300E5FF),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          char,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // Subject details card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF13182E),
                    border: Border.all(color: const Color(0xFF222B48)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school_rounded, color: Color(0xFF38BDF8), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Diskret matematika',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'O‘qituvchi: dots. A. Karimov',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // "Kutish xonasi"
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141933),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF26335C)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.people_outline_rounded, color: Color(0xFF8B5CF6), size: 18),
                          SizedBox(width: 6),
                          Text('Kutish xonasi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '12 / 30',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const Text(
                        'talaba qo‘shildi',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      const SizedBox(height: 14),

                      // Avatars row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _userAvatarCircle('🧑‍🎓'),
                          _userAvatarCircle('👩‍🎓'),
                          _userAvatarCircle('👨‍💻'),
                          _userAvatarCircle('👩‍🔬'),
                          _userAvatarCircle('🧑‍🏫'),
                          Container(
                            width: 34,
                            height: 34,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF242C4C),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '+7',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Countdown timer to start
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.timer_outlined, color: Color(0xFFFFB800), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'O‘yin boshlanishiga:',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '00:20',
                        style: TextStyle(color: Color(0xFFFFB800), fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Button: "Tayyor ✓"
                _gradientButton('Tayyor ✓', () => _goTo(2)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. JONLI SAVOL: Tezkor savol, taymer, ball va 4 ta variant
  // =========================================================================
  Widget _buildScreen3LiveQuestion() {
    return Column(
      children: [
        // Top status bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _goTo(1),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Jonli o‘yin',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const Spacer(),
              Row(
                children: const [
                  Icon(Icons.people_alt_outlined, color: Color(0xFF94A3B8), size: 16),
                  SizedBox(width: 4),
                  Text('12/30', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stat Pill Row: 3/10 Savol | 15 soniya | 250 ball
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Savol count
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13182E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF222B48)),
                      ),
                      child: Column(
                        children: const [
                          Text('3 / 10', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                          Text('Savol', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        ],
                      ),
                    ),

                    // Countdown Ring Timer (15 soniya)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: _timerSeconds / 15.0,
                            strokeWidth: 5,
                            backgroundColor: const Color(0xFF1E2848),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_timerSeconds',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            const Text('soniya', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                          ],
                        ),
                      ],
                    ),

                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13182E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF222B48)),
                      ),
                      child: Row(
                        children: const [
                          Text('⭐', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Column(
                            children: [
                              Text('250', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                              Text('ball', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Question Card with Cosmic Wave
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B143A), Color(0xFF0F152E)],
                    ),
                    border: Border.all(color: const Color(0xFF332B5E)),
                  ),
                  child: const Text(
                    'Grafda bog‘langanlikni tekshirish uchun qaysi algoritm qulay?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 4 Answer Options (A, B, C, D)
                _answerOption(0, 'A', 'Deykstra algoritmi'),
                const SizedBox(height: 10),
                _answerOption(1, 'B', 'Prim algoritmi'),
                const SizedBox(height: 10),
                _answerOption(2, 'C', 'BFS yoki DFS algoritmi', isCorrect: true),
                const SizedBox(height: 10),
                _answerOption(3, 'D', 'Kruskal algoritmi'),
                const SizedBox(height: 18),

                // Streak Banner: "🔥 3 ta ketma-ket to'g'ri javob!" + "+50 ball"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E152F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF5B2B8E)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          '3 ta ketma-ket to‘g‘ri javob!',
                          style: TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '+50 ball',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Next Button
                _gradientButton('Keyingi savol →', () => _goTo(3)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 4. NATIJALAR: Podium, Reyting va Shaxsiy natija
  // =========================================================================
  Widget _buildScreen4ResultsPodium() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _goTo(2),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text(
                  'Natijalar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 3D Podium with 1st, 2nd, 3rd place
                _buildPodiumWidget(),
                const SizedBox(height: 16),

                // User placement card: "Siz 5-o'rindasiz"
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141933),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3300E5FF),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _userAvatarCircle('🧑‍🎓', size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Siz 5-o‘rindasiz',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Jami: 760 ball  •  🏆 +120 XP',
                              style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // "Fan bo'yicha natijangiz"
                const Text(
                  'Fan bo‘yicha natijangiz',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                _subjectProgressRow('Graf nazariyasi', 0.90, '90%', const Color(0xFF00E5FF)),
                const SizedBox(height: 8),
                _subjectProgressRow('Algoritmlar', 0.80, '80%', const Color(0xFF00E5FF)),
                const SizedBox(height: 8),
                _subjectProgressRow('Ma’lumotlar tuzilmalari', 0.70, '70%', const Color(0xFFA855F7)),
                const SizedBox(height: 20),

                // Two Bottom Buttons: "Tahlilni ko'rish" | "Keyingi o'yin"
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _goTo(4),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          side: const BorderSide(color: Color(0xFF26335C)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text('Tahlilni ko‘rish', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _goTo(1),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(CupertinoIcons.play_arrow_solid, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text('Keyingi o‘yin', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 5. TAHLIL VA RIVOJLANISH: Umumiy aniqlik, xatolar, tavsiyalar
  // =========================================================================
  Widget _buildScreen5Analysis() {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _goTo(3),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text(
                  'Tahlil va rivojlanish',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Ring Card: 80% Umumiy aniqlik
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF13182E),
                    border: Border.all(color: const Color(0xFF26335C)),
                  ),
                  child: Row(
                    children: [
                      // 80% Circular Gauge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 68,
                            height: 68,
                            child: CircularProgressIndicator(
                              value: 0.80,
                              strokeWidth: 6,
                              backgroundColor: const Color(0xFF1E2848),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                            ),
                          ),
                          const Text(
                            '80%',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Stat description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Umumiy aniqlik',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '8 / 10 to‘g‘ri javob',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '▲ +10% (oldingi o‘yinga nisbatan)',
                                style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // "Xatolik qilingan savollar"
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF13182E),
                    border: Border.all(color: const Color(0xFF222B48)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(CupertinoIcons.doc_text, color: Color(0xFF38BDF8), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Xatolik qilingan savollar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '2 ta savol',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // "Mavzular bo'yicha natija"
                const Text(
                  'Mavzular bo‘yicha natija',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                _subjectProgressRow('Graf nazariyasi', 0.90, '90%', const Color(0xFF00E5FF)),
                const SizedBox(height: 8),
                _subjectProgressRow('Algoritmlar', 0.80, '80%', const Color(0xFF00E5FF)),
                const SizedBox(height: 8),
                _subjectProgressRow('Determinant', 0.60, '60%', const Color(0xFFFFB800)),
                const SizedBox(height: 16),

                // Weak Spot Recommendation Card (links directly to Determinant topic!)
                InkWell(
                  onTap: () {
                    widget.onNavigateLesson?.call('Determinant');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF241618),
                      border: Border.all(color: const Color(0xFF993B45)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_rounded, color: Color(0xFFFFB800), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Kuchsiz mavzu: Determinant',
                                style: TextStyle(color: Color(0xFFFF85A1), fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tavsiya: 2 ta video + 1 amaliy test',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_right, color: Color(0xFFFF85A1), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Level / Rank: "Bilim darajangiz: Tajribali (B2)"
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF13182E),
                    border: Border.all(color: const Color(0xFF26335C)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF38BDF8)),
                        ),
                        child: const Center(child: Text('💎', style: TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bilim darajangiz',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            const Text(
                              'Tajribali (B2)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2848),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: 2450 / 3000,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '2 450 / 3 000 XP',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // HELPER SUBWIDGETS
  // =========================================================================
  Widget _actionMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF13182E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF222B48)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF38BDF8), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _subjectPill(String name, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E143E) : const Color(0xFF11172E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFA855F7) : const Color(0xFF00E5FF).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: isSelected ? const Color(0xFFD8B4FE) : Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _toggleTab(int index, String label, IconData icon) {
    final active = _lobbyTab == index;
    return GestureDetector(
      onTap: () => setState(() => _lobbyTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF8B5CF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _answerOption(int index, String letter, String text, {bool isCorrect = false}) {
    final selected = _selectedAnswer == index;
    final showCorrect = isCorrect && _selectedAnswer != null;

    Color border = const Color(0xFF222B48);
    Color bg = const Color(0xFF13182E);

    if (showCorrect) {
      border = const Color(0xFF22C55E);
      bg = const Color(0xFF14532D);
    } else if (selected) {
      border = const Color(0xFF8B5CF6);
      bg = const Color(0xFF2E1065);
    }

    return InkWell(
      onTap: () => setState(() => _selectedAnswer = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: showCorrect ? const Color(0xFF22C55E) : const Color(0xFF222B48),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _podiumColumn(place: 2, name: 'D. Sevinch', score: '920 ball', avatar: '👩‍🎓', height: 75),
          const SizedBox(width: 10),
          // 1st Place (Crown)
          _podiumColumn(place: 1, name: 'O. Anvar', score: '980 ball', avatar: '🧑‍🎓', height: 105, isFirst: true),
          const SizedBox(width: 10),
          // 3rd Place
          _podiumColumn(place: 3, name: 'M. Aziz', score: '890 ball', avatar: '👨‍🎓', height: 55),
        ],
      ),
    );
  }

  Widget _podiumColumn({
    required int place,
    required String name,
    required String score,
    required String avatar,
    required double height,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (isFirst) const Text('👑', style: TextStyle(fontSize: 20)),
        _userAvatarCircle(avatar, size: isFirst ? 46 : 38),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
        Text(score, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
        const SizedBox(height: 8),

        // Pedestal step
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: isFirst ? const Color(0xFFF59E0B) : const Color(0xFF1E1B4B),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: isFirst ? const Color(0xFFFBBF24) : const Color(0xFF3B2D78)),
          ),
          child: Center(
            child: Text(
              '$place',
              style: TextStyle(
                color: isFirst ? Colors.black : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _subjectProgressRow(String name, double factor, String percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(name, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2848),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: factor,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(percent, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _userAvatarCircle(String emoji, {double size = 32}) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2848),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.5))),
    );
  }

  Widget _gradientButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

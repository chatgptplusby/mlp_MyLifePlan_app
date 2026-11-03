import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/mlp_campus_entry.dart';
import 'mlp_campus_dashboard.dart';
import 'mlp_subjects_flow.dart';
import 'mlp_quiz_arena_flow.dart';
import 'mlp_campus_market_flow.dart';
import 'mlp_campus_profile_flow.dart';

// ============================================================================
// MLP CAMPUS UNIFIED LOGIC & NAVIGATION HUB
// Seamlessly connects all 6 flows:
// 1. Entry (Welcome -> Onboarding -> University selection)
// 2. Dashboard (Salom Aziz, Lv. 4, Bugungi darslar/vazifa, Bottom Nav)
// 3. Subjects & Lessons (Chiziqli algebra, Determinant, Video, Mini-test)
// 4. Quiz Arena (Lobby, Live questions, Results, Weak topic recommendation)
// 5. Market / Rewards (Vouchers, Radar map, Filters, Coin wallet)
// 6. Profile & Communication (Achievements, Partners, Dodo, Petitions, Chat)
// + "Coin qanday ishlaydi?" explanatory interactive bottom sheet
// ============================================================================

class MLPCampusHub extends StatefulWidget {
  const MLPCampusHub({
    super.key,
    this.prefs,
    this.initialRoute = 'dashboard', // 'entry', 'dashboard', 'subjects', 'quiz', 'market', 'profile'
  });

  final SharedPreferences? prefs;
  final String initialRoute;

  @override
  State<MLPCampusHub> createState() => _MLPCampusHubState();
}

class _MLPCampusHubState extends State<MLPCampusHub> {
  late String _activeFlow;
  int _coins = 2450;

  // Subjects Flow Sub-Navigation
  int _subjectSubScreen = 0; // 0: list, 1: detail, 2: lesson
  String _selectedSubject = 'Chiziqli algebra';
  String _selectedTopic = '1. Determinant ta’rifi';

  // Market & Profile Sub-Navigation
  int _marketSubScreen = 0;
  int _profileSubScreen = 0;
  int _quizInitialStep = 0;

  @override
  void initState() {
    super.initState();
    _activeFlow = widget.initialRoute;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _activeFlow == 'dashboard',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _activeFlow != 'dashboard') {
          setState(() => _activeFlow = 'dashboard');
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildCurrentFlow(),
      ),
    );
  }

  Widget _buildCurrentFlow() {
    switch (_activeFlow) {
      case 'entry':
        if (widget.prefs != null) {
          return MLPCampusEntry(
            key: const ValueKey('flow_entry'),
            prefs: widget.prefs!,
            onComplete: () => setState(() => _activeFlow = 'dashboard'),
          );
        }
        return MLPCampusDashboard(
          key: const ValueKey('flow_dashboard'),
          prefs: widget.prefs,
          onNavigateSubject: (subject) => setState(() {
            _selectedSubject = subject;
            _subjectSubScreen = 1;
            _activeFlow = 'subjects';
          }),
        );

      case 'subjects':
        return _buildSubjectsFlow();

      case 'quiz':
        return MLPQuizArenaFlow(
          key: const ValueKey('flow_quiz'),
          initialStep: _quizInitialStep,
          onBackToDashboard: () => setState(() => _activeFlow = 'dashboard'),
          onNavigateLesson: (subject) {
            setState(() {
              _selectedSubject = subject;
              _subjectSubScreen = 2; // Jump straight to lesson
              _activeFlow = 'subjects';
            });
          },
        );

      case 'market':
        return MLPCampusMarketFlow(
          key: const ValueKey('flow_market'),
          initialScreen: _marketSubScreen,
          initialCoins: _coins,
          onBackToDashboard: () => setState(() => _activeFlow = 'dashboard'),
        );

      case 'profile':
        return MLPCampusProfileFlow(
          key: const ValueKey('flow_profile'),
          initialScreen: _profileSubScreen,
          onBackToDashboard: () => setState(() => _activeFlow = 'dashboard'),
          onOpenMarket: () => setState(() {
            _marketSubScreen = 0;
            _activeFlow = 'market';
          }),
        );

      case 'dashboard':
      default:
        return MLPCampusDashboard(
          key: const ValueKey('flow_dashboard'),
          prefs: widget.prefs,
          onNavigateSubject: (subject) {
            setState(() {
              _selectedSubject = subject;
              _subjectSubScreen = 1; // Open subject detail
              _activeFlow = 'subjects';
            });
          },
          onNavigateQuiz: () {
            setState(() {
              _quizInitialStep = 0;
              _activeFlow = 'quiz';
            });
          },
          onNavigateMission: () {
            _showTasksModal();
          },
          onNavigateRewards: () {
            setState(() {
              _marketSubScreen = 0;
              _activeFlow = 'market';
            });
          },
          onNavigateProfile: () {
            setState(() {
              _profileSubScreen = 0;
              _activeFlow = 'profile';
            });
          },
          onNavigateCourses: () {
            _showCoursesModal();
          },
          onNavigateSchedule: () {
            _showScheduleModal();
          },
          onCoinInfo: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF0F1428),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (ctx) => _CoinHowItWorksSheet(
              coins: _coins,
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
    }
  }

  // --------------------------------------------------------------------------
  // Subjects Flow Sub-Navigation
  // --------------------------------------------------------------------------
  Widget _buildSubjectsFlow() {
    if (_subjectSubScreen == 1) {
      return MLPSubjectDetailScreen(
        key: const ValueKey('subjects_detail'),
        subjectName: _selectedSubject,
        onBack: () => setState(() => _subjectSubScreen = 0),
        onSelectTopic: (topic) {
          setState(() {
            _selectedTopic = topic;
            _subjectSubScreen = 2;
          });
        },
        onStartChallenge: () {
          setState(() {
            _quizInitialStep = 1; // Lobby PIN
            _activeFlow = 'quiz';
          });
        },
      );
    }

    if (_subjectSubScreen == 2) {
      return MLPLessonVideoScreen(
        key: const ValueKey('subjects_lesson'),
        lessonTitle: _selectedTopic,
        onBack: () => setState(() => _subjectSubScreen = 1),
        onStartTest: () {
          setState(() {
            _quizInitialStep = 2; // Live question
            _activeFlow = 'quiz';
          });
        },
      );
    }

    return MLPSubjectsListScreen(
      key: const ValueKey('subjects_list'),
      onBack: () => setState(() => _activeFlow = 'dashboard'),
      onSelectSubject: (sub) {
        setState(() {
          _selectedSubject = sub;
          _subjectSubScreen = 1;
        });
      },
      onNavTabSelected: _handleNavTab,
    );
  }

  void _handleNavTab(int index) {
    setState(() {
      switch (index) {
        case 0:
          _activeFlow = 'dashboard';
          break;
        case 1:
          _activeFlow = 'subjects';
          _subjectSubScreen = 0;
          break;
        case 2:
          _showScheduleModal();
          break;
        case 3:
          _quizInitialStep = 0;
          _activeFlow = 'quiz';
          break;
        case 4:
          _profileSubScreen = 0;
          _activeFlow = 'profile';
          break;
      }
    });
  }

  void _showTasksModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1428),
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
                const Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 8),
                    Text(
                      'Bugungi vazifalar (3)',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _interactiveRow(
              tag: '15 daq',
              title: '1. Determinant mini-test',
              sub: 'Chiziqli algebra • +50 XP, +25 Coin',
              actionLabel: 'Bajarish',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedSubject = 'Chiziqli algebra';
                  _subjectSubScreen = 2;
                  _activeFlow = 'subjects';
                });
              },
            ),
            const SizedBox(height: 8),
            _interactiveRow(
              tag: '25 daq',
              title: '2. Tarmoq topologiyasi',
              sub: 'Kompyuter tarmoqlari • +40 XP',
              actionLabel: 'O‘tish',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedSubject = 'Kompyuter tarmoqlari';
                  _subjectSubScreen = 1;
                  _activeFlow = 'subjects';
                });
              },
            ),
            const SizedBox(height: 8),
            _interactiveRow(
              tag: '30 daq',
              title: '3. SQL JOIN laboratoriya',
              sub: 'Ma’lumotlar bazasi • +60 XP',
              actionLabel: 'O‘tish',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedSubject = 'Ma’lumotlar bazasi';
                  _subjectSubScreen = 1;
                  _activeFlow = 'subjects';
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCoursesModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1428),
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
                const Row(
                  children: [
                    Icon(Icons.play_lesson_rounded, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 8),
                    Text(
                      'Tavsiya etilgan kurslar',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _interactiveRow(
              tag: 'Mobil',
              title: 'Dasturlash (Flutter & Dart)',
              sub: '8 ta mavzu • 6 vazifa • 2 test',
              actionLabel: 'Boshlash',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedSubject = 'Dasturlash (Flutter)';
                  _subjectSubScreen = 1;
                  _activeFlow = 'subjects';
                });
              },
            ),
            const SizedBox(height: 8),
            _interactiveRow(
              tag: 'Algoritm',
              title: 'Diskret matematika va algoritmlar',
              sub: 'Quiz Arena ligasi uchun maxsus kurs',
              actionLabel: 'Kirish',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _quizInitialStep = 0;
                  _activeFlow = 'quiz';
                });
              },
            ),
            const SizedBox(height: 8),
            _interactiveRow(
              tag: 'Ingliz tili',
              title: 'IT mutaxassislari uchun ingliz tili',
              sub: '6 ta mavzu • 4 vazifa • B2 daraja',
              actionLabel: 'Tanlash',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedSubject = 'Ingliz tili';
                  _subjectSubScreen = 1;
                  _activeFlow = 'subjects';
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _interactiveRow({
    required String tag,
    required String title,
    required String sub,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF13182E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF222B48)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(actionLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1428),
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
                  'Bugungi dars jadvali',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _scheduleRow('08:00 - 09:20', 'Kompyuter tarmoqlari', 'Ma’ruza • SUYUMOV J. Y.', '8A-214'),
            const SizedBox(height: 8),
            _scheduleRow('09:30 - 10:50', 'Elektronika va sxemalar', 'Laboratoriya • RAXMONOV B. E.', '8A-117'),
            const SizedBox(height: 8),
            _scheduleRow('11:00 - 12:20', 'Ma’lumotlar bazasi', 'Amaliy • BURXONOVA M. M.', '8A-115'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _scheduleRow(String time, String title, String sub, String room) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2544),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(room, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// "Coin qanday ishlaydi?" Interactive Explanatory Sheet (1:1 with mockup footer)
// ============================================================================
class _CoinHowItWorksSheet extends StatelessWidget {
  const _CoinHowItWorksSheet({
    required this.coins,
    required this.onClose,
  });

  final int coins;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🪙', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Coin qanday ishlaydi?',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5-Step Process Card (Matching the poster diagram 1:1)
          _stepRow(
            step: '1',
            emoji: '🎓',
            title: 'Vazifa va testlarni bajar',
            desc: 'O‘qish, test, faoliyat va boshqa topshiriqlarni yakunlang.',
          ),
          const SizedBox(height: 10),
          _stepRow(
            step: '2',
            emoji: '🪙',
            title: 'Coin yig‘',
            desc: 'Bajarilgan har bir vazifa va quizlar evaziga coinlar to‘plang.',
          ),
          const SizedBox(height: 10),
          _stepRow(
            step: '3',
            emoji: '🎁',
            title: 'Hamkorlar bonusini tanla',
            desc: 'Yig‘ilgan coinlar evaziga chegirma, kupon va bonuslarni tanlang.',
          ),
          const SizedBox(height: 10),
          _stepRow(
            step: '4',
            emoji: '🔲',
            title: 'Voucher ol',
            desc: 'Kuponni tasdiqlang va maxsus QR-kodli vaucherni qo‘lga kiriting.',
          ),
          const SizedBox(height: 10),
          _stepRow(
            step: '5',
            emoji: '🏪',
            title: 'Lokatsiyaga borib foydalan',
            desc: 'Hamkorimiz filialiga borib chegirmadan unumli foydalaning.',
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Tushundim, boshlaymiz!',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow({
    required String step,
    required String emoji,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF222B48),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ============================================================================
// MLP CAMPUS PROFILE & COMMUNICATION ECOSYSTEM
// 1:1 Implementation of the 9-screen Profile & Governance flow:
// 1. Profil (Avatar, Level 4 card, Stats 12/5/8, Menu list)
// 2. Mening yutuqlarim (Bilimdon talaba badge 5/5, 6 badges grid)
// 3. Hamkorlar va bonuslar (Coin card, Categories, Top Partners)
// 4. Dodo Pizza Partner Detail (Hero, 15% discount, 800 coin, Voucher olish)
// 5. Yaqin atrofdagi hamkorlar (Radar map, Dodo card, Marshrut 5 daqiqa)
// 6. Ma'muriyatga murojaat (Rektor, Zamdekan, Dekanat, O'qituvchi)
// 7. Rektorga xabar (1:1 direct chat with live message sending)
// 8. Murojaat shakli (Topic dropdown, text area, PDF attach, Yuborish)
// 9. Mening murojaatlarim (Status cards: Yakunlangan, Jarayonda)
// ============================================================================

class MLPCampusProfileFlow extends StatefulWidget {
  const MLPCampusProfileFlow({
    super.key,
    this.initialScreen = 0,
    this.onBackToDashboard,
    this.onOpenMarket,
  });

  final int initialScreen;
  final VoidCallback? onBackToDashboard;
  final VoidCallback? onOpenMarket;

  @override
  State<MLPCampusProfileFlow> createState() => _MLPCampusProfileFlowState();
}

class _MLPCampusProfileFlowState extends State<MLPCampusProfileFlow> {
  late int _screen; // 0: Profil, 1: Yutuqlar, 2: Hamkorlar, 3: Partner Detail,
  // 4: Map, 5: Murojaat Hub, 6: Rektor Chat, 7: Murojaat Form, 8: Mening Murojaatlarim

  // Screen 3 Partner tab filter
  int _partnerPrimaryTab = 0; // 0: Hamkorlar, 1: Voucherlar, 2: Magazin
  int _partnerCategoryIndex = 0; // 0: Barchasi, 1: Taom, 2: Kitob, 3: Ta'lim, 4: Boshqa

  // Screen 9 Petition filter
  int _petitionFilterIndex = 0; // 0: Barchasi, 1: Jarayonda, 2: Yakunlangan

  // Chat state
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'isUser': true,
      'text': 'Assalomu alaykum, hurmatli rektor. Universitet hududida talabalarga mo‘ljallangan Wi-Fi qamrovini kengaytirish bo‘yicha taklifim bor.',
      'time': '14:24',
    },
    {
      'isUser': false,
      'text': 'Vaalaykum assalom, Azizbek. Taklifingizni qabul qildik. Masalani tegishli bo‘lim bilan ko‘rib chiqamiz.',
      'time': '15:10',
    },
  ];

  // Petition Form state
  String _selectedTopic = 'Infratuzilma (Wi-Fi, xona, jihozlar)';
  final TextEditingController _petitionTextController = TextEditingController(
    text: 'Talabalar foydalanadigan Wi-Fi qamrovini yangi binolarga ham kengaytirish taklifini bildiraman.',
  );
  String? _attachedFileName = 'Taklif.pdf';

  // Petitions list state
  final List<Map<String, dynamic>> _petitions = [
    {
      'title': 'Wi-Fi qamrovini kengaytirish',
      'status': 'Yakunlangan',
      'date': '2 noy, 2026',
      'isDone': true,
    },
    {
      'title': 'Dars jadvalini optimallashtirish',
      'status': 'Jarayonda',
      'date': '30 okt, 2026',
      'isDone': false,
    },
    {
      'title': 'Kutubxonada yangi kitoblar',
      'status': 'Yakunlangan',
      'date': '25 okt, 2026',
      'isDone': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _screen = widget.initialScreen;
  }

  @override
  void dispose() {
    _chatController.dispose();
    _petitionTextController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add({
        'isUser': true,
        'text': text,
        'time': 'Hozir',
      });
      _chatController.clear();
    });
  }

  void _submitPetition() {
    final text = _petitionTextController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _petitions.insert(0, {
        'title': _selectedTopic.split('(').first.trim(),
        'status': 'Jarayonda',
        'date': 'Bugun',
        'isDone': false,
      });
      _screen = 8; // go to petitions list
    });
  }

  void _showCoinHowItWorksModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1428),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Coin qanday ishlaydi?',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _lifecycleStep('1', '🎓', 'Vazifa va testlarni bajar', 'O‘qish, test, faoliyat va boshqa topshiriqlar.'),
            const SizedBox(height: 8),
            _lifecycleStep('2', '🪙', 'Coin yig‘', 'Bajarilgan vazifalar evaziga coinlar to‘plash.'),
            const SizedBox(height: 8),
            _lifecycleStep('3', '🎁', 'Hamkorlar bonusini tanla', 'Yig‘ilgan coinlar evaziga chegirma va bonuslar olish.'),
            const SizedBox(height: 8),
            _lifecycleStep('4', '🔲', 'Voucher ol', 'QR-kodli maxsus vaucherni yaratish.'),
            const SizedBox(height: 8),
            _lifecycleStep('5', '🏪', 'Lokatsiyaga borib foydalan', 'Filialga borib chegirmadan bahramand bo‘lish.'),
          ],
        ),
      ),
    );
  }

  Widget _lifecycleStep(String step, String emoji, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF222B48),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (_screen) {
            0 => _buildScreen1Profile(),
            1 => _buildScreen2Achievements(),
            2 => _buildScreen3Partners(),
            3 => _buildScreen4PartnerDetail(),
            4 => _buildScreen5PartnerMap(),
            5 => _buildScreen6AdministrationHub(),
            6 => _buildScreen7RektorChat(),
            7 => _buildScreen8PetitionForm(),
            _ => _buildScreen9MyPetitions(),
          },
        ),
      ),
    );
  }

  // =========================================================================
  // 1. PROFIL
  // =========================================================================
  Widget _buildScreen1Profile() {
    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onBackToDashboard,
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Text('Profil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // User Avatar & Name
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A2050), Color(0xFF131535)],
                            ),
                          ),
                          child: const Center(
                            child: Text('👨‍🎓', style: TextStyle(fontSize: 42)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Azizbek Karimov',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.verified_rounded, color: Color(0xFF8B5CF6), size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'FarDU • Informatika • 2-semestr',
                      style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Level 4 Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A3A), Color(0xFF10142A)],
                  ),
                  border: Border.all(color: const Color(0xFF2C2F58)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E235C),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('👑', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Lv. 4', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              Text('1 250 / 2 000 XP', style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const LinearProgressIndicator(
                        value: 1250 / 2000,
                        backgroundColor: Color(0xFF1E2442),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3 Stats Tiles: 12 Kun ketma-ket | 5 Yutuq | 8 Kurs
              Row(
                children: [
                  _profileStat('12', 'Kun ketma-ket', '🔥'),
                  const SizedBox(width: 8),
                  _profileStat('5', 'Yutuq', '🏆'),
                  const SizedBox(width: 8),
                  _profileStat('8', 'Kurs', '📚'),
                ],
              ),
              const SizedBox(height: 20),

              // Menu List
              _menuItem(Icons.emoji_events_outlined, 'Mening yutuqlarim', onTap: () => setState(() => _screen = 1)),
              _menuItem(Icons.bar_chart_rounded, 'Statistika', onTap: () => setState(() => _screen = 1)),
              _menuItem(Icons.card_giftcard_rounded, 'Hamkorlar va bonuslar', onTap: () => setState(() => _screen = 2)),
              _menuItem(
                Icons.account_balance_outlined,
                'Ma‘muriyatga murojaat',
                hasNotification: true,
                onTap: () => setState(() => _screen = 5),
              ),
              _menuItem(Icons.settings_outlined, 'Sozlamalar'),
              const SizedBox(height: 10),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF222B48)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _bottomNavItem(icon: Icons.home_rounded, label: 'Asosiy', isSelected: false, onTap: () => widget.onBackToDashboard?.call()),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _bottomNavItem(icon: Icons.menu_book_rounded, label: 'Fanlar', isSelected: false, onTap: () => widget.onBackToDashboard?.call()),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _bottomNavItem(icon: Icons.calendar_today_rounded, label: 'Dars jadvali', isSelected: false, onTap: () => widget.onBackToDashboard?.call()),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _bottomNavItem(icon: Icons.card_giftcard_rounded, label: 'Mukofotlar', isSelected: false, onTap: () => widget.onOpenMarket?.call()),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _bottomNavItem(icon: Icons.person_rounded, label: 'Profil', isSelected: true, onTap: () {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x668B5CF6),
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
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

  Widget _profileStat(String val, String label, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13182E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF222B48)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {bool hasNotification = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasNotification)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. MENING YUTUQLARIM
  // =========================================================================
  Widget _buildScreen2Achievements() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 0),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text('Mening yutuqlarim', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        // Tabs: Yutuqlar | Medallar | Reyting
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _pillTab('Yutuqlar', true),
                const SizedBox(width: 8),
                _pillTab('Medallar', false),
                const SizedBox(width: 8),
                _pillTab('Reyting', false),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Hero Badge: Bilimdon talaba
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1E46), Color(0xFF10142C)],
                  ),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                ),
                child: Column(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text('Bilimdon talaba', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    const Text('5 ta fan bo‘yicha 70%+ natija', style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Color(0xFF1E2442),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('5 / 5', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Badges Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  _badgeCard('Izchil o‘quvchi', '📅', isUnlocked: true),
                  _badgeCard('Test ustasi', '🎯', isUnlocked: true),
                  _badgeCard('Top 10', '🏆', isUnlocked: true),
                  _badgeCard('Faol talaba', '👥', isUnlocked: true),
                  _badgeCard('Kurs yaratuvchi', '🔒', isUnlocked: false),
                  _badgeCard('Mentor', '🔒', isUnlocked: false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pillTab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8B5CF6) : const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : const Color(0xFF9AA3C2), fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _segmentedTab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8B5CF6) : const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : const Color(0xFF9AA3C2), fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _badgeCard(String title, String emoji, {required bool isUnlocked}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              if (isUnlocked)
                const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16)
              else
                const Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. HAMKORLAR VA BONUSLAR
  // =========================================================================
  Widget _buildScreen3Partners() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 0),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text('Hamkorlar va bonuslar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Coin Balance Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF20163C), Color(0xFF131530)],
                  ),
                  border: Border.all(color: const Color(0xFF4C2F8A)),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Mening coinlarim', style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12)),
                          Text('2 450', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onOpenMarket?.call(),
                      child: const Text('Coin tarixi >', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Primary Tabs: Hamkorlar | Voucherlar | Magazin
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _partnerPrimaryTab = 0),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Hamkorlar', _partnerPrimaryTab == 0),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _partnerPrimaryTab = 1),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Voucherlar', _partnerPrimaryTab == 1),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() => _partnerPrimaryTab = 2);
                        widget.onOpenMarket?.call();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Magazin', _partnerPrimaryTab == 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Categories Filter: Barchasi | Taom | Kitob | Ta'lim | Boshqa
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _partnerCategoryIndex = 0),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Barchasi', _partnerCategoryIndex == 0),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _partnerCategoryIndex = 1),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Taom', _partnerCategoryIndex == 1),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _partnerCategoryIndex = 2),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Kitob', _partnerCategoryIndex == 2),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _partnerCategoryIndex = 3),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Ta‘lim', _partnerCategoryIndex == 3),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _partnerCategoryIndex = 4),
                      borderRadius: BorderRadius.circular(14),
                      child: _pillTab('Boshqa', _partnerCategoryIndex == 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Partners List
              _partnerRowItem(
                title: 'Dodo Pizza',
                promo: 'Pitsaga 15% chegirma',
                cost: '800',
                isNew: true,
                iconEmoji: '🍕',
                onTap: () => setState(() => _screen = 3),
              ),
              _partnerRowItem(
                title: 'Asaxiy',
                promo: 'Kitoblarga 10% chegirma',
                cost: '1 200',
                iconEmoji: '📚',
                onTap: () => setState(() => _screen = 3),
              ),
              _partnerRowItem(
                title: 'Najot Ta‘lim',
                promo: 'Kurslarga 20% chegirma',
                cost: '1 500',
                iconEmoji: '🎓',
                onTap: () => setState(() => _screen = 3),
              ),
              const SizedBox(height: 14),

              // "Eng yaqin hamkorlar" Banner button
              InkWell(
                onTap: () => setState(() => _screen = 4),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13182E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF222B48)),
                  ),
                  child: Row(
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Eng yaqin hamkorlar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('Sizga yaqin manzillar', style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // "Coin qanday ishlaydi?" Interactive Explanatory Banner
              InkWell(
                onTap: _showCoinHowItWorksModal,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1B4E), Color(0xFF141738)],
                    ),
                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🪙', style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Coin qanday ishlaydi?',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right, color: Color(0xFF8B5CF6), size: 16),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            _CoinStepPill('🎓', 'Vazifa bajar'),
                            _ArrowDivider(),
                            _CoinStepPill('🪙', 'Coin yig‘'),
                            _ArrowDivider(),
                            _CoinStepPill('🎁', 'Bonus tanla'),
                            _ArrowDivider(),
                            _CoinStepPill('🔲', 'Voucher ol'),
                            _ArrowDivider(),
                            _CoinStepPill('🏪', 'Lokatsiyada ishlat'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _partnerRowItem({
    required String title,
    required String promo,
    required String cost,
    required String iconEmoji,
    bool isNew = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2544),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(iconEmoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            if (isNew) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Yangi', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(promo, style: const TextStyle(color: Color(0xFF9AA3C2), fontSize: 11)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(cost, style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 4. DODO PIZZA PARTNER DETAIL
  // =========================================================================
  Widget _buildScreen4PartnerDetail() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 2),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.heart, color: Colors.white70, size: 22),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Hero Image Card
              Container(
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF351B08), Color(0xFF181525)],
                  ),
                  border: Border.all(color: const Color(0xFF6B3A10)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🍕', style: TextStyle(fontSize: 54)),
                      SizedBox(height: 6),
                      Text('DODO PIZZA', style: TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Distance
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Dodo Pizza', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(width: 12),
                    Text('• 1.2 km', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
              const Text('Taom va ichimlik', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 14),

              // Promo Banner (15% chegirma | 800 coin)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF162E20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('15% chegirma', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w900, fontSize: 16)),
                          SizedBox(width: 16),
                          Text('🪙 800 coin', style: TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Chegirma barcha pitsalar va ichimliklar uchun amal qiladi.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF13182E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: Column(
                  children: const [
                    _detailInfoRow(Icons.access_time_rounded, 'Ish vaqti', '10:00 - 23:00'),
                    SizedBox(height: 10),
                    _detailInfoRow(Icons.location_on_outlined, 'Manzil', 'Farg‘ona sh., I.Karimov ko‘ch. 45'),
                    SizedBox(height: 10),
                    _detailInfoRow(Icons.navigation_outlined, 'Marshrut', 'Navigator‘da ochish'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Button: Voucher olish (800 coin)
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voucher muvaffaqiyatli olindi!'), backgroundColor: Color(0xFF10B981)),
                  );
                },
                icon: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
                label: const Text('Voucher olish (800 coin)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 5. YAQIN ATROFDAGI HAMKORLAR (Full Map View)
  // =========================================================================
  Widget _buildScreen5PartnerMap() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 2),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text('Yaqin atrofdagi hamkorlar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        // Categories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _pillTab('Barchasi', true),
                const SizedBox(width: 8),
                _pillTab('Taom', false),
                const SizedBox(width: 8),
                _pillTab('Kitob', false),
                const SizedBox(width: 8),
                _pillTab('Ta‘lim', false),
              ],
            ),
          ),
        ),

        // Map View Canvas
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF0C1024),
              border: Border.all(color: const Color(0xFF222B48)),
            ),
            child: Stack(
              children: [
                // Faint street grid lines
                CustomPaint(
                  size: Size.infinite,
                  painter: _MapGridPainter(),
                ),

                // Radar concentric rings
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x3338BDF8), width: 1.2),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x4438BDF8), width: 1.2),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x5538BDF8), width: 1.2),
                    ),
                  ),
                ),

                // Current location center pulse dot
                Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x4438BDF8),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),
                ),

                // Partner Pin 1 (Top: Taom / Food)
                Positioned(
                  top: 70,
                  left: 110,
                  child: _mapPin(color: const Color(0xFFFF9800), icon: Icons.restaurant_rounded),
                ),

                // Partner Pin 2 (Right: Taom / Food)
                Positioned(
                  top: 130,
                  right: 50,
                  child: _mapPin(color: const Color(0xFFFF9800), icon: Icons.restaurant_rounded),
                ),

                // Partner Pin 3 (Left: Kitob / Shop)
                Positioned(
                  top: 180,
                  left: 45,
                  child: _mapPin(color: const Color(0xFF2563EB), icon: Icons.shopping_bag_rounded),
                ),

                // Partner Pin 4 (Bottom Right: Taom / Food)
                Positioned(
                  bottom: 110,
                  right: 85,
                  child: _mapPin(color: const Color(0xFFFF9800), icon: Icons.restaurant_rounded),
                ),

                // Location crosshair button on right
                Positioned(
                  bottom: 110,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13182E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF222B48)),
                    ),
                    child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                  ),
                ),

                // Card at bottom
                Positioned(
                  bottom: 12,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13182E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF222B48)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.local_pizza_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Dodo Pizza', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                              SizedBox(height: 2),
                              Text('1.2 km • 10:00 - 23:00', overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.navigation_outlined, color: Colors.white, size: 12),
                              SizedBox(width: 3),
                              Text('Marshrut (5 daqiqa)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapPin({required Color color, required IconData icon}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // =========================================================================
  // 6. MA'MURIYATGA MUROJAAT (Administration Hub)
  // =========================================================================
  Widget _buildScreen6AdministrationHub() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 0),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text('Ma‘muriyatga murojaat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => setState(() => _screen = 8),
                icon: const Icon(Icons.history_rounded, color: Colors.white70, size: 22),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Universitet rahbariyatiga rasmiy murojaat',
              style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _adminContactTile('Rektor', 'Universitet boshqaruvchisi', '👨‍💼', onTap: () => setState(() => _screen = 6)),
              _adminContactTile('Zamdekan', 'Ta‘lim jarayoni bo‘yicha', '👩‍💼', onTap: () => setState(() => _screen = 7)),
              _adminContactTile('Dekanat', 'Fakultet masalalari', '🏛️', onTap: () => setState(() => _screen = 7)),
              _adminContactTile('O‘qituvchi', 'Fan va baholar bo‘yicha', '🧑‍🏫', onTap: () => setState(() => _screen = 7)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adminContactTile(String role, String sub, String avatar, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF222B48)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF1E2544),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(avatar, style: const TextStyle(fontSize: 22))),
        ),
        title: Text(role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        trailing: const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
      ),
    ),
  );
}

  // =========================================================================
  // 7. REKTORGA XABAR (1:1 Chat)
  // =========================================================================
  Widget _buildScreen7RektorChat() {
    return Column(
      children: [
        // Top chat bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E2544))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 5),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF1E2544),
                child: Text('👨‍💼', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rektor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    Row(
                      children: const [
                        CircleAvatar(radius: 3, backgroundColor: Color(0xFF22C55E)),
                        SizedBox(width: 4),
                        Text('Onlayn', style: TextStyle(color: Color(0xFF22C55E), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Chat message list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2544),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Bugun', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ),
              ),
              const SizedBox(height: 16),

              ..._chatMessages.map((msg) {
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF7C3AED) : const Color(0xFF13182E),
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomRight: isUser ? Radius.zero : const Radius.circular(18),
                        bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
                      ),
                      border: isUser ? null : Border.all(color: const Color(0xFF222B48)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35)),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(msg['time'] as String, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Message input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0C1024),
            border: Border(top: BorderSide(color: Color(0xFF1E2544))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF94A3B8)),
              ),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Xabar yozing...',
                    hintStyle: TextStyle(color: Color(0xFF64748B)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: Color(0xFF8B5CF6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 8. MUROJAAT SHAKLI (Official Petition Submission)
  // =========================================================================
  Widget _buildScreen8PetitionForm() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 5),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text('Murojaat shakli', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const Text('Mavzu *', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13182E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTopic,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              const Text('Murojaat matni *', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                height: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13182E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: TextField(
                  controller: _petitionTextController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 18),

              const Text('Fayl (ixtiyoriy)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (_attachedFileName != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13182E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF222B48)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_attachedFileName!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            const Text('1.2 MB', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _attachedFileName = null),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 18),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),

              // Button: Yuborish
              ElevatedButton.icon(
                onPressed: _submitPetition,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                label: const Text('Yuborish', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 9. MENING MUROJAATLARIM (Petitions History)
  // =========================================================================
  Widget _buildScreen9MyPetitions() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 5),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Expanded(
                child: Text('Mening murojaatlarim', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        // Tabs: Barchasi | Jarayonda | Yakunlangan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  key: const Key('tab_barchasi'),
                  onTap: () => setState(() => _petitionFilterIndex = 0),
                  borderRadius: BorderRadius.circular(14),
                  child: _segmentedTab('Barchasi', _petitionFilterIndex == 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  key: const Key('tab_jarayonda'),
                  onTap: () => setState(() => _petitionFilterIndex = 1),
                  borderRadius: BorderRadius.circular(14),
                  child: _segmentedTab('Jarayonda', _petitionFilterIndex == 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  key: const Key('tab_yakunlangan'),
                  onTap: () => setState(() => _petitionFilterIndex = 2),
                  borderRadius: BorderRadius.circular(14),
                  child: _segmentedTab('Yakunlangan', _petitionFilterIndex == 2),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _petitions
                .where((p) {
                  if (_petitionFilterIndex == 1) return p['isDone'] == false;
                  if (_petitionFilterIndex == 2) return p['isDone'] == true;
                  return true;
                })
                .map((p) {
              final isDone = p['isDone'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF13182E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDone ? const Color(0xFF14532D) : const Color(0xFF451A03),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p['status'] as String,
                                  style: TextStyle(
                                    color: isDone ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(p['date'] as String, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _detailInfoRow extends StatelessWidget {
  const _detailInfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1F38BDF8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Angled street network lines
    final path = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.45)
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.1)
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.85, size.height)
      ..moveTo(size.width * 0.6, 0)
      ..lineTo(size.width * 0.35, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoinStepPill extends StatelessWidget {
  const _CoinStepPill(this.emoji, this.title);
  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2548),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C3766)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ArrowDivider extends StatelessWidget {
  const _ArrowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF8B5CF6), size: 14),
    );
  }
}

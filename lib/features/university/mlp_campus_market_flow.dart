import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ============================================================================
// MLP CAMPUS MARKET / MUKOFOTLAR / HAMKORLAR MODULI
// 1:1 Implementation of the 5-screen Market ecosystem:
// 1. Mukofotlar do'koni (Store with Categories & Coin Balances)
// 2. Bonus tafsiloti (Item Detail, Partner branches, Kod olish / Kupon)
// 3. Hamkorlar xaritasi (Radar Map, Nearby partners with distances)
// 4. Filtr va kategoriyalar (Bottom sheet modal with category pills & sliders)
// 5. Mening coinlarim (Wallet balance, weekly stats, voucher counts & history)
// ============================================================================

class MarketBonusItem {
  const MarketBonusItem({
    required this.id,
    required this.title,
    required this.partner,
    required this.category,
    required this.distance,
    required this.coinPrice,
    required this.icon,
    required this.color,
    this.badge,
    this.description = 'Har qanday xarid va xizmat uchun qulay chegirma kuponi.',
    this.branches = const [
      'Universitet ko‘chasi, 12 (Bosh filial)',
      'Talabalar shaharchasi, 5',
    ],
    this.workingHours = '08:00 - 22:00',
    this.phone = '+998 90 123 45 67',
  });

  final String id;
  final String title;
  final String partner;
  final String category;
  final String distance;
  final int coinPrice;
  final IconData icon;
  final Color color;
  final String? badge;
  final String description;
  final List<String> branches;
  final String workingHours;
  final String phone;
}

class MLPCampusMarketFlow extends StatefulWidget {
  const MLPCampusMarketFlow({
    super.key,
    this.initialScreen = 0, // 0: Store, 1: Detail, 2: Map, 3: Wallet
    this.onBackToDashboard,
    this.initialCoins = 2450,
  });

  final int initialScreen;
  final VoidCallback? onBackToDashboard;
  final int initialCoins;

  @override
  State<MLPCampusMarketFlow> createState() => _MLPCampusMarketFlowState();
}

class _MLPCampusMarketFlowState extends State<MLPCampusMarketFlow> {
  late int _screen; // 0: Store, 1: Detail, 2: Map, 3: Wallet
  late int _coins;
  int _activeVouchers = 3;
  int _usedVouchers = 12;
  int _weeklyEarned = 750;

  int _selectedCategoryIndex = 0; // 0: Barchasi, 1: Kafe, 2: Kitob, 3: Kurs, 4: Chegirma
  final List<String> _categories = ['Barchasi', 'Kafe', 'Kitob', 'Kurs', 'Chegirma'];

  double _maxPriceSlider = 15000;
  String _selectedLocationFilter = 'Hamma joy';

  late List<MarketBonusItem> _items;
  MarketBonusItem? _activeItem;
  String? _generatedCouponCode;

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Vazifa: Darsga qatnashish',
      'time': 'Bugun, 10:24',
      'amount': '+250 coin',
      'isPositive': true,
      'icon': Icons.arrow_upward_rounded,
      'color': const Color(0xFF22C55E),
    },
    {
      'title': 'Vazifa: Testni yakunlash',
      'time': 'Kecha, 18:07',
      'amount': '+500 coin',
      'isPositive': true,
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF38BDF8),
    },
    {
      'title': 'Kupon: Dodo Cafe',
      'time': '10 Yan, 14:20',
      'amount': '-500 coin',
      'isPositive': false,
      'icon': Icons.coffee_rounded,
      'color': const Color(0xFFF97316),
    },
    {
      'title': 'Vazifa: Profilni to‘ldirish',
      'time': '9 Yan, 09:11',
      'amount': '+250 coin',
      'isPositive': true,
      'icon': Icons.person_rounded,
      'color': const Color(0xFFA855F7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _screen = widget.initialScreen;
    _coins = widget.initialCoins;

    _items = [
      const MarketBonusItem(
        id: 'cafe_1',
        title: 'Kafeda qahva kuponi',
        partner: 'Dodo Cafe (namuna)',
        category: 'Kafe',
        distance: '1.2 km',
        coinPrice: 500,
        icon: Icons.coffee_rounded,
        color: Color(0xFFF97316),
        description: 'Har qanday qahva ichimligiga 500 coin evaziga kupon.',
      ),
      const MarketBonusItem(
        id: 'book_1',
        title: 'Kitob xaridi uchun voucher',
        partner: 'Asaxiy (namuna)',
        category: 'Kitob',
        distance: '850 m',
        coinPrice: 1000,
        icon: Icons.auto_stories_rounded,
        color: Color(0xFF3B82F6),
        description: 'Barcha badiiy va darslik kitoblariga 1 000 coinlik maxsus voucher.',
      ),
      const MarketBonusItem(
        id: 'course_1',
        title: 'Kursga 20% chegirma',
        partner: 'Najot Ta‘lim (namuna)',
        category: 'Kurs',
        distance: '1.6 km',
        coinPrice: 1500,
        icon: Icons.school_rounded,
        color: Color(0xFF10B981),
        description: 'IT kurslari va amaliy laboratoriyalar uchun 20% ta’lim bonusi.',
      ),
      const MarketBonusItem(
        id: 'stationery_1',
        title: 'Kantselyariya to‘plami',
        partner: 'Local Book (namuna)',
        category: 'Chegirma',
        distance: '2.1 km',
        coinPrice: 700,
        icon: Icons.edit_note_rounded,
        color: Color(0xFF8B5CF6),
        description: 'Talabalar uchun zarur daftarlar va ruchkalar jamlanmasi.',
      ),
    ];
    _activeItem = _items.first;
  }

  void _claimCoupon(MarketBonusItem item) {
    if (_coins < item.coinPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yetarli coin mavjud emas!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _coins -= item.coinPrice;
      _activeVouchers++;
      _generatedCouponCode = 'MLP-${item.category.toUpperCase()}-${1000 + math.Random().nextInt(9000)}';
      _transactions.insert(0, {
        'title': 'Kupon: ${item.partner}',
        'time': 'Hozir',
        'amount': '-${item.coinPrice} coin',
        'isPositive': false,
        'icon': item.icon,
        'color': item.color,
      });
    });

    _showCouponDialog(item, _generatedCouponCode!);
  }

  void _showCouponDialog(MarketBonusItem item, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13182E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 26),
              SizedBox(width: 10),
              Text('Kupon olindi!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              item.partner,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2442),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 70),
                  const SizedBox(height: 10),
                  Text(
                    code,
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Yopish', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF10152B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filtr va kategoriyalar',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                const Text('Kategoriya', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_categories.length, (i) {
                    final isSel = _selectedCategoryIndex == i;
                    return InkWell(
                      onTap: () {
                        setSheetState(() => _selectedCategoryIndex = i);
                        setState(() => _selectedCategoryIndex = i);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF2563EB) : const Color(0xFF1E2544),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? const Color(0xFF38BDF8) : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFFCBD5E1),
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Coin narxi (oralig‘i)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('0 - ${_maxPriceSlider.toInt()}', style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Slider(
                  value: _maxPriceSlider,
                  min: 500,
                  max: 15000,
                  divisions: 29,
                  activeColor: const Color(0xFF2563EB),
                  inactiveColor: const Color(0xFF1E2544),
                  onChanged: (val) {
                    setSheetState(() => _maxPriceSlider = val);
                    setState(() => _maxPriceSlider = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Joylashuv masofasi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2544),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 18),
                          const SizedBox(width: 8),
                          Text(_selectedLocationFilter, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Filtrlash', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D1E),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_screen) {
            0 => _buildScreen1Store(),
            1 => _buildScreen2Detail(),
            2 => _buildScreen3Map(),
            _ => _buildScreen5Wallet(),
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // =========================================================================
  // 1. MUKOFOTLAR DO'KONI
  // =========================================================================
  Widget _buildScreen1Store() {
    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBackToDashboard,
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Mukofotlar do‘koni',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _screen = 2), // open map
                icon: const Icon(Icons.map_outlined, color: Color(0xFF38BDF8), size: 22),
              ),
              IconButton(
                onPressed: _openFilterBottomSheet,
                icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 22),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 2 450 coin Banner
              GestureDetector(
                onTap: () => setState(() => _screen = 3), // open wallet
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E183E), Color(0xFF12142E)],
                    ),
                    border: Border.all(color: const Color(0xFF3B2D6E)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x338B5CF6),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🪙', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_coins coin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                            const Text(
                              'Joriy balans • Tarixni ko‘rish →',
                              style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Text('💰', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (i) {
                    final isSel = _selectedCategoryIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategoryIndex = i),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF2563EB) : const Color(0xFF13182E),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFF38BDF8) : const Color(0xFF222B48),
                            ),
                          ),
                          child: Text(
                            _categories[i],
                            style: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              ..._items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13182E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF222B48)),
                  ),
                  child: Row(
                    children: [
                      // Item graphic
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: item.color, size: 26),
                      ),
                      const SizedBox(width: 12),

                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.partner} • ${item.distance}',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.coinPrice} coin',
                                  style: const TextStyle(
                                    color: Color(0xFFFFB800),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // "Olish" button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activeItem = item;
                            _screen = 1; // open detail
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Olish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. BONUS TAFSILOTI
  // =========================================================================
  Widget _buildScreen2Detail() {
    final item = _activeItem ?? _items.first;
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
                child: Text('Bonus tafsiloti', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
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
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C1E1B), Color(0xFF181528)],
                  ),
                  border: Border.all(color: const Color(0xFF4C3030)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(item.icon, color: item.color.withValues(alpha: 0.8), size: 75),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(item.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title and Price
              Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(item.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text('${item.coinPrice} coin', style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 18),

              // Partner card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF13182E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.partner, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          const Text('Talabalar uchun qulay kafe', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right, color: Color(0xFF64748B), size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Branches & Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF13182E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222B48)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filiallar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...item.branches.map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $b', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Ish vaqti: ${item.workingHours}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Telefon: ${item.phone}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2 Map Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _screen = 2),
                      icon: const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                      label: const Text('Xaritada ko‘rish', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF222B48)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _screen = 2),
                      icon: const Icon(Icons.navigation_outlined, color: Color(0xFF38BDF8), size: 16),
                      label: const Text('Yo‘nalish olish', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF222B48)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Big Button: Kod olish (kupon)
              InkWell(
                onTap: () => _claimCoupon(item),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3310B981),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Kod olish (kupon)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. HAMKORLAR XARITASI (Radar Map & Nearby Partners)
  // =========================================================================
  Widget _buildScreen3Map() {
    return Column(
      children: [
        // Top search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 0),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13182E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF222B48)),
                  ),
                  child: Row(
                    children: const [
                      Icon(CupertinoIcons.search, color: Color(0xFF64748B), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hamkor yoki manzilni qidirish...',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _openFilterBottomSheet,
                icon: const Icon(Icons.tune_rounded, color: Colors.white70, size: 22),
              ),
            ],
          ),
        ),

        // Radar Map Canvas
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF0F1428),
              border: Border.all(color: const Color(0xFF222B48)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MarketRadarMapPainter(),
                    ),
                  ),

                  // Map pin tags
                  _mapPin('Asaxiy', 0.35, 0.28, const Color(0xFF3B82F6)),
                  _mapPin('Najot Ta‘lim', 0.65, 0.32, const Color(0xFF10B981)),
                  _mapPin('Dodo Pizza', 0.25, 0.65, const Color(0xFFF97316)),
                  _mapPin('Local Book', 0.70, 0.68, const Color(0xFF8B5CF6)),

                  // Radar center pulse
                  Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Nearby Partners bottom sheet card
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            decoration: const BoxDecoration(
              color: Color(0xFF13182E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yaqin atrofdagi hamkorlar',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: _items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon, color: item.color, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.partner, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                ],
                              ),
                            ),
                            Text(item.distance, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w700, fontSize: 12)),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _activeItem = item;
                                  _screen = 1;
                                });
                              },
                              icon: const Icon(Icons.navigation_rounded, color: Color(0xFF38BDF8), size: 18),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapPin(String name, double relX, double relY, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: constraints.maxWidth * relX - 30,
          top: constraints.maxHeight * relY - 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2544),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: color, size: 12),
                const SizedBox(width: 4),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // 5. MENING COINLARIM (Wallet, Weekly Progress & Transactions)
  // =========================================================================
  Widget _buildScreen5Wallet() {
    return Column(
      children: [
        // Top header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _screen = 0),
                icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 24),
              ),
              const Text('Mening coinlarim', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22164A), Color(0xFF131535)],
                  ),
                  border: Border.all(color: const Color(0xFF4C2F8A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_coins coin', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        const Text('Joriy balans', style: TextStyle(color: Color(0xFF9AA3C2), fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFA855F7), size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3 Stats tiles (+750 weekly, 3 active vouchers, 12 used)
              Row(
                children: [
                  _walletStatTile('+750', 'Bu haftada\nyig‘ilgan', Icons.trending_up_rounded, const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _walletStatTile('$_activeVouchers', 'Faol\nvoucher', Icons.confirmation_number_outlined, const Color(0xFF38BDF8)),
                  const SizedBox(width: 8),
                  _walletStatTile('$_usedVouchers', 'Ishlatilgan\nvoucher', Icons.check_circle_outline_rounded, const Color(0xFFA855F7)),
                ],
              ),
              const SizedBox(height: 20),

              // Tabs: Tarix / Voucherlar
              Row(
                children: const [
                  Text('Tarix', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(width: 24),
                  Text('Voucherlar', style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),

              // Transactions List
              ..._transactions.map((tx) {
                final isPos = tx['isPositive'] as bool;
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (tx['color'] as Color).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(tx['icon'] as IconData, color: tx['color'] as Color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(tx['time'] as String, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        tx['amount'] as String,
                        style: TextStyle(
                          color: isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _walletStatTile(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF13182E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF222B48)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, height: 1.2)),
          ],
        ),
      ),
    );
  }

  // Floating bottom navigation
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0C1024),
        border: Border(top: BorderSide(color: Color(0xFF1E2544))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Asosiy', false, onTap: widget.onBackToDashboard),
          _navItem(Icons.assignment_turned_in_rounded, 'Vazifalar', false),
          _navItem(Icons.storefront_rounded, 'Market', true),
          _navItem(Icons.account_balance_wallet_rounded, 'Hamyon', _screen == 3, onTap: () => setState(() => _screen = 3)),
          _navItem(Icons.person_rounded, 'Profil', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF8B5CF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? Colors.white : const Color(0xFF64748B), size: 20),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Radar Custom Painter for dark map aesthetic
class _MarketRadarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.45;

    final circlePaint = Paint()
      ..color = const Color(0xFF1E294B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxR * (i / 3), circlePaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF1E294B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MLPCampusEntry extends StatefulWidget {
  const MLPCampusEntry({
    super.key,
    required this.prefs,
    required this.onComplete,
  });

  static const universityKey = 'mlp_campus_university_v1';
  final SharedPreferences prefs;
  final VoidCallback onComplete;

  @override
  State<MLPCampusEntry> createState() => _MLPCampusEntryState();
}

class _MLPCampusEntryState extends State<MLPCampusEntry> {
  int step = 0;
  int slide = 0;
  String selected = 'FarDU';
  String query = '';
  bool saving = false;
  String? error;

  final custom = TextEditingController();
  final search = TextEditingController();

  static const universities = [
    'FarDU',
    'Andijon davlat univ.',
    'Namangan univ.',
    'TATU',
    'Boshqasi...',
  ];

  static const headings = [
    'O‘qishdan\nko‘proq natija\noling',
    'Har kuni\naniq reja bilan\no‘rganing',
    'Bilimingizni\nsinov orqali\ntekshiring',
    'Natijalaringizni\nbir joyda\nkuzating',
  ];

  static const descriptions = [
    'Fanlar, testlar va shaxsiy rivojlanish orqali bilim va ko‘nikmalaringizni oshiring.',
    'Maqsadingizni tanlang va bugungi topshiriqni bajaring.',
    'Qisqa savollar bilan nimalarni o‘rganganingizni bilib oling.',
    'Bajargan ishlaringiz va sinov natijalaringiz saqlanadi.',
  ];

  @override
  void dispose() {
    custom.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (step < 2) {
      setState(() => step++);
      return;
    }

    final value = selected == 'Boshqasi...' ? custom.text.trim() : selected;
    if (value.length < 2) {
      setState(() => error = 'Universitet nomini kiriting.');
      return;
    }

    error = null;
    try {
      final ok =
          await widget.prefs.setString(MLPCampusEntry.universityKey, value);
      if (!ok) throw StateError('save');
      if (mounted) widget.onComplete();
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Tanlov saqlanmadi. Qayta urinib ko‘ring.';
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !saving) {
          setState(() => step--);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050816),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _CampusBackdrop()),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top bar (Back button)
                                SizedBox(
                                  height: 44,
                                  child: step > 0
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                            tooltip: 'Orqaga',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: saving
                                                ? null
                                                : () => setState(() => step--),
                                            icon: const Icon(
                                              CupertinoIcons.chevron_back,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),

                                // Central content by step
                                if (step == 0)
                                  _buildStep0()
                                else if (step == 1)
                                  _buildStep1()
                                else
                                  _buildStep2(),

                                // Bottom button & error
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (error != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Text(
                                          error!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFFFF85A1),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    _CampusButton(
                                      label: step == 0
                                          ? 'Boshlash'
                                          : 'Davom etish',
                                      arrow: step == 0,
                                      busy: saving,
                                      onTap: next,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: const [
          SizedBox(height: 10),
          Center(child: _CampusLogo()),
          SizedBox(height: 32),
          Text(
            'MLP\nCampus',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Universitet talabalari uchun\no‘rganish va rivojlanish\nplatformasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9AA3C2),
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Center(
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(260, 210),
              painter: _StudyArt(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          headings[slide],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.18,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          descriptions[slide],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Color(0xFF9AA3C2),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (i) => GestureDetector(
              onTap: () => setState(() => slide = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == slide ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: i == slide
                      ? const Color(0xFFA855F7)
                      : const Color(0xFF282D4B),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final filtered = universities
        .where((u) => u.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Universitetni tanlang',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 18),
        _CampusGlass(
          borderRadius: 16,
          child: TextField(
            controller: search,
            onChanged: (v) => setState(() => query = v),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Qidirish...',
              hintStyle: TextStyle(color: Color(0xFF7482A0), fontSize: 16),
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: Color(0xFF7482A0),
                size: 20,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (final name in filtered)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _UniversityCard(
              name: name,
              isSelected: selected == name,
              onTap: saving
                  ? null
                  : () => setState(() {
                        selected = name;
                        error = null;
                      }),
            ),
          ),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: TextButton(
                onPressed: () => setState(() {
                  selected = 'Boshqasi...';
                  query = '';
                  search.clear();
                }),
                child: const Text(
                  'Topilmadi. Universitet nomini kiritish',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        if (selected == 'Boshqasi...')
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: _CampusGlass(
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: custom,
                  maxLength: 100,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Universitet nomi',
                    labelStyle: TextStyle(color: Color(0xFF9AA3C2)),
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFA855F7) : const Color(0xFF1E2642),
          width: isSelected ? 1.6 : 1.0,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? const [Color(0xFF231346), Color(0xFF160E32)]
              : const [Color(0xFF0D1426), Color(0xFF0A0F1D)],
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? const [Color(0xFF3B82F6), Color(0xFF6366F1)]
                          : const [Color(0xFF0F3A4F), Color(0xFF0B2236)],
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: isSelected ? Colors.white : const Color(0xFF38BDF8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? CupertinoIcons.check_mark
                      : CupertinoIcons.chevron_right,
                  color:
                      isSelected ? Colors.white : const Color(0xFF64748B),
                  size: isSelected ? 20 : 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampusGlass extends StatelessWidget {
  const _CampusGlass({
    required this.child,
    this.borderRadius = 18,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: const Color(0xFF1E2642),
                width: 1.0,
              ),
              color: const Color(0xFF0D1426).withValues(alpha: 0.75),
            ),
            child: child,
          ),
        ),
      );
}

class _CampusButton extends StatelessWidget {
  const _CampusButton({
    required this.label,
    required this.onTap,
    this.arrow = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool arrow, busy;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFC084FC).withValues(alpha: 0.5),
            width: 1.0,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9333EA), Color(0xFF7928CA), Color(0xFF581C87)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x667928CA),
              blurRadius: 22,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: busy ? null : onTap,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (arrow) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.arrow_right,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}

class _CampusLogo extends StatelessWidget {
  const _CampusLogo();

  @override
  Widget build(BuildContext context) => Container(
        width: 140,
        height: 140,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00E5FF), Color(0xFF7C3AED), Color(0xFFE040FB)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5500E5FF),
              blurRadius: 28,
              offset: Offset(-6, -6),
            ),
            BoxShadow(
              color: Color(0x669333EA),
              blurRadius: 28,
              offset: Offset(6, 6),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: const RadialGradient(
              center: Alignment(0.4, -0.4),
              radius: 1.1,
              colors: [Color(0xFF221142), Color(0xFF06091E)],
            ),
          ),
          child: CustomPaint(painter: _MMark()),
        ),
      );
}

class _MMark extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    // Elegant neon cyan 'M'
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

    // Glow aura
    c.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Sharp foreground stroke
    c.drawPath(
      p,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF22D3EE), Color(0xFF00E5FF)],
        ).createShader(Offset.zero & s)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_MMark old) => false;
}

class _CampusBackdrop extends CustomPainter {
  const _CampusBackdrop();

  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF050816));

    // Top-left cyan nebula
    c.drawCircle(
      Offset(-s.width * 0.05, s.height * 0.15),
      s.width * 0.65,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.35),
            const Color(0xFF00E5FF).withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(-s.width * 0.05, s.height * 0.15),
            radius: s.width * 0.65,
          ),
        ),
    );

    // Bottom-right cyan streak
    c.drawCircle(
      Offset(s.width * 1.05, s.height * 0.90),
      s.width * 0.60,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00D2FF).withValues(alpha: 0.28),
            const Color(0xFF00D2FF).withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(s.width * 1.05, s.height * 0.90),
            radius: s.width * 0.60,
          ),
        ),
    );

    // Bottom-left purple nebula
    c.drawCircle(
      Offset(-s.width * 0.10, s.height * 0.78),
      s.width * 0.60,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.35),
            const Color(0xFF8B5CF6).withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(-s.width * 0.10, s.height * 0.78),
            radius: s.width * 0.60,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(_CampusBackdrop old) => false;
}

class _StudyArt extends CustomPainter {
  const _StudyArt();

  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 260, s.height / 210);

    // Purple pool glow under books
    c.drawOval(
      const Rect.fromLTWH(30, 165, 200, 36),
      Paint()
        ..color = const Color(0xBB8B5CF6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Glowing orbital rings
    c.drawOval(
      const Rect.fromLTWH(10, 70, 240, 80),
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    c.drawOval(
      const Rect.fromLTWH(18, 60, 224, 76),
      Paint()
        ..color = const Color(0xFFC084FC).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    void shape(List<Offset> points, List<Color> colors) {
      final p = Path()..addPolygon(points, true);
      c.drawPath(
        p,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ).createShader(p.getBounds()),
      );
      c.drawPath(
        p,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Stacked books
    for (var i = 0; i < 2; i++) {
      final y = 150.0 - i * 36.0;
      shape(
        [
          Offset(35, y),
          Offset(165, y - 30),
          Offset(235, y - 6),
          Offset(230, y + 22),
          Offset(100, y + 48),
          Offset(32, y + 22),
        ],
        [
          i == 0 ? const Color(0xFF4F46E5) : const Color(0xFFF97316),
          i == 0 ? const Color(0xFF312E81) : const Color(0xFFC2410C),
        ],
      );
      shape(
        [
          Offset(42, y + 4),
          Offset(102, y + 27),
          Offset(228, y + 2),
          Offset(226, y + 17),
          Offset(102, y + 42),
          Offset(42, y + 20),
        ],
        [const Color(0xFFFFFFFF), const Color(0xFFCBD5E1)],
      );
      shape(
        [
          Offset(32, y),
          Offset(165, y - 30),
          Offset(235, y - 7),
          Offset(102, y + 22),
        ],
        [
          i == 0 ? const Color(0xFF6366F1) : const Color(0xFF06B6D4),
          i == 0 ? const Color(0xFF4338CA) : const Color(0xFF0891B2),
        ],
      );
    }

    // Graduation mortarboard cap base
    final body = Path()
      ..moveTo(94, 58)
      ..lineTo(94, 98)
      ..quadraticBezierTo(138, 128, 180, 96)
      ..lineTo(180, 58)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF6366F1), Color(0xFF1E1B4B)],
        ).createShader(const Rect.fromLTWH(94, 58, 86, 60)),
    );

    // Graduation mortarboard diamond top
    shape(
      const [
        Offset(40, 52),
        Offset(137, 18),
        Offset(234, 51),
        Offset(137, 85),
      ],
      [
        const Color(0xFF818CF8),
        const Color(0xFF4F46E5),
        const Color(0xFF312E81),
      ],
    );

    // Gold tassel hanging on left side
    c.drawPath(
      Path()
        ..moveTo(137, 52)
        ..lineTo(86, 68)
        ..quadraticBezierTo(78, 72, 78, 96),
      Paint()
        ..color = const Color(0xFFFBBF24)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    c.drawOval(
      const Rect.fromLTWH(72, 92, 12, 18),
      Paint()..color = const Color(0xFFF59E0B),
    );

    c.restore();
  }

  @override
  bool shouldRepaint(_StudyArt old) => false;
}

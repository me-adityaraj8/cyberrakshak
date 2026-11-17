import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../app/tr.dart';
import '../content/call_scenarios.dart';
import '../content/lessons.dart';
import '../detection/detector.dart';
import '../ui/postal.dart';
import '../ui/widgets.dart';
import 'call_sim.dart';
import 'lesson.dart';
import 'verdict.dart';

const _examples = [
  Tr(
    'Dear customer, your SBI KYC has expired. Update now at bit.ly/sbi-kyc9 or your account will be blocked today.',
    'प्रिय ग्राहक, आपका SBI KYC समाप्त हो गया है। तुरंत bit.ly/sbi-kyc9 पर अपडेट करें वरना आज ही खाता बंद हो जाएगा।',
  ),
  Tr(
    '482913 is your OTP for a payment of Rs 1,250 at Amazon. Do not share it with anyone. -HDFC Bank',
    '482913 आपके ₹1,250 के Amazon भुगतान का OTP है। इसे किसी के साथ साझा न करें। -HDFC बैंक',
  ),
  Tr(
    'This is CBI Cyber Cell. A parcel with drugs in your name was seized. You are under digital arrest, do not disconnect the video call.',
    'यह CBI साइबर सेल है। आपके नाम का ड्रग्स वाला पार्सल पकड़ा गया है। आप डिजिटल अरेस्ट में हैं, वीडियो कॉल न काटें।',
  ),
  Tr(
    'Sir galti se aapke number par OTP chala gaya, please bata do urgent hai',
    'सर गलती से आपके नंबर पर OTP चला गया है, कृपया बता दीजिए, बहुत ज़रूरी है।',
  ),
];

const _days = [
  Tr('Monday', 'सोमवार'),
  Tr('Tuesday', 'मंगलवार'),
  Tr('Wednesday', 'बुधवार'),
  Tr('Thursday', 'गुरुवार'),
  Tr('Friday', 'शुक्रवार'),
  Tr('Saturday', 'शनिवार'),
  Tr('Sunday', 'रविवार'),
];
const _months = [
  Tr('January', 'जनवरी'),
  Tr('February', 'फ़रवरी'),
  Tr('March', 'मार्च'),
  Tr('April', 'अप्रैल'),
  Tr('May', 'मई'),
  Tr('June', 'जून'),
  Tr('July', 'जुलाई'),
  Tr('August', 'अगस्त'),
  Tr('September', 'सितंबर'),
  Tr('October', 'अक्टूबर'),
  Tr('November', 'नवंबर'),
  Tr('December', 'दिसंबर'),
];

const _onInk = Color(0xFFB9BDD6);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  int _example = 0;
  bool _reading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scan.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text? when text.trim().isNotEmpty) {
      _ctrl.text = text.trim();
    }
  }

  Future<void> _check() async {
    final input = _ctrl.text.trim();
    if (input.isEmpty || _reading) return;
    _focus.unfocus();
    // A short "reading" pass over the message: the check itself is instant,
    // but a beat of visible work makes the verdict feel considered.
    if (!MediaQuery.of(context).disableAnimations) {
      setState(() => _reading = true);
      await _scan.forward(from: 0);
      if (!mounted) return;
      setState(() => _reading = false);
    }
    if (!mounted) return;
    openCheck(context, input);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lesson = lessons.firstWhere(
      (l) => !app.completedLessons.contains(l.id),
      orElse: () => lessons.first,
    );
    final headline = app.name.isEmpty
        ? app.t(S.safeToday)
        : fill(app.t(S.safeTodayNamed), {'name': app.name});
    final now = DateTime.now();
    final date =
        '${app.t(_days[now.weekday - 1])}, ${now.day} ${app.t(_months[now.month - 1])}';
    final top = MediaQuery.paddingOf(context).top;

    return ListView(
      padding: const EdgeInsets.only(bottom: 72),
      children: [
        // ------------------------------------------------ ink header
        InkBackdrop(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Space.page,
              top + Space.l,
              Space.page,
              78,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [_Mark(), Spacer(), LangToggle(onDark: true)],
                ),
                const SizedBox(height: 34),
                FadeUp(
                  order: 0,
                  child: Text(
                    '${app.t(S.greeting)}  ·  $date',
                    style: T.small.copyWith(color: _onInk, letterSpacing: 0.2),
                  ),
                ),
                const SizedBox(height: 6),
                FadeUp(
                  order: 1,
                  child: Text(
                    headline,
                    style: T.display.copyWith(color: C.paper, fontSize: 29),
                  ),
                ),
                const SizedBox(height: Space.m),
                FadeUp(
                  order: 2,
                  child: Row(
                    children: [
                      const _LiveDot(),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          app.t(S.onDevice),
                          style: T.small.copyWith(color: _onInk),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // everything below rides up over the header
        Transform.translate(
          offset: const Offset(0, -54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeUp(order: 3, child: _checker(app)),
                const SizedBox(height: Space.l),
                FadeUp(
                  order: 4,
                  child: _Ticket(
                    checked: app.checkedCount,
                    caught: app.caughtCount,
                  ),
                ),
                const SizedBox(height: Space.l),

                // ------------------------------------------ practice call
                FadeUp(
                  order: 5,
                  child: PaperCard(
                    padding: const EdgeInsets.fromLTRB(
                      Space.l,
                      Space.l,
                      Space.l,
                      Space.l,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CallSimScreen(scenario: nextCall(app.passedCalls)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const _RingingIcon(),
                        const SizedBox(width: Space.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.t(S.practiceCardTitle),
                                style: T.heading,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app.passedCalls.isEmpty
                                    ? app.t(S.practiceCardBody)
                                    : fill(app.t(S.practiceCardNext), {
                                        'name': app.t(
                                          nextCall(app.passedCalls).title,
                                        ),
                                      }),
                                style: T.small,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Space.s),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: C.inkFaint,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Space.m),

                // ------------------------------------------ lesson stamp
                FadeUp(
                  order: 6,
                  child: PaperCard(
                    color: C.marigoldTint,
                    borderColor: const Color(0x33C98A1E),
                    padding: const EdgeInsets.fromLTRB(
                      Space.l,
                      Space.l,
                      Space.m,
                      Space.l,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(lesson: lesson),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionLabel(
                                app.t(S.thisWeek),
                                color: const Color(0xFF8A5A0E),
                              ),
                              const SizedBox(height: 6),
                              Text(app.t(lesson.title), style: T.title),
                              const SizedBox(height: 4),
                              Text(
                                app.t(lesson.hook),
                                style: T.small.copyWith(
                                  color: const Color(0xFF5E4A26),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${fill(app.t(S.minutes), {'n': lesson.minutes})}  →',
                                style: T.small.copyWith(
                                  color: const Color(0xFF8A5A0E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Space.m),
                        Transform.rotate(
                          angle: 0.07,
                          child: SizedBox(
                            width: 66,
                            height: 82,
                            child: Stamp(
                              padding: const EdgeInsets.all(7),
                              child: Container(
                                color: C.ink,
                                alignment: Alignment.center,
                                child: Text(
                                  (lessons.indexOf(lesson) + 1)
                                      .toString()
                                      .padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontFamily: F.serif,
                                    fontSize: 24,
                                    color: C.marigoldTint,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ------------------------------------------ history
                if (app.history.isNotEmpty) ...[
                  const SizedBox(height: Space.xxl),
                  SectionLabel(app.t(S.recent)),
                  const SizedBox(height: Space.s),
                  for (final h in app.history.take(4)) _HistoryRow(entry: h),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The checker, dressed as a letter: airmail edging on top, the message
  /// inside, and a scan line that reads it before the verdict.
  Widget _checker(AppState app) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x241B2350),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x141B2350),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AirmailStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.l,
              Space.l,
              Space.l,
              Space.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.t(S.checkTitle),
                  style: T.title.copyWith(fontSize: 19),
                ),
                const SizedBox(height: Space.m),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: C.paper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _focus.hasFocus || _reading ? C.ink : C.hairline,
                    ),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        readOnly: _reading,
                        minLines: 3,
                        maxLines: 6,
                        style: T.body.copyWith(fontSize: 14.5),
                        decoration: InputDecoration(
                          hintText: app.t(S.checkHint),
                          hintStyle: T.body.copyWith(
                            color: C.inkFaint,
                            fontSize: 14.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(
                            14,
                            12,
                            14,
                            12,
                          ),
                        ),
                        onTapOutside: (_) => _focus.unfocus(),
                      ),
                      if (_reading)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _scan,
                              builder: (context, _) => CustomPaint(
                                painter: _ScanPainter(_scan.value),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.s),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.content_paste_rounded,
                      label: app.t(S.paste),
                      onTap: _paste,
                    ),
                    const SizedBox(width: Space.s),
                    _Chip(
                      icon: Icons.auto_awesome_outlined,
                      label: app.t(S.tryExample),
                      onTap: () {
                        _ctrl.text = _examples[_example % _examples.length].of(
                          app.lang,
                        );
                        _example++;
                      },
                    ),
                    const Spacer(),
                    if (_ctrl.text.isNotEmpty)
                      IconButton(
                        onPressed: _ctrl.clear,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: C.inkFaint,
                        ),
                        tooltip: 'Clear',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Space.m),
                AppButton(
                  label: app.t(_reading ? S.reading : S.checkBtn),
                  icon: _reading ? null : Icons.search_rounded,
                  onPressed: _ctrl.text.trim().isEmpty ? null : _check,
                ),
                const SizedBox(height: Space.m),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.ios_share_rounded,
                        size: 15,
                        color: C.inkFaint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        app.t(S.shareTip),
                        style: T.small.copyWith(color: C.inkFaint),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A marigold line that sweeps down and back up over the message.
class _ScanPainter extends CustomPainter {
  _ScanPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final p = t < 0.5
        ? Curves.easeInOut.transform(t * 2)
        : 1 - Curves.easeInOut.transform((t - 0.5) * 2);
    final y = p * size.height;
    final down = t < 0.5;
    final trail = Rect.fromLTRB(
      0,
      down ? y - 46 : y,
      size.width,
      down ? y : y + 46,
    );
    canvas.drawRect(
      trail,
      Paint()
        ..shader = LinearGradient(
          begin: down ? Alignment.bottomCenter : Alignment.topCenter,
          end: down ? Alignment.topCenter : Alignment.bottomCenter,
          colors: [
            C.marigold.withValues(alpha: 0.28),
            C.marigold.withValues(alpha: 0),
          ],
        ).createShader(trail),
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = C.marigold
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.t != t;
}

/// A green dot that breathes: protection is on.
class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF6FCF9B);
    final still = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = still ? 0.0 : _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 7 + t * 7,
                height: 7 + t * 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: green.withValues(alpha: (1 - t) * 0.45),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The two counters as a ticket stub: notched sides, a dashed tear line.
class _Ticket extends StatelessWidget {
  const _Ticket({required this.checked, required this.caught});
  final int checked;
  final int caught;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    Widget cell(int value, String label, Color color) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.l,
          vertical: Space.m + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Text(
                '${v.round()}',
                style: T.number.copyWith(color: color, fontSize: 28),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(label, style: T.small.copyWith(height: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: C.sunk,
          borderRadius: BorderRadius.circular(14),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              cell(checked, app.t(S.checked), C.ink),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DashedLine(axis: Axis.vertical),
              ),
              cell(caught, app.t(S.caught), caught > 0 ? C.sindoor : C.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & size),
    Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width / 2, 0), radius: 8))
      ..addOval(
        Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: 8),
      ),
  );

  @override
  bool shouldReclip(_TicketClipper old) => false;
}

class _Mark extends StatelessWidget {
  const _Mark();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: C.marigold,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: const Text(
            'र',
            style: TextStyle(
              fontFamily: F.serif,
              fontSize: 18,
              color: C.ink,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'CyberRakshak',
          style: TextStyle(
            fontFamily: F.sans,
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            color: C.paper,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: C.hairlineStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: C.inkSoft),
              const SizedBox(width: 6),
              Text(
                label,
                style: T.small.copyWith(
                  color: C.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final seal = switch (entry.level) {
      RiskLevel.scam => S.scamSeal,
      RiskLevel.suspicious => S.suspiciousSeal,
      RiskLevel.safe => S.safeSeal,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: C.hairline)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: levelColor(entry.level),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: T.small.copyWith(color: C.ink),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            app.t(seal),
            style: T.small.copyWith(
              color: levelColor(entry.level),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A phone icon with a soft marigold pulse, hinting "this rings".
class _RingingIcon extends StatefulWidget {
  const _RingingIcon();
  @override
  State<_RingingIcon> createState() => _RingingIconState();
}

class _RingingIconState extends State<_RingingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: 52,
      height: 52,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = still ? 0.0 : _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40 + t * 12,
                height: 40 + t * 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.leaf.withValues(alpha: (1 - t) * 0.35),
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: C.leaf,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phone_in_talk_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

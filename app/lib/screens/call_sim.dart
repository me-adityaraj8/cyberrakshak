import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../app/tr.dart';
import '../content/call_scenarios.dart';
import '../ui/widgets.dart';

enum _Phase { ringing, talking, ended }

enum _Who { caller, you, coachGood, coachBad }

/// A practice scam call. The screen turns dark like a real call; the user
/// answers, reads what the caller says, and picks how to reply.
class CallSimScreen extends StatefulWidget {
  const CallSimScreen({super.key, required this.scenario});
  final CallScenario scenario;

  @override
  State<CallSimScreen> createState() => _CallSimScreenState();
}

class _CallSimScreenState extends State<CallSimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();
  final _scroll = ScrollController();
  final _log = <(_Who, Tr)>[];
  _Phase _phase = _Phase.ringing;
  int _step = 0;
  int _seconds = 0;
  bool _waiting = false;
  bool _won = false;
  bool _declined = false;
  Timer? _clock;

  CallScenario get sc => widget.scenario;

  @override
  void dispose() {
    _ring.dispose();
    _scroll.dispose();
    _clock?.cancel();
    super.dispose();
  }

  void _add(_Who who, Tr text) {
    setState(() => _log.add((who, text)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _answer() {
    _ring.stop();
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _seconds++),
    );
    setState(() => _phase = _Phase.talking);
    _add(_Who.caller, sc.steps.first.line);
  }

  void _decline() {
    _ring.stop();
    _end(won: true, declined: true);
  }

  Future<void> _pick(CallChoice c) async {
    if (_waiting) return;
    setState(() => _waiting = true);
    _add(_Who.you, c.text);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    _add(c.safe ? _Who.coachGood : _Who.coachBad, c.feedback);
    await Future<void>.delayed(Duration(milliseconds: c.safe ? 1500 : 1700));
    if (!mounted) return;
    if (c.safe) {
      _end(won: true);
    } else if (_step == sc.steps.length - 1) {
      _end(won: false);
    } else {
      _step++;
      _add(_Who.caller, sc.steps[_step].line);
      setState(() => _waiting = false);
    }
  }

  void _end({required bool won, bool declined = false}) {
    _clock?.cancel();
    if (won && !declined) context.read<AppState>().passCall(sc.id);
    setState(() {
      _won = won;
      _declined = declined;
      _phase = _Phase.ended;
      _waiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = _phase != _Phase.ended;
    return Scaffold(
      backgroundColor: dark ? C.ink : C.paper,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        child: KeyedSubtree(
          key: ValueKey(_phase),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: switch (_phase) {
                  _Phase.ringing => _ringing(),
                  _Phase.talking => _talking(),
                  _Phase.ended => _result(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ ringing
  Widget _ringing() {
    final app = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.page,
        Space.s,
        Space.page,
        Space.xxl,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: _onInkSoft),
            ),
          ),
          const Spacer(flex: 2),
          Text(
            app.t(S.practiceCallTag),
            style: T.label.copyWith(color: C.marigold),
          ),
          const SizedBox(height: Space.xl),
          SizedBox(
            width: 150,
            height: 150,
            child: AnimatedBuilder(
              animation: _ring,
              builder: (context, child) =>
                  CustomPaint(painter: _RingPainter(_ring.value), child: child),
              child: Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3363),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: _onInkSoft,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          Text(
            app.t(sc.caller),
            textAlign: TextAlign.center,
            style: T.title.copyWith(color: C.paper, fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            sc.number,
            style: T.small.copyWith(color: _onInkSoft, letterSpacing: 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            app.t(S.incomingCall),
            style: T.small.copyWith(color: _onInkSoft),
          ),
          const Spacer(flex: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundAction(
                icon: Icons.call_end_rounded,
                color: C.sindoor,
                label: app.t(S.decline),
                onTap: _decline,
              ),
              _RoundAction(
                icon: Icons.call_rounded,
                color: C.leaf,
                label: app.t(S.answer),
                onTap: _answer,
              ),
            ],
          ),
          const SizedBox(height: Space.l),
          Text(
            app.t(S.practiceNote),
            textAlign: TextAlign.center,
            style: T.small.copyWith(color: _onInkFaint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ talking
  Widget _talking() {
    final app = context.watch<AppState>();
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    final step = sc.steps[_step];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.page,
            Space.m,
            Space.s,
            Space.m,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A3363),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: _onInkSoft,
                ),
              ),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.t(sc.caller),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.heading.copyWith(color: C.paper, fontSize: 15),
                    ),
                    Text(
                      '$mm:$ss  ·  ${sc.number}',
                      style: T.small.copyWith(color: _onInkSoft, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: app.t(S.hangUp),
                onPressed: () => _end(won: true),
                style: IconButton.styleFrom(backgroundColor: C.sindoor),
                icon: const Icon(
                  Icons.call_end_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: const Color(0x1AFFFFFF)),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.l,
              Space.page,
              Space.l,
            ),
            children: [
              for (final (who, text) in _log)
                FadeUp(
                  child: _Line(who: who, text: app.t(text)),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            Space.page,
            Space.m,
            Space.page,
            Space.l,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF151C42),
            border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _waiting ? 0.35 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fill(app.t(S.yourReply), {
                    'n': _step + 1,
                    'total': sc.steps.length,
                  }),
                  style: T.label.copyWith(color: _onInkFaint),
                ),
                const SizedBox(height: Space.s),
                for (final c
                    in _step.isOdd ? step.choices.reversed : step.choices) ...[
                  _ReplyButton(
                    text: app.t(c.text),
                    onTap: _waiting ? null : () => _pick(c),
                  ),
                  const SizedBox(height: Space.s),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ result
  Widget _result() {
    final app = context.watch<AppState>();
    final color = _won ? C.leaf : C.sindoor;
    final seal = _won ? S.callSafeSeal : S.callLostSeal;
    final headline = _declined
        ? S.callDeclinedHead
        : (_won ? S.callWonHead : S.callLostHead);
    final sub = _declined
        ? app.t(S.callDeclinedSub)
        : _won
        ? fill(app.t(S.callWonSub), {'n': _step + 1, 'total': sc.steps.length})
        : app.t(sc.loss);
    final next = nextCall(app.passedCalls, after: sc.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.page,
        Space.s,
        Space.page,
        Space.xxl,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: C.ink),
            style: IconButton.styleFrom(
              backgroundColor: C.surface,
              side: const BorderSide(color: C.hairline),
            ),
          ),
        ),
        const SizedBox(height: Space.l),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: Space.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.t(headline),
                      style: T.display.copyWith(
                        color: _won ? C.ink : C.sindoor,
                      ),
                    ),
                    const SizedBox(height: Space.s),
                    Text(sub, style: T.bodySoft),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Space.m),
            Seal(
              label: app.t(seal),
              sub: app.lang == Lang.hi ? seal.en : seal.hi,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: Space.xl),
        SectionLabel(app.t(S.tricksInCall)),
        const SizedBox(height: Space.xs),
        for (final (i, s) in sc.steps.indexed)
          FadeUp(
            order: i + 1,
            child: NumberedRow(
              n: i + 1,
              text: app.t(s.trick),
              color: C.marigold,
            ),
          ),
        const SizedBox(height: Space.l),
        PaperCard(
          color: C.marigoldTint,
          borderColor: const Color(0x33C98A1E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(app.t(S.remember), color: const Color(0xFF8A5A0E)),
              const SizedBox(height: 6),
              Text(app.t(sc.remember), style: T.quote),
            ],
          ),
        ),
        const SizedBox(height: Space.xl),
        AppButton(
          label: app.t(S.tryAgain),
          icon: Icons.replay_rounded,
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => CallSimScreen(scenario: sc)),
          ),
        ),
        const SizedBox(height: Space.s),
        AppButton(
          label: fill(app.t(S.tryOtherCall), {'name': app.t(next.title)}),
          tone: ButtonTone.outline,
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => CallSimScreen(scenario: next)),
          ),
        ),
      ],
    );
  }
}

const _onInkSoft = Color(0xFFB9BDD6);
const _onInkFaint = Color(0xFF7F86AD);

class _Line extends StatelessWidget {
  const _Line({required this.who, required this.text});
  final _Who who;
  final String text;

  @override
  Widget build(BuildContext context) {
    switch (who) {
      case _Who.caller:
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.m, right: 36),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF263061),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: T.body.copyWith(color: C.paper, fontSize: 14.5),
            ),
          ),
        );
      case _Who.you:
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.m, left: 48),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
              decoration: const BoxDecoration(
                color: C.marigoldTint,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(text, style: T.body.copyWith(fontSize: 14.5)),
            ),
          ),
        );
      case _Who.coachGood:
      case _Who.coachBad:
        final good = who == _Who.coachGood;
        final accent = good ? const Color(0xFF7FC4A0) : const Color(0xFFE9A86A);
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  good
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 16,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: T.small.copyWith(color: accent, fontSize: 13.5),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ReplyButton extends StatelessWidget {
  const _ReplyButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x0FFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: T.body.copyWith(color: C.paper, fontSize: 14.5),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _onInkFaint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 66,
              height: 66,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: T.small.copyWith(color: _onInkSoft)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 2; i++) {
      final p = (t + i * 0.5) % 1;
      final r = 40 + p * 34;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = C.marigold.withValues(alpha: (1 - p) * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

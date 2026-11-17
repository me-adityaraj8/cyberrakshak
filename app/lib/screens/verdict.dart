import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/actions.dart';
import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../app/tr.dart';
import '../content/lessons.dart';
import '../detection/detector.dart';
import '../ui/postal.dart';
import '../ui/widgets.dart';
import 'family_sheet.dart';
import 'lesson.dart';

/// Which lesson explains a given red flag best.
const _lessonForSignal = {
  'digital_arrest': 'digital-arrest',
  'asks_secret': 'otp',
  'remote_app': 'electricity',
  'short_link': 'kyc',
  'lookalike_link': 'kyc',
  'identity_docs': 'kyc',
  'threat': 'kyc',
  'new_number_money': 'new-number',
  'prize': 'easy-money',
  'pay_to_receive': 'easy-money',
  'too_good': 'easy-money',
  'call_officer': 'electricity',
};

/// Checks [input] (a message or a phone number), records it, and opens the
/// verdict. Used by the home checker and by text shared from other apps.
void openCheck(BuildContext context, String input, {bool shared = false}) {
  final app = context.read<AppState>();
  final text = input.trim();
  if (text.isEmpty) return;
  final Widget screen;
  if (NumberCheck.looksLikeNumber(text)) {
    final v = app.numberCheck.check(text);
    app.recordCheck(text, v.level);
    screen = VerdictScreen.number(v, shared: shared);
  } else {
    final v = app.detector.check(text);
    app.recordCheck(text, v.level);
    screen = VerdictScreen.message(v, shared: shared);
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class VerdictScreen extends StatefulWidget {
  const VerdictScreen.message(
    Verdict this.verdict, {
    super.key,
    this.shared = false,
  }) : numberVerdict = null;
  const VerdictScreen.number(
    NumberVerdict this.numberVerdict, {
    super.key,
    this.shared = false,
  }) : verdict = null;

  /// Arrived from another app's share menu.
  final bool shared;
  final Verdict? verdict;
  final NumberVerdict? numberVerdict;

  @override
  State<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends State<VerdictScreen> {
  bool _reported = false;

  RiskLevel get level => widget.verdict?.level ?? widget.numberVerdict!.level;

  void _report() {
    final app = context.read<AppState>();
    final nv = widget.numberVerdict;
    if (nv != null) {
      final n = NumberCheck.normalise(nv.number);
      if (n != null) app.reportNumber(n);
    }
    ReportSink.submit(
      kind: nv != null ? 'number' : 'message',
      level: level.name,
      number: nv?.number,
    );
    setState(() => _reported = true);
    showToast(context, app.t(S.reported));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final v = widget.verdict;
    final nv = widget.numberVerdict;
    final color = levelColor(level);
    final (seal, headline, sub) = switch (level) {
      RiskLevel.scam => (S.scamSeal, S.scamHeadline, S.scamSub),
      RiskLevel.suspicious => (
        S.suspiciousSeal,
        S.suspiciousHeadline,
        S.suspiciousSub,
      ),
      RiskLevel.safe => (S.safeSeal, S.safeHeadline, S.safeSub),
    };
    final flags = v?.redFlags ?? const [];
    final good = v?.goodSigns ?? const [];
    final lessonId = flags
        .map((s) => _lessonForSignal[s.id])
        .whereType<String>()
        .firstOrNull;
    final lesson = lessonId == null
        ? null
        : lessons.firstWhere((l) => l.id == lessonId);

    return Scaffold(
      backgroundColor: C.paper,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopWash(color: levelTint(level)),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.page,
                    Space.s,
                    Space.page,
                    Space.xxl,
                  ),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: C.ink,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: C.surface,
                            side: const BorderSide(color: C.hairline),
                          ),
                        ),
                        if (widget.shared) ...[
                          const SizedBox(width: Space.s),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: C.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: C.hairline),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.ios_share_rounded,
                                  size: 14,
                                  color: C.inkSoft,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  app.t(S.sharedIn),
                                  style: T.small.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                                    color: level == RiskLevel.safe
                                        ? C.ink
                                        : color,
                                  ),
                                ),
                                const SizedBox(height: Space.s),
                                Text(app.t(sub), style: T.bodySoft),
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
                    if (v != null) ...[
                      const SizedBox(height: Space.xl),
                      _Likelihood(score: v.score, color: color),
                    ],
                    const SizedBox(height: Space.xl),
                    SectionLabel(
                      app.t(nv != null ? S.theNumber : S.theMessage),
                    ),
                    const SizedBox(height: Space.s),
                    if (v != null) ...[
                      MessageBubble(
                        text: v.text,
                        accent: color,
                        marks: [
                          for (final f in flags)
                            for (final (a, b) in f.spans) (a, b, color),
                          for (final g in good)
                            for (final (a, b) in g.spans) (a, b, C.leaf),
                        ],
                      ),
                      if (flags.any((f) => f.spans.isNotEmpty)) ...[
                        const SizedBox(height: Space.s),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 3,
                              color: color.withValues(alpha: 0.75),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                app.t(S.marksNote),
                                style: T.small.copyWith(
                                  color: C.inkFaint,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else
                      Text(
                        nv!.number,
                        style: T.title.copyWith(letterSpacing: 0.5),
                      ),
                    if (flags.isNotEmpty || nv != null) ...[
                      const SizedBox(height: Space.xl),
                      SectionLabel(app.t(S.whyTitle)),
                      const SizedBox(height: Space.xs),
                      if (nv != null)
                        NumberedRow(n: 1, text: app.t(nv.reason), color: color),
                      for (final (i, s) in flags.indexed)
                        FadeUp(
                          order: i + 2,
                          child: NumberedRow(
                            n: i + 1,
                            text: app.t(s.reason),
                            color: color,
                          ),
                        ),
                    ],
                    if (good.isNotEmpty) ...[
                      const SizedBox(height: Space.l),
                      SectionLabel(app.t(S.goodSignsTitle), color: C.leaf),
                      const SizedBox(height: Space.xs),
                      for (final (i, s) in good.indexed)
                        NumberedRow(
                          n: i + 1,
                          text: app.t(s.reason),
                          color: C.leaf,
                        ),
                    ],
                    const SizedBox(height: Space.xl),
                    if (level != RiskLevel.safe) ...[
                      SectionLabel(app.t(S.whatNow)),
                      const SizedBox(height: Space.m),
                      AppButton(
                        label: app.t(S.call1930),
                        tone: ButtonTone.danger,
                        icon: Icons.call_rounded,
                        onPressed: Act.call,
                      ),
                      const SizedBox(height: Space.s),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: app.t(S.tellFamily),
                              tone: ButtonTone.outline,
                              icon: Icons.people_outline_rounded,
                              onPressed: () => showFamilySheet(
                                context,
                                fill(app.t(S.familyMsg), {
                                  'msg': v?.text ?? nv!.number,
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.s),
                      AppButton(
                        label: _reported
                            ? app.t(S.reported)
                            : app.t(S.reportIt),
                        tone: ButtonTone.quiet,
                        icon: _reported
                            ? Icons.check_rounded
                            : Icons.flag_outlined,
                        onPressed: _reported ? null : _report,
                      ),
                    ],
                    if (lesson != null) ...[
                      const SizedBox(height: Space.xl),
                      PaperCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LessonScreen(lesson: lesson),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              color: C.inkSoft,
                              size: 20,
                            ),
                            const SizedBox(width: Space.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.t(S.learnMore), style: T.small),
                                  Text(app.t(lesson.title), style: T.heading),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: C.inkSoft,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: Space.l),
                    AppButton(
                      label: app.t(S.checkAnother),
                      tone: level == RiskLevel.safe
                          ? ButtonTone.ink
                          : ButtonTone.outline,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Likelihood extends StatelessWidget {
  const _Likelihood({required this.score, required this.color});
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final pct = (score * 100).round().clamp(1, 99);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(app.t(S.likelihood), style: T.small),
            const Spacer(),
            Text(
              '$pct%',
              style: T.small.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 5, color: C.sunk),
                FractionallySizedBox(
                  widthFactor: t.clamp(0.02, 1),
                  child: Container(height: 5, color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

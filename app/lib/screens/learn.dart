import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../content/call_scenarios.dart';
import '../content/lessons.dart';
import '../ui/postal.dart';
import '../ui/widgets.dart';
import 'call_sim.dart';
import 'lesson.dart';
import 'quiz.dart';

const _stampLook = <String, (IconData, Color)>{
  'digital-arrest': (Icons.videocam_outlined, Color(0xFFE2E5F3)),
  'kyc': (Icons.badge_outlined, C.marigoldTint),
  'otp': (Icons.password_rounded, C.leafTint),
  'electricity': (Icons.bolt_rounded, C.amberTint),
  'new-number': (Icons.family_restroom_rounded, C.sindoorTint),
  'easy-money': (Icons.savings_outlined, Color(0xFFE7E2F1)),
};

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final done = lessons
        .where((l) => app.completedLessons.contains(l.id))
        .length;
    void open(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return ListView(
      padding: EdgeInsets.fromLTRB(
        Space.page,
        MediaQuery.paddingOf(context).top + Space.xl,
        Space.page,
        120,
      ),
      children: [
        FadeUp(child: Text(app.t(S.learnTitle), style: T.display)),
        const SizedBox(height: Space.s),
        FadeUp(order: 1, child: Text(app.t(S.learnSub), style: T.bodySoft)),
        const SizedBox(height: Space.xl),

        // ---------------------------------------------- stamp collection
        Row(
          children: [
            Expanded(child: SectionLabel(app.t(S.collection))),
            Text(
              fill(app.t(S.collectionCount), {
                'n': done,
                'total': lessons.length,
              }),
              style: T.small.copyWith(
                color: C.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.s),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 4, color: C.sunk),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: (done / lessons.length).clamp(0.02, 1),
                child: Container(height: 4, color: C.leaf),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.l),
        for (var i = 0; i < lessons.length; i += 2) ...[
          Row(
            children: [
              for (var k = i; k < i + 2; k++) ...[
                if (k > i) const SizedBox(width: Space.l),
                Expanded(
                  child: k < lessons.length
                      ? FadeUp(
                          order: k + 2,
                          child: _LessonStamp(
                            index: k,
                            lesson: lessons[k],
                            done: app.completedLessons.contains(lessons[k].id),
                            onTap: () => open(LessonScreen(lesson: lessons[k])),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ],
          ),
          const SizedBox(height: Space.l),
        ],
        Text(
          app.t(S.collectionNote),
          style: T.small.copyWith(color: C.inkFaint),
        ),
        const SizedBox(height: Space.xxl),

        // ---------------------------------------------- practice calls
        Row(
          children: [
            Expanded(child: SectionLabel(app.t(S.practiceLabel))),
            Text(
              fill(app.t(S.callsPassedCount), {
                'n': app.passedCalls.length,
                'total': callScenarios.length,
              }),
              style: T.small.copyWith(color: C.inkFaint),
            ),
          ],
        ),
        const SizedBox(height: Space.s),
        for (final sc in callScenarios) ...[
          PaperCard(
            padding: const EdgeInsets.fromLTRB(
              Space.l,
              Space.m + 2,
              Space.l,
              Space.m + 2,
            ),
            onTap: () => open(CallSimScreen(scenario: sc)),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: C.leafTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: C.leaf,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Space.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.t(sc.title), style: T.heading),
                      const SizedBox(height: 2),
                      Text(app.t(sc.hook), style: T.small),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s),
                if (app.passedCalls.contains(sc.id))
                  Tooltip(
                    message: app.t(S.callPassed),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: C.leaf,
                      size: 20,
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: C.inkFaint,
                    size: 18,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.s),
        ],
        const SizedBox(height: Space.l),

        // ---------------------------------------------- quiz
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InkBackdrop(
            radius: 20,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => open(const QuizScreen()),
                child: Padding(
                  padding: const EdgeInsets.all(Space.l + 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.t(S.quizCardTitle),
                              style: T.title.copyWith(
                                color: C.paper,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app.t(S.quizCardBody),
                              style: T.small.copyWith(
                                color: const Color(0xFFC9CCE0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Space.m),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: C.marigold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          app.t(S.startQuiz),
                          style: T.small.copyWith(
                            color: C.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One lesson as a postage stamp. Finishing the lesson cancels the stamp
/// with a green postmark.
class _LessonStamp extends StatelessWidget {
  const _LessonStamp({
    required this.index,
    required this.lesson,
    required this.done,
    required this.onTap,
  });
  final int index;
  final Lesson lesson;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final (icon, tint) =
        _stampLook[lesson.id] ?? (Icons.mail_outline_rounded, C.sunk);
    return Transform.rotate(
      angle: (index.isEven ? -1 : 1) * 0.012,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Stamp(
          onTap: onTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: tint,
                        border: Border.all(color: C.hairline),
                      ),
                      padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                      child: Stack(
                        children: [
                          Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontFamily: F.serif,
                              fontSize: 17,
                              color: C.ink,
                              height: 1.1,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              fill(app.t(S.minutes), {'n': lesson.minutes}),
                              style: T.label.copyWith(
                                color: C.inkSoft,
                                fontSize: 10,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Center(child: Icon(icon, size: 38, color: C.ink)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(3, 8, 3, 2),
                    child: SizedBox(
                      height: 40,
                      child: Text(
                        app.t(lesson.title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: T.heading.copyWith(fontSize: 14, height: 1.3),
                      ),
                    ),
                  ),
                ],
              ),
              if (done)
                Positioned(
                  right: -50,
                  top: 70,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Postmark(
                      size: 62,
                      color: C.leaf.withValues(alpha: 0.85),
                      child: Text(
                        app.t(S.stampDone),
                        style: TextStyle(
                          fontFamily: F.sans,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: C.leaf.withValues(alpha: 0.95),
                        ),
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
}

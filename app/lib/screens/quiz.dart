import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../content/lessons.dart';
import '../ui/widgets.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _i = 0;
  int _score = 0;
  bool? _answer; // what the user said for the current card (true = scam)

  QuizItem get _item => quiz[_i];
  bool get _finished => _i >= quiz.length;

  void _pick(bool saysScam) {
    if (_answer != null) return;
    setState(() {
      _answer = saysScam;
      if (saysScam == _item.isScam) _score++;
    });
  }

  void _next() => setState(() {
    _i++;
    _answer = null;
  });

  void _restart() => setState(() {
    _i = 0;
    _score = 0;
    _answer = null;
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.s,
                Space.page,
                Space.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: C.ink),
                        style: IconButton.styleFrom(
                          backgroundColor: C.surface,
                          side: const BorderSide(color: C.hairline),
                        ),
                      ),
                      const SizedBox(width: Space.l),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value:
                                (_i + (_answer != null ? 1 : 0)) / quiz.length,
                            minHeight: 5,
                            backgroundColor: C.sunk,
                            color: C.marigold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xl),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(a),
                          child: child,
                        ),
                      ),
                      child: _finished ? _result(app) : _card(app),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(AppState app) {
    final answered = _answer != null;
    final right = answered && _answer == _item.isScam;
    return ListView(
      key: ValueKey(_i),
      children: [
        Text(
          fill(app.t(S.question), {'n': _i + 1, 'total': quiz.length}),
          style: T.small,
        ),
        const SizedBox(height: Space.xs),
        Text(app.t(S.quizQ), style: T.title),
        const SizedBox(height: Space.xl),
        MessageBubble(
          text: app.t(_item.message),
          sender: _item.sender,
          accent: answered
              ? (_item.isScam ? C.sindoor : C.leaf)
              : C.hairlineStrong,
        ),
        const SizedBox(height: Space.xl),
        if (!answered)
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: app.t(S.quizScam),
                  tone: ButtonTone.outline,
                  icon: Icons.gpp_bad_outlined,
                  onPressed: () => _pick(true),
                ),
              ),
              const SizedBox(width: Space.s),
              Expanded(
                child: AppButton(
                  label: app.t(S.quizReal),
                  tone: ButtonTone.outline,
                  icon: Icons.verified_outlined,
                  onPressed: () => _pick(false),
                ),
              ),
            ],
          )
        else ...[
          PaperCard(
            color: right ? C.leafTint : C.sindoorTint,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      right ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 18,
                      color: right ? C.leaf : C.sindoor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      app.t(right ? S.correct : S.notQuite),
                      style: T.heading.copyWith(
                        color: right ? C.leaf : C.sindoor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      app.t(_item.isScam ? S.quizScam : S.quizReal),
                      style: T.small.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: Space.s),
                Text(app.t(_item.why), style: T.body),
              ],
            ),
          ),
          const SizedBox(height: Space.l),
          AppButton(
            label: app.t(_i == quiz.length - 1 ? S.finish : S.next),
            onPressed: _next,
          ),
        ],
      ],
    );
  }

  Widget _result(AppState app) {
    final great = _score >= quiz.length - 1;
    return Column(
      key: const ValueKey('result'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          '$_score / ${quiz.length}',
          style: T.display.copyWith(
            fontSize: 56,
            color: great ? C.leaf : C.ink,
          ),
        ),
        const SizedBox(height: Space.m),
        Text(
          fill(app.t(S.quizResult), {'n': _score, 'total': quiz.length}),
          style: T.title,
        ),
        const SizedBox(height: Space.s),
        Text(app.t(great ? S.quizGreat : S.quizKeep), style: T.bodySoft),
        const Spacer(flex: 2),
        AppButton(
          label: app.t(S.backToLearn),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: Space.s),
        AppButton(
          label: app.t(S.tryAgain),
          tone: ButtonTone.outline,
          onPressed: _restart,
        ),
      ],
    );
  }
}

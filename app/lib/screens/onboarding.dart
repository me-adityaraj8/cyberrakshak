import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../app/tr.dart';
import '../ui/postal.dart';
import '../ui/widgets.dart';

/// First launch: pick a language, then (optionally) a name.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.xl,
                Space.page,
                Space.xl,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0 ? _language(app) : _welcome(app),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _language(AppState app) {
    Widget tile(Lang l, String glyph, String name, String other) {
      final on = app.lang == l;
      return Expanded(
        child: GestureDetector(
          onTap: () => app.setLang(l),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            height: 190,
            padding: const EdgeInsets.all(Space.l),
            decoration: BoxDecoration(
              color: on ? C.ink : C.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: on ? C.ink : C.hairlineStrong),
              boxShadow: on
                  ? const [
                      BoxShadow(
                        color: Color(0x331B2350),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: on ? C.marigold : Colors.transparent,
                        border: Border.all(
                          color: on ? C.marigold : C.hairlineStrong,
                          width: 1.5,
                        ),
                      ),
                      child: on
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: C.ink,
                            )
                          : null,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  glyph,
                  style: TextStyle(
                    fontFamily: F.serif,
                    fontSize: 62,
                    height: 1.1,
                    color: on ? C.marigoldTint : C.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: T.heading.copyWith(color: on ? C.paper : C.ink),
                ),
                Text(
                  other,
                  style: T.small.copyWith(
                    color: on ? const Color(0xFFB9BDD6) : C.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      key: const ValueKey('lang'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Emblem(),
        const Spacer(),
        Text('भाषा चुनें · Choose language', style: T.small),
        const SizedBox(height: Space.xs),
        Text(app.t(S.chooseLanguage), style: T.display),
        const SizedBox(height: Space.xl),
        Row(
          children: [
            tile(Lang.hi, 'अ', 'हिन्दी', 'Hindi'),
            const SizedBox(width: Space.m),
            tile(Lang.en, 'A', 'English', 'अंग्रेज़ी'),
          ],
        ),
        const SizedBox(height: Space.m),
        Text(
          app.t(S.chooseLanguageNote),
          style: T.small.copyWith(color: C.inkFaint),
        ),
        const Spacer(flex: 2),
        AppButton(
          label: app.t(S.continueBtn),
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _welcome(AppState app) {
    return Column(
      key: const ValueKey('welcome'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Emblem(),
        const Spacer(),
        Transform.rotate(
          angle: -0.06,
          child: SizedBox(
            width: 92,
            height: 112,
            child: Stamp(
              padding: const EdgeInsets.all(8),
              child: Container(
                color: C.ink,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shield_rounded,
                  color: C.marigold,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        Text(app.t(S.welcomeTitle), style: T.display),
        const SizedBox(height: Space.m),
        Text(app.t(S.welcomeBody), style: T.bodySoft),
        const SizedBox(height: Space.xxl),
        Text(app.t(S.yourName), style: T.heading),
        const SizedBox(height: Space.s),
        TextField(
          controller: _name,
          style: T.body,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: app.t(S.yourNameHint),
            hintStyle: T.body.copyWith(color: C.inkFaint),
            filled: true,
            fillColor: C.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: C.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: C.ink),
            ),
          ),
          onSubmitted: (_) => app.completeOnboarding(_name.text),
        ),
        const Spacer(flex: 2),
        AppButton(
          label: app.t(S.continueBtn),
          onPressed: () => app.completeOnboarding(_name.text),
        ),
      ],
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: C.ink,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'र',
            style: TextStyle(
              fontFamily: F.serif,
              fontSize: 24,
              color: C.marigoldTint,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CyberRakshak',
              style: TextStyle(
                fontFamily: F.sans,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: C.ink,
                height: 1.1,
              ),
            ),
            Text('साइबर रक्षक', style: T.small.copyWith(height: 1.2)),
          ],
        ),
      ],
    );
  }
}

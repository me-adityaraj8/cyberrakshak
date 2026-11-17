import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app_state.dart';
import 'app/share_intake.dart';
import 'app/strings.dart';
import 'app/theme.dart';
import 'screens/help.dart';
import 'screens/home.dart';
import 'screens/learn.dart';
import 'screens/onboarding.dart';
import 'screens/verdict.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: C.paper,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final state = AppState();
  await state.load();
  runApp(
    ChangeNotifierProvider.value(value: state, child: const CyberRakshakApp()),
  );
}

class CyberRakshakApp extends StatelessWidget {
  const CyberRakshakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarded = context.select<AppState, bool>((s) => s.onboarded);
    return MaterialApp(
      title: 'CyberRakshak',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: onboarded ? const Shell() : const OnboardingScreen(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  static const _pages = [HomeScreen(), LearnScreen(), HelpScreen()];

  @override
  void initState() {
    super.initState();
    ShareIntake.listen(_onShared);
  }

  /// A message shared from WhatsApp, SMS or any other app: check it now.
  void _onShared(String text) {
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    setState(() => _tab = 0);
    openCheck(context, text, shared: true);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = [
      (Icons.shield_outlined, Icons.shield_rounded, app.t(S.navHome)),
      (Icons.menu_book_outlined, Icons.menu_book_rounded, app.t(S.navLearn)),
      (Icons.support_outlined, Icons.support, app.t(S.navHelp)),
    ];
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: C.paper,
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: IndexedStack(index: _tab, children: _pages),
            ),
          ),
          // the paper fades out under the floating bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 110,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [C.paper.withValues(alpha: 0), C.paper],
                    stops: const [0, 0.75],
                  ),
                ),
              ),
            ),
          ),
          if (!keyboardUp)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 14),
                child: Center(
                  child: _FloatingNav(
                    items: items,
                    index: _tab,
                    onTap: (i) => setState(() => _tab = i),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// An ink pill that floats over the page. The current tab is a paper chip
/// that slides between positions.
class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.items,
    required this.index,
    required this.onTap,
  });
  final List<(IconData, IconData, String)> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 316,
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: C.ink,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D1B2350),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x1F1B2350),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment(-1 + index * 2 / (items.length - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / items.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: C.paper,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (final (i, (icon, activeIcon, label)) in items.indexed)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Semantics(
                        button: true,
                        selected: i == index,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              i == index ? activeIcon : icon,
                              size: 19,
                              color: i == index
                                  ? C.ink
                                  : const Color(0xFFB9BDD6),
                            ),
                            const SizedBox(width: 7),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontFamily: F.sans,
                                fontSize: 13.5,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: i == index
                                    ? C.ink
                                    : const Color(0xFFB9BDD6),
                              ),
                              child: Text(label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

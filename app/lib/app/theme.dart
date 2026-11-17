import 'package:material_ui/material_ui.dart';

/// CyberRakshak design tokens. "Chitthi": handmade paper, indigo ink,
/// marigold for warmth, sindoor red reserved for danger.
///
/// Rule of thumb: one large serif line per screen. Everything else is quiet.
class C {
  static const paper = Color(0xFFF6F1E7);
  static const surface = Color(0xFFFCF9F3);
  static const sunk = Color(0xFFEFE8DA);
  static const ink = Color(0xFF1B2350);
  static const inkSoft = Color(0xFF4B527A);
  static const inkFaint = Color(0xFF8A8FA8);
  static const hairline = Color(0x1F1B2350);
  static const hairlineStrong = Color(0x381B2350);

  static const marigold = Color(0xFFC98A1E);
  static const marigoldTint = Color(0xFFF3E4C4);

  static const sindoor = Color(0xFFA3241C);
  static const sindoorTint = Color(0xFFF5E1DC);
  static const amber = Color(0xFF9C5F0C);
  static const amberTint = Color(0xFFF4E7CF);
  static const leaf = Color(0xFF2E6A4E);
  static const leafTint = Color(0xFFE2EDE4);
}

class F {
  static const serif = 'Tiro';
  static const sans = 'Mukta';
}

/// Type scale. Sizes are deliberately modest; hierarchy comes from the serif
/// vs sans contrast and from colour, not from shouting.
class T {
  static const display = TextStyle(
    fontFamily: F.serif,
    fontSize: 27,
    height: 1.22,
    color: C.ink,
    letterSpacing: -0.2,
  );
  static const title = TextStyle(
    fontFamily: F.serif,
    fontSize: 20,
    height: 1.3,
    color: C.ink,
  );
  static const heading = TextStyle(
    fontFamily: F.sans,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: C.ink,
  );
  static const body = TextStyle(
    fontFamily: F.sans,
    fontSize: 15,
    height: 1.5,
    color: C.ink,
  );
  static const bodySoft = TextStyle(
    fontFamily: F.sans,
    fontSize: 15,
    height: 1.5,
    color: C.inkSoft,
  );
  static const small = TextStyle(
    fontFamily: F.sans,
    fontSize: 13,
    height: 1.45,
    color: C.inkSoft,
  );
  static const label = TextStyle(
    fontFamily: F.sans,
    fontSize: 11.5,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.9,
    color: C.inkFaint,
  );
  static const quote = TextStyle(
    fontFamily: F.serif,
    fontSize: 15.5,
    height: 1.5,
    fontStyle: FontStyle.italic,
    color: C.ink,
  );
  static const number = TextStyle(
    fontFamily: F.serif,
    fontSize: 30,
    height: 1.0,
    color: C.ink,
  );
}

class Space {
  static const xs = 4.0,
      s = 8.0,
      m = 12.0,
      l = 16.0,
      xl = 24.0,
      xxl = 32.0,
      page = 22.0;
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: F.sans,
    scaffoldBackgroundColor: C.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.ink,
      surface: C.paper,
      primary: C.ink,
      error: C.sindoor,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: F.sans,
      bodyColor: C.ink,
      displayColor: C.ink,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: C.ink,
      selectionColor: C.marigoldTint,
      selectionHandleColor: C.marigold,
    ),
    dividerTheme: const DividerThemeData(
      color: C.hairline,
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}

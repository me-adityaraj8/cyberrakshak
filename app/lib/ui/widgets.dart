import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/theme.dart';
import '../app/tr.dart';
import '../detection/detector.dart';

/// Small tracked label above a section. Hindi labels are not upper-cased.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: T.label.copyWith(color: color ?? C.inkFaint));
}

/// The quiet container used everywhere: warm surface, hairline, no shadow.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.l),
    this.color = C.surface,
    this.borderColor = C.hairline,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: borderColor),
    );
    return Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

enum ButtonTone { ink, danger, outline, quiet }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = ButtonTone.ink,
    this.icon,
    this.expand = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final ButtonTone tone;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (bg, fgActive, side) = switch (tone) {
      ButtonTone.ink => (C.ink, C.paper, BorderSide.none),
      ButtonTone.danger => (C.sindoor, Colors.white, BorderSide.none),
      ButtonTone.outline => (
        Colors.transparent,
        C.ink,
        const BorderSide(color: C.hairlineStrong),
      ),
      ButtonTone.quiet => (C.sunk, C.ink, BorderSide.none),
    };
    final fg = onPressed == null ? C.inkFaint : fgActive;
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: T.heading.copyWith(color: fg, fontSize: 15),
          ),
        ),
      ],
    );
    return SizedBox(
      height: 50,
      width: expand ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: onPressed == null ? C.sunk : bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: side,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// "हि | EN" switch. Always visible on the home header.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key, this.onDark = false});
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    Widget seg(Lang l, String label) {
      final on = app.lang == l;
      return GestureDetector(
        onTap: () => app.setLang(l),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: on ? (onDark ? C.paper : C.ink) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: F.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: on
                  ? (onDark ? C.ink : C.paper)
                  : (onDark ? const Color(0xFFB9BDD6) : C.inkSoft),
              height: 1.1,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Language',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: onDark ? const Color(0x40FFFFFF) : C.hairlineStrong,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [seg(Lang.hi, 'हिन्दी'), seg(Lang.en, 'EN')],
        ),
      ),
    );
  }
}

Color levelColor(RiskLevel l) => switch (l) {
  RiskLevel.scam => C.sindoor,
  RiskLevel.suspicious => C.amber,
  RiskLevel.safe => C.leaf,
};

Color levelTint(RiskLevel l) => switch (l) {
  RiskLevel.scam => C.sindoorTint,
  RiskLevel.suspicious => C.amberTint,
  RiskLevel.safe => C.leafTint,
};

/// A rubber-stamp seal: double ring, slightly rotated, stamps in.
class Seal extends StatefulWidget {
  const Seal({
    super.key,
    required this.label,
    required this.sub,
    required this.color,
    this.size = 96,
  });
  final String label;
  final String sub;
  final Color color;
  final double size;

  @override
  State<Seal> createState() => _SealState();
}

class _SealState extends State<Seal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = reduce ? 1.0 : Curves.easeOutBack.transform(_c.value);
        final o = reduce
            ? 1.0
            : Curves.easeOut.transform((_c.value * 1.6).clamp(0, 1));
        return Opacity(
          opacity: o,
          child: Transform.rotate(
            angle: (-9 + (1 - t) * -10) * math.pi / 180,
            child: Transform.scale(scale: 1.35 - 0.35 * t, child: child),
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _SealPainter(widget.color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: widget.size * 0.7,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: F.serif,
                        fontSize: widget.size * 0.21,
                        color: widget.color,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.sub,
                  style: TextStyle(
                    fontFamily: F.sans,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  _SealPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withValues(alpha: 0.9);
    canvas.drawCircle(c, r - 1.5, p..strokeWidth = 2.4);
    canvas.drawCircle(c, r - 7, p..strokeWidth = 0.9);
    // little ticks around the ring, like a postal cancellation mark
    final tick = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 0; i < 36; i++) {
      final a = i * math.pi * 2 / 36;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * (r - 7), c + d * (r - 4.5), tick);
    }
  }

  @override
  bool shouldRepaint(_SealPainter old) => old.color != color;
}

/// A message shown the way a phone shows it: sender line + bubble.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    this.sender,
    this.accent = C.hairlineStrong,
    this.marks = const [],
  });
  final String text;
  final String? sender;
  final Color accent;

  /// Phrases to mark inside the text: (start, end, colour). Earlier marks win
  /// where two overlap, so pass red flags before good signs.
  final List<(int, int, Color)> marks;

  TextSpan _spans() {
    const base = TextStyle(
      fontFamily: F.sans,
      fontSize: 14.5,
      height: 1.55,
      color: C.ink,
    );
    if (marks.isEmpty) return TextSpan(text: text, style: base);
    final owner = List<Color?>.filled(text.length, null);
    for (final (a, b, c) in marks) {
      for (var i = a.clamp(0, text.length); i < b.clamp(0, text.length); i++) {
        owner[i] ??= c;
      }
    }
    final out = <TextSpan>[];
    var start = 0;
    for (var i = 1; i <= text.length; i++) {
      if (i == text.length || owner[i] != owner[start]) {
        final c = owner[start];
        out.add(
          TextSpan(
            text: text.substring(start, i),
            style: c == null
                ? null
                : TextStyle(
                    background: Paint()..color = c.withValues(alpha: 0.13),
                    decoration: TextDecoration.underline,
                    decorationColor: c.withValues(alpha: 0.75),
                    decorationThickness: 1.6,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
          ),
        );
        start = i;
      }
    }
    return TextSpan(style: base, children: out);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sender != null) ...[
          Text(
            sender!,
            style: T.small.copyWith(
              fontWeight: FontWeight.w600,
              color: C.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border(
              left: BorderSide(color: accent, width: 3),
              top: const BorderSide(color: C.hairline),
              right: const BorderSide(color: C.hairline),
              bottom: const BorderSide(color: C.hairline),
            ),
          ),
          child: Text.rich(_spans()),
        ),
      ],
    );
  }
}

/// Numbered list row used for reasons and steps.
class NumberedRow extends StatelessWidget {
  const NumberedRow({
    super.key,
    required this.n,
    required this.text,
    this.color = C.ink,
  });
  final int n;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Text(
              n.toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: F.serif,
                fontSize: 14,
                color: color,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: T.body)),
        ],
      ),
    );
  }
}

class Hairline extends StatelessWidget {
  const Hairline({super.key, this.vertical = Space.l});
  final double vertical;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: vertical),
    child: const Divider(),
  );
}

void showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: T.body.copyWith(color: C.paper, fontSize: 14),
        ),
        backgroundColor: C.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
}

/// Content that rises into place when a screen opens. Pass increasing
/// [order] values down the page for a gentle stagger.
class FadeUp extends StatelessWidget {
  const FadeUp({super.key, required this.child, this.order = 0});
  final Widget child;
  final int order;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final delay = (order * 60).clamp(0, 480);
    final total = 420 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 14),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../app/theme.dart';

/// The visual language of the app borrows from the Indian post: airmail
/// edging, perforated stamps and cancellation postmarks. A letter you can
/// trust, checked before it reaches you.

/// Diagonal ink-and-marigold stripes, like the edge of an airmail envelope.
class AirmailStrip extends StatelessWidget {
  const AirmailStrip({super.key, this.height = 6});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: _AirmailPainter()),
  );
}

class _AirmailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    const w = 14.0, gap = 8.0;
    final skew = size.height * 1.1;
    var x = -skew;
    var i = 0;
    while (x < size.width + skew) {
      final p = Path()
        ..moveTo(x + skew, 0)
        ..lineTo(x + skew + w, 0)
        ..lineTo(x + w, size.height)
        ..lineTo(x, size.height)
        ..close();
      canvas.drawPath(p, Paint()..color = i.isEven ? C.ink : C.marigold);
      x += w + gap;
      i++;
    }
  }

  @override
  bool shouldRepaint(_AirmailPainter old) => false;
}

/// A postage stamp: paper with perforated edges and a soft shadow.
class Stamp extends StatelessWidget {
  const Stamp({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(9),
    this.color = C.surface,
    this.onTap,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _StampPainter(color),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

Path _perforated(Size s, {double r = 3.6}) {
  final holes = Path();
  void edge(double length, Offset Function(double d) at) {
    final n = math.max(3, (length / (r * 3.3)).round());
    final step = length / n;
    for (var i = 0; i < n; i++) {
      holes.addOval(Rect.fromCircle(center: at((i + 0.5) * step), radius: r));
    }
  }

  edge(s.width, (d) => Offset(d, 0));
  edge(s.width, (d) => Offset(d, s.height));
  edge(s.height, (d) => Offset(0, d));
  edge(s.height, (d) => Offset(s.width, d));
  return Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & s),
    holes,
  );
}

class _StampPainter extends CustomPainter {
  _StampPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _perforated(size);
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x1F1B2350)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StampPainter old) => old.color != color;
}

/// A cancellation postmark: a double ring with wavy lines trailing off.
class Postmark extends StatelessWidget {
  const Postmark({
    super.key,
    required this.color,
    this.size = 64,
    this.child,
    this.waves = true,
  });
  final Color color;
  final double size;
  final Widget? child;
  final bool waves;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: waves ? size * 1.9 : size,
    height: size,
    child: CustomPaint(
      painter: PostmarkPainter(color, waves: waves),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class PostmarkPainter extends CustomPainter {
  PostmarkPainter(this.color, {this.waves = true});
  final Color color;
  final bool waves;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final c = Offset(r, r);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = math.max(1.2, r * 0.045);
    canvas.drawCircle(c, r - 1.5, p);
    canvas.drawCircle(c, r * 0.76, p..strokeWidth = math.max(0.8, r * 0.025));
    if (!waves) return;
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = math.max(1.1, r * 0.04)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = r + (i - 1.5) * r * 0.36;
      final path = Path()..moveTo(r * 2 + 2, y);
      final seg = (size.width - r * 2 - 4) / 6;
      for (var k = 0; k < 6; k++) {
        final x0 = r * 2 + 2 + k * seg;
        path.quadraticBezierTo(
          x0 + seg / 2,
          y + (k.isEven ? -1 : 1) * r * 0.13,
          x0 + seg,
          y,
        );
      }
      canvas.drawPath(path, wave);
    }
  }

  @override
  bool shouldRepaint(PostmarkPainter old) => old.color != color;
}

/// A dashed rule, horizontal or vertical: the tear line on a ticket.
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.color = C.hairlineStrong,
  });
  final Axis axis;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: axis == Axis.horizontal
        ? const Size(double.infinity, 1)
        : const Size(1, double.infinity),
    painter: _DashPainter(axis, color),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.axis, this.color);
  final Axis axis;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final len = axis == Axis.horizontal ? size.width : size.height;
    for (var d = 0.0; d < len; d += 7) {
      final a = axis == Axis.horizontal ? Offset(d, 0.5) : Offset(0.5, d);
      final b = axis == Axis.horizontal
          ? Offset(math.min(d + 3, len), 0.5)
          : Offset(0.5, math.min(d + 3, len));
      canvas.drawLine(a, b, p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// Backdrop for ink panels: a faint jaali lattice with a large marigold
/// postmark drifting off the top-right corner.
class InkBackdrop extends StatelessWidget {
  const InkBackdrop({super.key, required this.child, this.radius = 30});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
    child: CustomPaint(painter: _InkBackdropPainter(), child: child),
  );
}

class _InkBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232C63), C.ink, Color(0xFF141A40)],
        ).createShader(Offset.zero & size),
    );
    // jaali: small diamonds on a staggered grid
    final dot = Paint()..color = const Color(0x0DFFFFFF);
    const step = 22.0;
    var row = 0;
    for (var y = 6.0; y < size.height; y += step / 2, row++) {
      for (
        var x = row.isEven ? 6.0 : 6.0 + step / 2;
        x < size.width;
        x += step
      ) {
        canvas.drawPath(
          Path()
            ..moveTo(x, y - 2.2)
            ..lineTo(x + 2.2, y)
            ..lineTo(x, y + 2.2)
            ..lineTo(x - 2.2, y)
            ..close(),
          dot,
        );
      }
    }
    // postmark, half off the corner
    canvas.save();
    canvas.translate(size.width - 118, 64);
    canvas.rotate(-14 * math.pi / 180);
    PostmarkPainter(C.marigold.withValues(alpha: 0.2))
        .paint(canvas, const Size(250, 132));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InkBackdropPainter old) => false;
}

/// A soft colour wash that fades into the paper, used behind headers.
class TopWash extends StatelessWidget {
  const TopWash({super.key, required this.color, this.height = 300});
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    ),
  );
}

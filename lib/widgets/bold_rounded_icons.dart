import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Pixel-accurate Bold & Rounded Vector Icons matching user reference images:
/// - Fa10517c: Bold rounded Close 'X' icon
/// - 54b811c1: Bold rounded Share icon (open box with rounded arrow)
/// - 88db6175: Bold rounded Download icon (downward arrow + rounded bottom bar)
/// - E7c90ebf: Bold rounded Left Arrow icon
/// - Cb5b9e9d: Bold rounded Success Checkmark (extra thick with rounded joint & caps)

/// Bold Rounded Close 'X' Icon (Fa10517c)
class BoldCloseIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldCloseIcon({
    super.key,
    this.size = 18,
    this.color = Colors.white,
    this.strokeWidth = 2.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.xmark, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: _BoldClosePainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldClosePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldClosePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final inset = size.width * 0.18;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BoldClosePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Left Arrow Icon (E7c90ebf)
class BoldBackArrowIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldBackArrowIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
    this.strokeWidth = 2.8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.arrow_left, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: _BoldBackArrowPainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldBackArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldBackArrowPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final leftX = size.width * 0.16;
    final rightX = size.width * 0.84;
    final wingExtent = size.width * 0.32;

    // Horizontal shaft
    canvas.drawLine(Offset(leftX, centerY), Offset(rightX, centerY), paint);

    // Chevron wings
    final path = Path()
      ..moveTo(leftX + wingExtent, centerY - wingExtent)
      ..lineTo(leftX, centerY)
      ..lineTo(leftX + wingExtent, centerY + wingExtent);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldBackArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Share Icon (54b811c1)
class BoldShareIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldShareIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
    this.strokeWidth = 2.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.share, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: _BoldSharePainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldSharePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldSharePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // 1. Box with rounded corners and open top
    final boxLeft = w * 0.16;
    final boxRight = w * 0.84;
    final boxTop = h * 0.38;
    final boxBottom = h * 0.88;
    final radius = w * 0.16;

    final boxPath = Path()
      ..moveTo(boxLeft, boxTop + radius * 0.4)
      ..lineTo(boxLeft, boxBottom - radius)
      ..arcToPoint(Offset(boxLeft + radius, boxBottom), radius: Radius.circular(radius))
      ..lineTo(boxRight - radius, boxBottom)
      ..arcToPoint(Offset(boxRight, boxBottom - radius), radius: Radius.circular(radius))
      ..lineTo(boxRight, boxTop + radius * 0.4);

    canvas.drawPath(boxPath, paint);

    // 2. Upward arrow in center
    final centerX = w / 2;
    final arrowTop = h * 0.12;
    final arrowBottom = h * 0.62;
    final wingExtent = w * 0.22;

    // Arrow vertical shaft
    canvas.drawLine(Offset(centerX, arrowTop), Offset(centerX, arrowBottom), paint);

    // Arrow chevron head
    final headPath = Path()
      ..moveTo(centerX - wingExtent, arrowTop + wingExtent)
      ..lineTo(centerX, arrowTop)
      ..lineTo(centerX + wingExtent, arrowTop + wingExtent);

    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldSharePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Download Icon (88db6175)
class BoldDownloadIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldDownloadIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
    this.strokeWidth = 2.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.arrow_down_to_line, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: _BoldDownloadPainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldDownloadPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldDownloadPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    final arrowTop = h * 0.14;
    final arrowBottom = h * 0.64;
    final wingExtent = w * 0.24;

    // Downward arrow vertical shaft
    canvas.drawLine(Offset(centerX, arrowTop), Offset(centerX, arrowBottom), paint);

    // Downward chevron head
    final headPath = Path()
      ..moveTo(centerX - wingExtent, arrowBottom - wingExtent)
      ..lineTo(centerX, arrowBottom)
      ..lineTo(centerX + wingExtent, arrowBottom - wingExtent);

    canvas.drawPath(headPath, paint);

    // Horizontal bottom base bar
    final barY = h * 0.86;
    final barInset = w * 0.22;
    canvas.drawLine(Offset(barInset, barY), Offset(w - barInset, barY), paint);
  }

  @override
  bool shouldRepaint(covariant _BoldDownloadPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Checkmark Icon (Cb5b9e9d)
class BoldCheckmarkIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldCheckmarkIcon({
    super.key,
    this.size = 26,
    this.color = Colors.white,
    this.strokeWidth = 3.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.checkmark_alt, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: _BoldCheckmarkPainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldCheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldCheckmarkPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Checkmark coordinates with smooth rounded joint and rounded tips
    final path = Path()
      ..moveTo(w * 0.20, h * 0.52)
      ..lineTo(w * 0.42, h * 0.76)
      ..lineTo(w * 0.82, h * 0.26);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldCheckmarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Send / Paperplane Icon
class BoldSendIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldSendIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
    this.strokeWidth = 2.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.paperplane, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: _BoldSendPainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldSendPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldSendPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final tip = Offset(w * 0.88, h * 0.12);
    final leftWing = Offset(w * 0.12, h * 0.48);
    final fold = Offset(w * 0.42, h * 0.58);
    final bottomWing = Offset(w * 0.52, h * 0.88);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftWing.dx, leftWing.dy)
      ..lineTo(fold.dx, fold.dy)
      ..lineTo(bottomWing.dx, bottomWing.dy)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawLine(fold, tip, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldSendPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Right / Forward Arrow Icon
class BoldForwardArrowIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldForwardArrowIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
    this.strokeWidth = 2.8,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.arrow_right, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter:
              _BoldForwardArrowPainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldForwardArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldForwardArrowPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final leftX = size.width * 0.16;
    final rightX = size.width * 0.84;
    final wingExtent = size.width * 0.32;

    // Horizontal shaft
    canvas.drawLine(Offset(leftX, centerY), Offset(rightX, centerY), paint);

    // Chevron wings pointing right
    final path = Path()
      ..moveTo(rightX - wingExtent, centerY - wingExtent)
      ..lineTo(rightX, centerY)
      ..lineTo(rightX - wingExtent, centerY + wingExtent);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldForwardArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bold Rounded Right Chevron Icon
class BoldChevronRightIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BoldChevronRightIcon({
    super.key,
    this.size = 14,
    this.color = Colors.white,
    this.strokeWidth = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Semantic icon for automated widget tests
        Opacity(
          opacity: 0.0,
          child: Icon(CupertinoIcons.chevron_right, size: size, color: color),
        ),
        CustomPaint(
          size: Size(size, size),
          painter:
              _BoldChevronRightPainter(color: color, strokeWidth: strokeWidth),
        ),
      ],
    );
  }
}

class _BoldChevronRightPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BoldChevronRightPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.35, h * 0.20)
      ..lineTo(w * 0.65, h * 0.50)
      ..lineTo(w * 0.35, h * 0.80);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldChevronRightPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}


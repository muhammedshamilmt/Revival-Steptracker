import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/onboarding_item.dart';
import '../../theme/app_typography.dart';

class ActivityStatsOverlay extends StatelessWidget {
  final OnboardingItem item;

  const ActivityStatsOverlay({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Vignette Gradient (protects contrast against bright photos)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Colors.transparent,
                  Color(0x22000000),
                  Color(0x99000000),
                ],
                stops: [0.0, 0.28, 0.60, 1.0],
              ),
            ),
          ),
        ),

        // Top Centered Frosted Pill Chip (e.g. "just vibing & gliding ☁️")
        Positioned(
          top: 24,
          left: 20,
          right: 20,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E3E42).withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.tag,
                    style: AppTypography.base.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Left Metrics Cluster (Pace, Distance, Moving Time)
        Positioned(
          left: 22,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: item.stats.map((stat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          stat.value,
                          style: AppTypography.base.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.8,
                            height: 1.05,
                          ),
                        ),
                        if (stat.unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            stat.unit,
                            style: AppTypography.base.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stat.label,
                      style: AppTypography.base.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Bottom Right: Neon GPS Route Polyline
        Positioned(
          right: 22,
          bottom: 30,
          child: CustomPaint(
            size: const Size(110, 80),
            painter: RoutePolylinePainter(
              points: item.routePoints,
              startColor: item.startRouteColor,
              endColor: item.endRouteColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter for the neon gradient GPS route
class RoutePolylinePainter extends CustomPainter {
  final List<Offset> points;
  final Color startColor;
  final Color endColor;

  const RoutePolylinePainter({
    required this.points,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [startColor, endColor],
    );

    // Glow stroke behind
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(path, glowPaint);

    // Core crisp stroke
    final linePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant RoutePolylinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}

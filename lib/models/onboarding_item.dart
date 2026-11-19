import 'package:flutter/material.dart';

class OnboardingStat {
  final String value;
  final String unit;
  final String label;

  const OnboardingStat({
    required this.value,
    required this.unit,
    required this.label,
  });
}

class OnboardingItem {
  final String id;
  final String tag;
  final String imageUrl;
  final List<OnboardingStat> stats;
  final List<Offset> routePoints;
  final Color startRouteColor;
  final Color endRouteColor;

  const OnboardingItem({
    required this.id,
    required this.tag,
    required this.imageUrl,
    required this.stats,
    required this.routePoints,
    this.startRouteColor = const Color(0xFFFF8A1E),
    this.endRouteColor = const Color(0xFFFF3D8E),
  });

  /// The 4 main hero run cards referenced in the Everyday onboarding spec
  /// using high quality authentic running photography instead of vector drawings.
  static const List<OnboardingItem> heroItems = [
    OnboardingItem(
      id: 'A',
      tag: 'just vibing & gliding ☁️',
      // High-resolution real running photograph: friends running outdoors
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1200&auto=format&fit=crop',
      stats: [
        OnboardingStat(value: '7.21', unit: 'mins', label: 'pace'),
        OnboardingStat(value: '9.36', unit: 'km', label: 'distance'),
        OnboardingStat(value: '1h 25m', unit: '', label: 'moving time'),
      ],
      routePoints: [
        Offset(0.05, 0.70),
        Offset(0.05, 0.44),
        Offset(0.28, 0.44),
        Offset(0.28, 0.20),
        Offset(0.60, 0.07),
        Offset(0.72, 0.40),
        Offset(0.52, 0.50),
        Offset(0.50, 0.76),
        Offset(0.22, 0.82),
      ],
    ),
    OnboardingItem(
      id: 'B',
      tag: 'chasing the sunrise',
      // High-resolution runner in golden hour
      imageUrl:
          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?q=80&w=1200&auto=format&fit=crop',
      stats: [
        OnboardingStat(value: '6.16', unit: 'mins', label: 'pace'),
        OnboardingStat(value: '5.36', unit: 'km', label: 'distance'),
        OnboardingStat(value: '32m 25s', unit: '', label: 'moving time'),
      ],
      routePoints: [
        Offset(0.04, 0.38),
        Offset(0.20, 0.76),
        Offset(0.30, 0.07),
        Offset(0.42, 0.85),
        Offset(0.52, 0.48),
        Offset(0.82, 0.15),
        Offset(0.76, 0.68),
      ],
    ),
    OnboardingItem(
      id: 'C',
      tag: 'less running, more talking ✌️',
      // High-resolution runners group selfie / bridge jog
      imageUrl:
          'https://images.unsplash.com/photo-1502680390469-be75c86b636f?q=80&w=1200&auto=format&fit=crop',
      stats: [
        OnboardingStat(value: '5.21', unit: 'mins', label: 'pace'),
        OnboardingStat(value: '8.30', unit: 'km', label: 'distance'),
        OnboardingStat(value: '44m 25s', unit: '', label: 'moving time'),
      ],
      routePoints: [
        Offset(0.05, 0.30),
        Offset(0.25, 0.48),
        Offset(0.38, 0.15),
        Offset(0.48, 0.68),
        Offset(0.76, 0.78),
        Offset(0.92, 0.48),
      ],
    ),
    OnboardingItem(
      id: 'D',
      tag: 'legs tired',
      // High-resolution trail / sunset athlete
      imageUrl:
          'https://images.unsplash.com/photo-1486218119243-13883505764c?q=80&w=1200&auto=format&fit=crop',
      stats: [
        OnboardingStat(value: '7.21', unit: 'mins', label: 'pace'),
        OnboardingStat(value: '9.36', unit: 'km', label: 'distance'),
        OnboardingStat(value: '1h 25m', unit: '', label: 'moving time'),
      ],
      routePoints: [
        Offset(0.04, 0.80),
        Offset(0.42, 0.80),
        Offset(0.42, 0.44),
        Offset(0.66, 0.44),
        Offset(0.66, 0.20),
        Offset(0.97, 0.11),
        Offset(0.93, 0.50),
        Offset(0.77, 0.63),
      ],
    ),
  ];

  /// Additional image URLs for the scrolling filmstrip
  static const List<String> stripImages = [
    'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1486218119243-13883505764c?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1502680390469-be75c86b636f?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1530549387789-4c1017266635?q=80&w=600&auto=format&fit=crop',
  ];
}

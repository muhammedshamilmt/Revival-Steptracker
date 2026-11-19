import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Solid / Filled Hugeicons implementations matching design specifications.
class AppHugeIcons {
  AppHugeIcons._();

  // 1. User Group (Solid standard three-person silhouette with heads near body)
  static const String solidStandardUserGroup02Svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <circle cx="12" cy="6.2" r="3.5"/>
  <circle cx="5.4" cy="8.4" r="2.8"/>
  <circle cx="18.6" cy="8.4" r="2.8"/>
  <path d="M7.0 20.4c0-5.2 2.2-8.6 5.0-8.6s5.0 3.4 5.0 8.6c0 .9-.7 1.6-1.6 1.6H8.6c-.9 0-1.6-.7-1.6-1.6z"/>
  <path d="M2.2 19.8c0-3.6 1.4-6.4 3.4-6.8.5-.1.9.3.8.8-.4 1.7-.4 3.8.2 5.6.2.5-.2 1.0-.7 1.0H4.1c-.9 0-1.9-.3-1.9-.6z"/>
  <path d="M21.8 19.8c0-3.6-1.4-6.4-3.4-6.8-.5-.1-.9.3-.8.8.4 1.7.4 3.8-.2 5.6-.2.5.2 1.0.7 1.0h1.8c.9 0 1.9-.3 1.9-.6z"/>
</svg>
''';

  // 2. Calendar Clock (Solid rounded calendar body with clock cutout)
  static const String solidRoundedCalendarClockSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <path d="M7 2a1 1 0 011 1v2a1 1 0 01-2 0V3a1 1 0 011-1zm10 0a1 1 0 011 1v2a1 1 0 01-2 0V3a1 1 0 011-1z"/>
  <path fill-rule="evenodd" clip-rule="evenodd" d="M6.5 4A3.5 3.5 0 003 7.5v9A3.5 3.5 0 006.5 20h2.76A7.03 7.03 0 019 16a7 7 0 017-7c1.47 0 2.82.45 3.94 1.22.04-.23.06-.47.06-.72V7.5A3.5 3.5 0 0016.5 4h-10zm-1.5 5.5h14V7.5A1.5 1.5 0 0017.5 6h-11A1.5 1.5 0 005 7.5v2z"/>
  <path fill-rule="evenodd" clip-rule="evenodd" d="M16 22a6 6 0 100-12 6 6 0 000 12zm.75-9a.75.75 0 00-1.5 0v3.25c0 .2.08.39.22.53l2 2a.75.75 0 101.06-1.06l-1.78-1.78V13z"/>
</svg>
''';

  // 3. Instagram Camera Glyph (Solid rounded squircle with lens and flash cutout)
  static const String solidRoundedInstagramSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <path fill-rule="evenodd" clip-rule="evenodd" d="M7.5 2C4.462 2 2 4.462 2 7.5v9C2 19.538 4.462 22 7.5 22h9c3.038 0 5.5-2.462 5.5-5.5v-9C22 4.462 19.538 2 16.5 2h-9zm9.5 4.5a1.25 1.25 0 11-2.5 0 1.25 1.25 0 012.5 0zM12 7a5 5 0 100 10 5 5 0 000-10zm0 2.2a2.8 2.8 0 110 5.6 2.8 2.8 0 010-5.6z"/>
</svg>
''';

  /// Top navigation bar silhouette icon
  static Widget solidUserGroup({
    double size = 22,
    Color color = Colors.white,
  }) {
    return SvgPicture.string(
      solidStandardUserGroup02Svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Dock calendar icon
  static Widget solidCalendarClock({
    double size = 22,
    Color color = Colors.white,
  }) {
    return SvgPicture.string(
      solidRoundedCalendarClockSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Dock Instagram camera icon
  static Widget solidInstagram({
    double size = 22,
    Color color = Colors.white,
  }) {
    return SvgPicture.string(
      solidRoundedInstagramSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// Generic Solid Icon Widget
enum SolidHugeIconType {
  userGroup,
  calendarClock,
  instagram,
}

class SolidHugeIcon extends StatelessWidget {
  final SolidHugeIconType icon;
  final double size;
  final Color color;

  const SolidHugeIcon({
    super.key,
    required this.icon,
    this.size = 22,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    switch (icon) {
      case SolidHugeIconType.userGroup:
        return AppHugeIcons.solidUserGroup(size: size, color: color);
      case SolidHugeIconType.calendarClock:
        return AppHugeIcons.solidCalendarClock(size: size, color: color);
      case SolidHugeIconType.instagram:
        return AppHugeIcons.solidInstagram(size: size, color: color);
    }
  }
}

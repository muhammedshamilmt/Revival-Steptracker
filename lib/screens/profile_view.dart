import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/bold_rounded_icons.dart';

/// Shows the 95% height Profile Modal Sheet with slide-up animation & ambient background blur
Future<void> showProfileModal(BuildContext context) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (context) {
      return Stack(
        children: [
          // Ambient background blur over the underlying page
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: const SizedBox.expand(),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: ProfileModalSheet(),
          ),
        ],
      );
    },
  );
}

class ProfileModalSheet extends StatefulWidget {
  const ProfileModalSheet({super.key});

  @override
  State<ProfileModalSheet> createState() => _ProfileModalSheetState();
}

class _ProfileModalSheetState extends State<ProfileModalSheet> {
  String _vibeName = 'kannapi';
  String _age = '25';

  String get _inviteLink => 'inviteeveryday....&user=$_vibeName';
  String get _fullInviteUrl => 'https://inviteeveryday.com/?user=$_vibeName';

  void _copyInviteLink() {
    Clipboard.setData(ClipboardData(text: _fullInviteUrl));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF222329),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        duration: const Duration(milliseconds: 1800),
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.checkmark_alt,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Invite link copied to clipboard',
              style: AppTypography.base.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String title) async {
    HapticFeedback.lightImpact();
    if (title == 'Age') {
      final newAge = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        builder: (context) => UpdateAgeModalSheet(initialAge: _age),
      );
      if (newAge != null && newAge.isNotEmpty && mounted) {
        setState(() => _age = newAge);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF222329),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              duration: const Duration(milliseconds: 1600),
              content: Text(
                'Age updated to $newAge',
                style: AppTypography.base.copyWith(color: Colors.white),
              ),
            ),
          );
      }
      return;
    }

    if (title == 'Vibe name') {
      final newName = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        builder: (context) =>
            PickVibeNameModalSheet(initialVibeName: _vibeName),
      );
      if (newName != null && newName.isNotEmpty && mounted) {
        setState(() => _vibeName = newName);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF222329),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              duration: const Duration(milliseconds: 1600),
              content: Text(
                'Vibe name updated to $newName',
                style: AppTypography.base.copyWith(color: Colors.white),
              ),
            ),
          );
      }
      return;
    }

    if (title == 'Feedback for us') {
      final submitted = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        builder: (context) => const FeedbackModalSheet(),
      );
      if (submitted == true && mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF222329),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              duration: const Duration(milliseconds: 1800),
              content: Row(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_alt,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Thank you for your feedback!',
                    style: AppTypography.base.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
      }
      return;
    }

    if (title == 'Log out') {
      _showLogoutDialog();
      return;
    }
    if (title == 'Delete account') {
      _showDeleteAccountDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF222329),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        duration: const Duration(milliseconds: 1400),
        content: Text(
          '$title tapped',
          style: AppTypography.base.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Log out',
          style: AppTypography.base.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: AppTypography.base.copyWith(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Log out'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Delete account',
          style: AppTypography.base.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'This action is irreversible and will delete all your runs and history.',
          style: AppTypography.base.copyWith(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exactly 90% of total screen height as requested
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.92;

    return Container(
      height: modalHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        // Authentic sleek dark background gradient matching media_1794824598236_af06d678.png (#16161A -> #0E0E0E)
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF16161A), // Subtle charcoal highlight at top edge
            Color(0xFF111114), // Deep charcoal
            Color(0xFF0E0E0E), // Sleek obsidian black #0E0E0E
            Color(0xFF0E0E0E),
          ],
          stops: [0.0, 0.15, 0.45, 1.0],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
        // Specular top highlight edge
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.16),
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            spreadRadius: 8,
            offset: Offset(0, -6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Watermark using assets/images/vector-white.svg
          Positioned(
            top: -20,
            left: -20,
            right: -20,
            height: 380,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.07,
                child: SvgPicture.asset(
                  'assets/images/vector-white.svg',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Top Specular Glass Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(38),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.015),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable Profile Content
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 60, // Clears top X button & drag handle
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // 1. Glowing Sunset Gradient Ring Profile Avatar ("K")
                  _buildProfileAvatarRing(),

                  const SizedBox(height: 18),

                  // 2. Profile Username
                  Text(
                    _vibeName,
                    style: AppTypography.base.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 3. Invite Link & Copy Button: "inviteeveryday....&user=kannapi [copy]"
                  _buildInviteLinkRow(),

                  const SizedBox(height: 34),

                  // 4. Settings & Action List with Dotted Dividers
                  _buildSettingsSection(),
                ],
              ),
            ),
          ),

          // Top Center Drag Handle Pill (matching close-up crop)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF585960),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Top Left Frosted Glass 'X' Close Button (matching close-up crop)
          Positioned(top: 18, left: 18, child: _buildCloseButton()),
        ],
      ),
    );
  }

  /// Frosted glass circular 'X' close button
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2C2D33).withValues(alpha: 0.72),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: BoldCloseIcon(size: 16, strokeWidth: 2.8),
            ),
          ),
        ),
      ),
    );
  }

  /// Circular Profile Avatar with multi-stop neon sunset gradient ring
  Widget _buildProfileAvatarRing() {
    return Container(
      width: 122,
      height: 122,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradient Ring: Pink -> Coral -> Warm Orange -> Peach
        gradient: SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: math.pi * 2,
          colors: const [
            Color(0xFFFF2E93), // vibrant neon pink
            Color(0xFFFF4558), // bright coral red
            Color(0xFFFF8C38), // warm sunset orange
            Color(0xFFFFA726), // peach amber
            Color(0xFFFF2E93), // loop back to pink
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2E93).withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Ring thickness
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF27282E), // Dark charcoal circle inside
          ),
          child: Center(
            child: Text(
              'K',
              style: AppTypography.base.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD6D7DC),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Invite Link row with copy icon and tap-to-copy
  Widget _buildInviteLinkRow() {
    return GestureDetector(
      onTap: _copyInviteLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _inviteLink,
              style: AppTypography.base.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF86868B),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.doc_on_doc,
              size: 14,
              color: Color(0xFF86868B),
            ),
          ],
        ),
      ),
    );
  }

  /// Settings and Action List with Dotted Dividers
  Widget _buildSettingsSection() {
    final items = [
      _ProfileItemData(
        icon: CupertinoIcons.calendar,
        title: 'Age',
        trailingText: _age,
      ),
      _ProfileItemData(
        icon: Icons.accessibility_new_rounded,
        title: 'Vibe name',
        showChevron: true,
      ),
      _ProfileItemData(
        icon: CupertinoIcons.eye,
        title: 'Terms of Service',
        showChevron: true,
      ),
      _ProfileItemData(
        icon: CupertinoIcons.eye,
        title: 'Privacy Policy',
        showChevron: true,
      ),
      _ProfileItemData(
        icon: CupertinoIcons.chat_bubble_2,
        title: 'Feedback for us',
        showChevron: true,
      ),
      _ProfileItemData(
        icon: CupertinoIcons.trash,
        title: 'Delete account',
        showChevron: true,
      ),
      _ProfileItemData(
        icon: CupertinoIcons.power,
        title: 'Log out',
        showChevron: true,
        isDestructive: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: items.map((item) {
          return Column(
            children: [
              _buildProfileRow(item),
              // Subtle dotted divider matching the screenshot
              const SizedBox(height: 12),
              const CustomPaint(
                size: Size(double.infinity, 1),
                painter: _DottedDividerPainter(color: Color(0x1FFFFFFF)),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileRow(_ProfileItemData item) {
    final textColor = Colors.white;
    final iconColor = const Color(0xFF8E8F96);
    final chevronColor = const Color(0xFF6E6E73);

    return InkWell(
      onTap: () => _handleAction(item.title),
      borderRadius: BorderRadius.circular(12),
      splashColor: (item.isDestructive ? AppColors.primary : Colors.white)
          .withValues(alpha: 0.08),
      highlightColor: (item.isDestructive ? AppColors.primary : Colors.white)
          .withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Row(
          children: [
            // Left icon
            SizedBox(
              width: 28,
              height: 28,
              child: Center(child: Icon(item.icon, size: 20, color: iconColor)),
            ),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                item.title,
                style: AppTypography.base.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),

            // Trailing text (e.g. "25" for Age)
            if (item.trailingText != null) ...[
              Text(
                item.trailingText!,
                style: AppTypography.base.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF86868B),
                ),
              ),
              const SizedBox(width: 4),
            ],

            // Trailing chevron
            if (item.showChevron)
              BoldChevronRightIcon(
                size: 14,
                color: chevronColor,
                strokeWidth: 2.4,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItemData {
  final IconData icon;
  final String title;
  final String? trailingText;
  final bool showChevron;
  final bool isDestructive;

  const _ProfileItemData({
    required this.icon,
    required this.title,
    this.trailingText,
    this.showChevron = false,
    this.isDestructive = false,
  });
}

/// Dotted Divider Painter for separating profile items
class _DottedDividerPainter extends CustomPainter {
  final Color color;

  const _DottedDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const dashWidth = 3.0;
    const dashSpace = 4.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Standalone Full-Screen Profile View that reuses the exact same layout
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D11),
      body: SafeArea(child: ProfileModalSheet()),
    );
  }
}

// ============================================================================
// 1. Glowing Orb Widget (Matching all 3 reference screenshots)
// ============================================================================
Widget _buildGlowingTopOrb() {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFB021A2), // Neon violet magenta
          Color(0xFFE03BB8), // Neon bright hot pink
          Color(0xFFFF92CF), // Soft rose pink
          Color(0xFFFFF2EB), // Glowing soft peach white
        ],
        stops: [0.0, 0.40, 0.75, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFE03BB8).withValues(alpha: 0.5),
          blurRadius: 18,
          spreadRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
    ),
  );
}

// ============================================================================
// 2. Shared Modal Scaffold (92% height, top specular blur, vector watermark)
// ============================================================================
Widget _buildModalScaffold({
  required BuildContext context,
  required Widget child,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  final modalHeight = screenHeight * 0.92;

  return Stack(
    children: [
      // Ambient background blur
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: const SizedBox.expand(),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: modalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF16161A),
                Color(0xFF111114),
                Color(0xFF0E0E0E),
                Color(0xFF0E0E0E),
              ],
              stops: [0.0, 0.15, 0.45, 1.0],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1.0,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                spreadRadius: 8,
                offset: Offset(0, -6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Vector watermark
              Positioned(
                top: -20,
                left: -20,
                right: -20,
                height: 380,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.07,
                    child: SvgPicture.asset(
                      'assets/images/vector-white.svg',
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Specular glass highlight overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(38),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.015),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Sheet content
              Positioned.fill(child: child),

              // Top drag handle
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF585960),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Frosted Close Button ('X')
              Positioned(
                top: 18,
                left: 18,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF2C2D33,
                          ).withValues(alpha: 0.72),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: BoldCloseIcon(
                            size: 16,
                            strokeWidth: 2.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ============================================================================
// 3. Pick Your Vibe Name Modal Sheet (Matching Image 1)
// ============================================================================
class PickVibeNameModalSheet extends StatefulWidget {
  final String initialVibeName;
  const PickVibeNameModalSheet({super.key, required this.initialVibeName});

  @override
  State<PickVibeNameModalSheet> createState() => _PickVibeNameModalSheetState();
}

class _PickVibeNameModalSheetState extends State<PickVibeNameModalSheet> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialVibeName);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: _buildModalScaffold(
        context: context,
        child: Padding(
          padding: EdgeInsets.only(
            top: 56,
            bottom: math.max(36.0, bottomInset + 16.0),
            left: 24,
            right: 24,
          ),
          child: Column(
            children: [
              // Top Orb
              _buildGlowingTopOrb(),
              const SizedBox(height: 14),

              // Title
              Text(
                'Pick your vibe name',
                style: AppTypography.base.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'This is how people will see you.',
                style: AppTypography.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8E8F96),
                  letterSpacing: -0.1,
                ),
              ),

              const Spacer(),

              // Central Editable Vibe Name (Click to focus & show native system keyboard)
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                style: AppTypography.base.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                cursorColor: Colors.white,
                cursorWidth: 2.5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'kannapi',
                  hintStyle: AppTypography.base.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF45454C),
                    letterSpacing: -0.5,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const Spacer(),

              // Update Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  final text = _controller.text.trim();
                  Navigator.of(
                    context,
                  ).pop(text.isEmpty ? widget.initialVibeName : text);
                },
                child: Container(
                  width: 130,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Update',
                      style: AppTypography.base.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. Feedback For Us Modal Sheet (Matching Image 2)
// ============================================================================
class FeedbackModalSheet extends StatefulWidget {
  const FeedbackModalSheet({super.key});

  @override
  State<FeedbackModalSheet> createState() => _FeedbackModalSheetState();
}

class _FeedbackModalSheetState extends State<FeedbackModalSheet> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final hasContent = _controller.text.trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: _buildModalScaffold(
        context: context,
        child: Padding(
          padding: EdgeInsets.only(
            top: 56,
            bottom: math.max(36.0, bottomInset + 16.0),
            left: 24,
            right: 24,
          ),
          child: Column(
            children: [
              // Top Orb
              _buildGlowingTopOrb(),
              const SizedBox(height: 14),

              // Title
              Text(
                'Feedback for us',
                style: AppTypography.base.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Help us make Everyday better',
                style: AppTypography.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8E8F96),
                  letterSpacing: -0.1,
                ),
              ),

              const Spacer(),

              // Central Editable Feedback Input (Click to focus & show native system keyboard)
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: AppTypography.base.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
                cursorColor: Colors.white,
                cursorWidth: 2.5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Say anything...',
                  hintStyle: AppTypography.base.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF45454C),
                    letterSpacing: -0.4,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const Spacer(),

              // Submit Button
              GestureDetector(
                onTap: () {
                  if (_controller.text.trim().isEmpty) return;
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                },
                child: Container(
                  width: 130,
                  height: 56,
                  decoration: BoxDecoration(
                    color: hasContent ? Colors.white : const Color(0xFF38383E),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: hasContent
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: AppTypography.base.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: hasContent
                            ? Colors.black
                            : const Color(0xFF6E6E73),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. Update Your Age Modal Sheet (Matching Image 3)
// ============================================================================
class UpdateAgeModalSheet extends StatefulWidget {
  final String initialAge;
  const UpdateAgeModalSheet({super.key, required this.initialAge});

  @override
  State<UpdateAgeModalSheet> createState() => _UpdateAgeModalSheetState();
}

class _UpdateAgeModalSheetState extends State<UpdateAgeModalSheet> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAge);
    _focusNode = FocusNode();
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: _buildModalScaffold(
        context: context,
        child: Padding(
          padding: EdgeInsets.only(
            top: 56,
            bottom: math.max(36.0, bottomInset + 16.0),
            left: 24,
            right: 24,
          ),
          child: Column(
            children: [
              // Top Orb
              _buildGlowingTopOrb(),
              const SizedBox(height: 14),

              // Title
              Text(
                'Update your age',
                style: AppTypography.base.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Helps us make things feel more you.\nYour age stays private.',
                textAlign: TextAlign.center,
                style: AppTypography.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8E8F96),
                  height: 1.3,
                  letterSpacing: -0.1,
                ),
              ),

              const Spacer(),

              // Central Age Input with Blue Cursor (Click to focus & show native numeric keyboard)
              IntrinsicWidth(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTypography.base.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  cursorColor: const Color(0xFF2979FF),
                  cursorWidth: 2.5,
                  cursorRadius: const Radius.circular(1.5),
                  showCursor: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(height: 24),

              // Update Button directly below Age as shown in reference image
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  final text = _controller.text.trim();
                  Navigator.of(context).pop(text.isEmpty ? '25' : text);
                },
                child: Container(
                  width: 130,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Update',
                      style: AppTypography.base.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/bold_rounded_icons.dart';

/// Shows the 92% height Invite Friends Modal Sheet with smooth slide-up animation & ambient blur
Future<void> showInviteModal(
  BuildContext context, {
  String username = 'kannapi',
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (context) => InviteFriendsModalSheet(username: username),
  );
}

/// Pixel-accurate Invite Friends Modal Sheet matching the reference design
class InviteFriendsModalSheet extends StatefulWidget {
  final String username;
  const InviteFriendsModalSheet({super.key, this.username = 'kannapi'});

  @override
  State<InviteFriendsModalSheet> createState() =>
      _InviteFriendsModalSheetState();
}

class _InviteFriendsModalSheetState extends State<InviteFriendsModalSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String get _displayLink => 'inviteeveryday.net...2C&user=${widget.username}';
  String get _fullInviteUrl =>
      'https://inviteeveryday.net/?code=2C&user=${widget.username}';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _copyLink() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _fullInviteUrl));
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
          content: Row(
            children: [
              const BoldCheckmarkIcon(
                color: AppColors.primary,
                size: 18,
                strokeWidth: 3.2,
              ),
              const SizedBox(width: 10),
              Text(
                'Link copied to clipboard!',
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

  void _sendToFriends() {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: _fullInviteUrl));
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
              const BoldShareIcon(
                color: AppColors.primary,
                size: 18,
                strokeWidth: 2.6,
              ),
              const SizedBox(width: 10),
              Text(
                'Invite link ready to share!',
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.92;

    return Stack(
      children: [
        // Ambient background blur over the underlying page
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: const SizedBox.expand(),
          ),
        ),

        // Bottom Sheet Scaffold
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
                  Color(0xFF16161A), // Top charcoal highlight
                  Color(0xFF111114), // Subtle dark middle
                  Color(0xFF0E0E0E), // Pitch dark bottom
                  Color(0xFF0E0E0E),
                ],
                stops: [0.0, 0.15, 0.45, 1.0],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(38),
              ),
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
                // Background Vector Watermark
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

                // Top Specular Highlight Gradient Overlay
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

                // Main Content
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 88,
                          left: 24,
                          right: 24,
                          bottom: 36,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Headline Text:
                            // "Now go make some"
                            // "🔔 📍 ☕ miles together"
                            RichText(
                              text: TextSpan(
                                style: AppTypography.base.copyWith(
                                  fontSize: 27,
                                  height: 1.25,
                                  letterSpacing: -0.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Now go ',
                                    style: TextStyle(
                                      color: Color(0xFF8E8F96),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'make ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'some\n',
                                    style: TextStyle(
                                      color: Color(0xFF8E8F96),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 1.0),
                                      child: Image.asset(
                                        'assets/images/emoji/bell.png',
                                        width: 26,
                                        height: 26,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 2.0),
                                      child: Image.asset(
                                        'assets/images/emoji/locaiton.png',
                                        width: 26,
                                        height: 26,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 2.5),
                                      child: Image.asset(
                                        'assets/images/cards/coffee.png',
                                        width: 26,
                                        height: 26,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'miles together',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 38),

                            // Invite Friends Row (Icon + Label)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 17,
                                  color: Color(0xFF8E8F96),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Invite Friends',
                                  style: AppTypography.base.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF8E8F96),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Invite Link Pill Container (Tap to copy)
                            GestureDetector(
                              onTap: _copyLink,
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1B1F),
                                  borderRadius: BorderRadius.circular(27),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _displayLink,
                                        style: AppTypography.base.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      CupertinoIcons.doc_on_doc,
                                      size: 18,
                                      color: Color(0xFF8E8F96),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Send to Friends Button (White Stadium Pill)
                            GestureDetector(
                              onTap: _sendToFriends,
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Send to friends',
                                    style: AppTypography.base.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
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
                  ),
                ),

                // Top Drag Handle Pill
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

                // Top-Left Frosted Glass 'X' Close Button
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
                            child: BoldCloseIcon(size: 16, strokeWidth: 2.8),
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
}

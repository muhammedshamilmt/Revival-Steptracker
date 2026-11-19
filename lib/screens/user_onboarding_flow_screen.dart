import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_typography.dart';
import '../widgets/bold_rounded_icons.dart';
import 'activity_tracker_screen.dart';

class HeardOption {
  final String label;
  final String? svgAsset;
  final IconData? icon;

  const HeardOption({
    required this.label,
    this.svgAsset,
    this.icon,
  });
}

/// 3-Step User Onboarding Flow:
/// 1. Pick your vibe name
/// 2. How old are you? (Age)
/// 3. Where you heard about us (TikTok, Instagram, App Store, Twitter, YouTube, etc.)
class UserOnboardingFlowScreen extends StatefulWidget {
  final String initialVibeName;
  final String initialAge;

  const UserOnboardingFlowScreen({
    super.key,
    this.initialVibeName = 'kannapi',
    this.initialAge = '25',
  });

  @override
  State<UserOnboardingFlowScreen> createState() =>
      _UserOnboardingFlowScreenState();
}

class _UserOnboardingFlowScreenState extends State<UserOnboardingFlowScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Step 1: Vibe Name
  late final TextEditingController _vibeNameController;
  late final FocusNode _vibeNameFocusNode;

  // Step 2: Age
  late final TextEditingController _ageController;
  late final FocusNode _ageFocusNode;

  // Step 3: Where heard about us
  String _selectedHeardSource = 'Instagram';
  late final TextEditingController _customSourceController;
  late final FocusNode _customSourceFocusNode;

  final List<HeardOption> _heardOptions = const [
    HeardOption(
      label: 'TikTok',
      svgAsset: 'assets/images/tiktok.svg',
    ),
    HeardOption(
      label: 'Instagram',
      svgAsset: 'assets/images/instagram.svg',
    ),
    HeardOption(
      label: 'App Store',
      svgAsset: 'assets/images/appstore.svg',
    ),
    HeardOption(
      label: 'X (Twitter)',
      svgAsset: 'assets/images/twitter.svg',
    ),
    HeardOption(
      label: 'YouTube',
      svgAsset: 'assets/images/youtube.svg',
    ),
    HeardOption(
      label: 'Friends & Family',
      icon: Icons.people_alt_rounded,
    ),
    HeardOption(
      label: 'Other',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _vibeNameController = TextEditingController(text: widget.initialVibeName);
    _vibeNameFocusNode = FocusNode();

    _ageController = TextEditingController(text: widget.initialAge);
    _ageFocusNode = FocusNode();
    _ageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _ageController.text.length),
    );

    _customSourceController = TextEditingController();
    _customSourceFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _vibeNameController.dispose();
    _vibeNameFocusNode.dispose();
    _ageController.dispose();
    _ageFocusNode.dispose();
    _customSourceController.dispose();
    _customSourceFocusNode.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _goToPreviousPage() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleCloseOrBack() {
    if (_currentPage > 0) {
      _goToPreviousPage();
    } else {
      HapticFeedback.lightImpact();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        _finishOnboarding();
      }
    }
  }

  void _finishOnboarding() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ActivityTrackerScreen(showOnboardingOnLaunch: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.92;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Ambient top atmospheric aura
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.6),
                    radius: 1.2,
                    colors: [
                      const Color(0xFFD926B8).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Modal Sheet Scaffold (coming from bottom, matching reference screenshot)
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
                    // Vector watermark in background
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

                    // Specular highlight at top curve
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

                    // PageView Content
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 56,
                          bottom: math.max(36.0, bottomInset + 16.0),
                          left: 24,
                          right: 24,
                        ),
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          children: [
                            _buildVibeNamePage(),
                            _buildAgePage(),
                            _buildHeardAboutUsPage(),
                          ],
                        ),
                      ),
                    ),

                    // Top drag pill handle
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

                    // Frosted Close / Back Button
                    Positioned(
                      top: 18,
                      left: 18,
                      child: GestureDetector(
                        onTap: _handleCloseOrBack,
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
                              child: Center(
                                child: _currentPage > 0
                                    ? const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : const BoldCloseIcon(
                                        size: 16,
                                        strokeWidth: 2.8,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Step Indicator dots (Subtle top right)
                    Positioned(
                      top: 26,
                      right: 24,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            margin: const EdgeInsets.only(left: 6),
                            width: isActive ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // GLOWING TOP ORB (Identical to reference screenshot)
  // ===========================================================================
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

  // ===========================================================================
  // STEP 1: PICK YOUR VIBE NAME
  // ===========================================================================
  Widget _buildVibeNamePage() {
    return Column(
      children: [
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

        // Central Editable Vibe Name
        TextField(
          controller: _vibeNameController,
          focusNode: _vibeNameFocusNode,
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
        ),

        const Spacer(),

        // Action Button
        _buildPillButton(
          label: 'Next',
          onTap: _goToNextPage,
        ),
      ],
    );
  }

  // ===========================================================================
  // STEP 2: HOW OLD ARE YOU? (AGE)
  // ===========================================================================
  Widget _buildAgePage() {
    return Column(
      children: [
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

        // Central Editable Age Input
        IntrinsicWidth(
          child: TextField(
            controller: _ageController,
            focusNode: _ageFocusNode,
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
          ),
        ),

        const SizedBox(height: 24),

        // Action Button
        _buildPillButton(
          label: 'Next',
          onTap: _goToNextPage,
        ),

        const Spacer(),
      ],
    );
  }

  // ===========================================================================
  // STEP 3: WHERE DID YOU HEAR ABOUT US?
  // ===========================================================================
  Widget _buildHeardAboutUsPage() {
    return Column(
      children: [
        _buildGlowingTopOrb(),
        const SizedBox(height: 14),

        // Title
        Text(
          'Where you heard about us',
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
          'Help us understand how you discovered RevivalStep.',
          textAlign: TextAlign.center,
          style: AppTypography.base.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8E8F96),
            letterSpacing: -0.1,
          ),
        ),

        const SizedBox(height: 18),

        // Options Selection List with Custom SVGs
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ..._heardOptions.map((option) {
                  final isSelected = _selectedHeardSource == option.label;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedHeardSource = option.label;
                        });
                        if (option.label == 'Other') {
                          _customSourceFocusNode.requestFocus();
                        } else {
                          _customSourceFocusNode.unfocus();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF202127).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.08),
                            width: isSelected ? 1.4 : 0.8,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // SVG / Icon Badge
                            _buildOptionIcon(option, isSelected),
                            const SizedBox(width: 14),

                            // Label
                            Expanded(
                              child: Text(
                                option.label,
                                style: AppTypography.base.copyWith(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            // Selected Checkmark Badge
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Optional "Other" input field
                if (_selectedHeardSource == 'Other')
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1C22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE03BB8).withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _customSourceController,
                        focusNode: _customSourceFocusNode,
                        style: AppTypography.base.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        cursorColor: const Color(0xFFE03BB8),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Where did you find us?',
                          hintStyle: AppTypography.base.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6E6F78),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Action Button
        _buildPillButton(
          label: 'Done',
          onTap: _finishOnboarding,
        ),
      ],
    );
  }

  Widget _buildOptionIcon(HeardOption option, bool isSelected) {
    if (option.svgAsset != null) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16161A) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        padding: isSelected ? const EdgeInsets.all(3.5) : EdgeInsets.zero,
        child: Center(
          child: SvgPicture.asset(
            option.svgAsset!,
            width: isSelected ? 20 : 22,
            height: isSelected ? 20 : 22,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      child: Icon(
        option.icon ?? Icons.circle,
        size: 20,
        color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  // ===========================================================================
  // REUSABLE WHITE PILL BUTTON (Matching screenshot)
  // ===========================================================================
  Widget _buildPillButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.base.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

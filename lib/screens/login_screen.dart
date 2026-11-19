import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_typography.dart';
import 'user_onboarding_flow_screen.dart';

/// Redesigned Login Screen:
/// - Top-to-bottom red-to-black gradient covering the entire screen
/// - No separate card widget: buttons sit directly on the gradient's bottom black section
/// - Upper area: Center Hero Squircle Icon & "Now go make some miles together" headline
/// - Bottom section: High-contrast auth buttons ("Continue with Google" & "Continue with Apple")
///   and privacy disclaimer directly on the black base of the gradient
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _handleSocialLogin(String provider) {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserOnboardingFlowScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top-to-Bottom Gradient: Brand red covering ~60% of the screen, then transitioning into black
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF0050), // Vivid brand red
                    Color(0xFFFF0050), // Dominant rich brand red across top 40%
                    Color(0xFF8A002B), // Deep ruby at ~60%
                    Color.fromARGB(255, 28, 0, 9), // Transition dark wine
                    Color(0xFF000000), // Solid black base
                    Color(0xFF000000), // Solid black bottom section for buttons
                  ],
                  stops: [0.0, 0.38, 0.60, 0.78, 0.92, 1.0],
                ),
              ),
            ),
          ),

          // 2. Subtle Ribbon Watermark at Top
          Positioned(
            top: -40,
            left: -40,
            right: -40,
            height: 440,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.08,
                child: SvgPicture.asset(
                  'assets/images/vector-white.svg',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 3. Unified Content Flow on the Gradient (Squircle + Headline -> Buttons on bottom black)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Center Hero Squircle Icon with specular reflection
                  _buildSquircle(),

                  const SizedBox(height: 32),

                  // Headline: "Now go make some \n miles together"
                  _buildHeadline(),

                  const Spacer(flex: 4),

                  // Auth Buttons directly in the bottom black section of the gradient
                  _buildAuthButtons(),

                  const SizedBox(height: 20),

                  // Footer Terms & Privacy Policy
                  _buildDisclaimer(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clean Hero Squircle icon with radiant gradient and specular reflection
  Widget _buildSquircle() {
    return Center(
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.05,
            colors: [
              Color(0xFFE040FB), // bright neon violet center
              Color(0xFFAA00FF), // deep magenta
              Color(0xFFFF4081), // warm pink
              Color(0xFFFF8A80), // coral peach
              Color(0xFFFFE0B2), // soft peach highlight on bottom rim
            ],
            stops: [0.0, 0.40, 0.70, 0.88, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAA00FF).withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Inner top specular reflection
            Positioned(
              top: 2,
              left: 12,
              right: 12,
              height: 32,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Headline: "Now go make some \n miles together"
  Widget _buildHeadline() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTypography.loginHeadlineMuted,
        children: [
          const TextSpan(text: 'Now go '),
          TextSpan(text: 'make ', style: AppTypography.loginHeadlineBold),
          const TextSpan(text: 'some\n'),
          TextSpan(
            text: 'miles together',
            style: AppTypography.loginHeadlineBold,
          ),
        ],
      ),
    );
  }

  /// Auth Buttons Group: Primary White Button & Secondary Dark Button directly on the black gradient base
  Widget _buildAuthButtons() {
    return Column(
      children: [
        // Continue with Google Button
        _AuthButton(
          label: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          icon: SvgPicture.asset(
            'assets/images/google_logo.svg',
            width: 22,
            height: 22,
          ),
          onTap: () => _handleSocialLogin('Google'),
        ),

        const SizedBox(height: 14),

        // Continue with Apple Button
        _AuthButton(
          label: 'Continue with Apple',
          backgroundColor: const Color(0xFF141418),
          textColor: Colors.white,
          borderColor: Colors.white.withValues(alpha: 0.16),
          icon: SvgPicture.asset(
            'assets/images/apple_logo.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onTap: () => _handleSocialLogin('Apple'),
        ),
      ],
    );
  }

  /// Footer Terms & Privacy Policy
  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'By continuing, I agree to the terms\nand privacy policy.',
        textAlign: TextAlign.center,
        style: AppTypography.loginDisclaimer,
      ),
    );
  }
}

class _AuthButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Widget icon;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(28),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.0)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor == Colors.white
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.40),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: AppTypography.authButton.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

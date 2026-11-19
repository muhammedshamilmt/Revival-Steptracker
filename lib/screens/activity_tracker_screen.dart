import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/huge_icons.dart';
import 'profile_view.dart';
import 'invite_modal_sheet.dart';
import 'event_routine_screen.dart';
import 'onboarding_screen.dart';
import 'running_start_screen.dart';
import 'dashboard_screen.dart';

class ActivityTrackerScreen extends StatefulWidget {
  final bool showBackButton;
  final bool showOnboardingOnLaunch;

  const ActivityTrackerScreen({
    super.key,
    this.showBackButton = false,
    this.showOnboardingOnLaunch = false,
  });

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  String _selectedAudience = 'Everyone';
  bool _isTracking = false;
  int _secondsElapsed = 0;
  double _distanceKm = 0.00;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.showOnboardingOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openOnboardingFromBottom();
      });
    }
  }

  void _openOnboardingFromBottom() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openRunningStartScreen() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isTracking = true;
    });
    Navigator.of(context).push(RunningStartScreen.route());
  }

  void _toggleTracking() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsElapsed++;
            // Approximate walking pace ~ 5 km/h -> ~0.0014 km/sec
            _distanceKm += 0.0014;
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatMovingTime() {
    final minutes = (_secondsElapsed ~/ 60).toString();
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '${minutes}m ${seconds}s';
  }

  String _formatPace() {
    if (_distanceKm <= 0.005) return "0'00\"";
    final paceSeconds = (_secondsElapsed / _distanceKm).round();
    final pMin = paceSeconds ~/ 60;
    final pSec = (paceSeconds % 60).toString().padLeft(2, '0');
    return "$pMin'$pSec\"";
  }

  void _showAudienceSelector() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Who can see this activity?',
                  style: AppTypography.heroTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildAudienceOption('Everyone', Icons.public_rounded),
                _buildAudienceOption('Friends only', Icons.people_rounded),
                _buildAudienceOption(
                  'Just me (Private)',
                  Icons.lock_outline_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudienceOption(String title, IconData icon) {
    final isSelected = _selectedAudience == title;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.white70,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTypography.base.copyWith(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : Colors.white,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedAudience = title);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.redToBlackGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              _buildTopBar(),

              const SizedBox(height: 6),

              // Maximized Main Activity Card (Expanded to increase vertical height)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildMainActivityCard(),
                ),
              ),

              const SizedBox(height: 12),

              // User Badge Pill: "K kannapi"
              _buildUserPill(),

              const SizedBox(height: 16),

              // Bottom Action Controls [Calendar] [+ #FF0050] [Camera]
              _buildBottomControls(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Bar: Profile icon, Audience selector ("Everyone v"), Avatar Initial ("K")
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Two Silhouette People Icon (Solid Filled UserGroup02)
          GestureDetector(
            onTap: () {
              if (widget.showBackButton) {
                Navigator.of(context).pop();
              } else {
                showInviteModal(context);
              }
            },
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.centerLeft,
              child: widget.showBackButton
                  ? const Icon(
                      CupertinoIcons.chevron_back,
                      color: Colors.white,
                      size: 35,
                    )
                  : AppHugeIcons.solidUserGroup(color: Colors.white, size: 30),
            ),
          ),

          // Center: "Everyone v" Dropdown Selector
          GestureDetector(
            onTap: _showAudienceSelector,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedAudience,
                  style: AppTypography.base.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 14,
                ),
              ],
            ),
          ),

          // Right: Circular User Initial Avatar Badge ("K") - Opens Profile Modal
          GestureDetector(
            onTap: () => showProfileModal(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'K',
                  style: AppTypography.base.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Main Large Rounded Card with Increased Height and Metrics
  Widget _buildMainActivityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF261D24).withValues(alpha: 0.94),
            const Color(0xFF1B1C20).withValues(alpha: 0.95),
            const Color(0xFF141519).withValues(alpha: 0.98),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.circular(38),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          children: [
            // Background Ribbon Watermark (matching reference image, isolated with RepaintBoundary)
            Positioned(
              top: -20,
              left: -20,
              right: -20,
              height: 420,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: 0.07,
                    child: SvgPicture.asset(
                      'assets/images/vector-white.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Inner Content with responsive metrics alignment
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Status Pill Chip: "No runs yet, let's start" (matching media_1794824299980_5adfbcfa.png)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2B2C33,
                                  ).withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  _isTracking
                                      ? 'Tracking in progress...'
                                      : "No runs yet, let's start",
                                  style: AppTypography.base.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Metric 1: Distance (0.00 km)
                            _buildMetricGroup(
                              mainValue: _distanceKm.toStringAsFixed(2),
                              unit: 'km',
                              label: 'distance',
                            ),

                            const SizedBox(height: 18),

                            // Metric 2: Pace (0'00" mins)
                            _buildMetricGroup(
                              mainValue: _formatPace(),
                              unit: 'mins',
                              label: 'pace',
                            ),

                            const SizedBox(height: 18),

                            // Metric 3: Moving Time (0m 00s)
                            _buildMetricGroup(
                              mainValue: _formatMovingTime(),
                              unit: '',
                              label: 'moving time',
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Single metric row (Large number + unit, followed by lowercase label)
  Widget _buildMetricGroup({
    required String mainValue,
    required String unit,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              mainValue,
              style: AppTypography.base.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.05,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.base.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.base.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8E8F96),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  /// User Tag Pill ("K kannapi") - Glowing Gradient Stadium Capsule matching reference
  Widget _buildUserPill() {
    return GestureDetector(
      onTap: () => showProfileModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16171B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2B2C33),
              ),
              child: Center(
                child: Text(
                  'K',
                  style: AppTypography.base.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'kannapi',
              style: AppTypography.base.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Controls: [Calendar]  [+ (Radiant #FF0050 Glow)]  [Camera/Instagram]
  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left: Calendar Circle Button (Solid Filled CalendarClock)
        _buildCircularDockButton(
          child: AppHugeIcons.solidCalendarClock(color: Colors.white, size: 22),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const EventRoutineScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      final slideAnimation = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      );
                      final fadeAnimation = CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
                      );
                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(slideAnimation),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 360),
                reverseTransitionDuration: const Duration(milliseconds: 260),
              ),
            );
          },
        ),

        const SizedBox(width: 20),

        // Center: Big Radiant Red #FF0050 Action Button (+)
        _buildCenterStartButton(),

        const SizedBox(width: 20),

        // Right: Camera / Instagram Circle Button -> Opens DashboardScreen coming from bottom
        _buildCircularDockButton(
          child: AppHugeIcons.solidInstagram(color: Colors.white, size: 22),
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.of(context).push(DashboardScreen.route());
          },
        ),
      ],
    );
  }

  /// Small floating circular dock button
  Widget _buildCircularDockButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1B1C21),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  /// Center radiant #FF0050 Action Button (+)
  Widget _buildCenterStartButton() {
    return _PressableScale(
      onTap: _openRunningStartScreen,
      onLongPress: _toggleTracking,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Radiant Glow around the button using #FF0050
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 30,
                  spreadRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Main Button Circle with radiant gradient
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(0.0, -0.2),
                radius: 1.0,
                colors: [
                  Color(0xFFFF3373), // bright neon red
                  Color(0xFFFF0050), // brand red #FF0050
                  Color(0xFFD60043), // rich deep red
                  Color(0xFFFFB2C9), // soft peach-pink highlight rim
                ],
                stops: [0.0, 0.5, 0.85, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Center(
              child: AnimatedRotation(
                turns: _isTracking ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  _isTracking ? Icons.stop_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PressableScale({
    required this.child,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onLongPress: widget.onLongPress,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.92 : 1.0,
        child: widget.child,
      ),
    );
  }
}

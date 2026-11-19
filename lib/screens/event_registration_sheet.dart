import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/bold_rounded_icons.dart';
import 'event_routine_screen.dart';

/// Callback when registration is completed
typedef OnRegistrationComplete =
    void Function({
      required String fullName,
      required String email,
      required String phone,
      required String passTier,
      required String notes,
    });

/// Displays the step-by-step Event Registration Modal Sheet
/// matching the exact design reference from PickVibeNameModalSheet in profile_view.dart:
/// - Glowing Top Orb (Neon magenta/hot-pink gradient)
/// - Ambient background blur with dark obsidian scaffold
/// - 4 Steps:
///   1. Full Name (prefilled, editable large centered text field)
///   2. Attender Count (Count on TOP, Auto-Drag Magnetic Ruler Scroller UNDER the count
///      with exact center-aligned snapping, solid crisp center needle, NO glow, NO +/- icons)
///   3. Email Address (prefilled, editable centered text field)
///   4. Success Verification View (Brand red scalloped rosette seal matching media_1794970096550_fd60e9d1.png)
Future<void> showEventRegistrationSheet(
  BuildContext context, {
  required EventCardItem event,
  required DateTime selectedDate,
  required String currentName,
  required String currentPassTier,
  required OnRegistrationComplete onComplete,
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (context) {
      return EventRegistrationSheet(
        event: event,
        selectedDate: selectedDate,
        initialName: currentName,
        initialPassTier: currentPassTier,
        onComplete: onComplete,
      );
    },
  );
}

class EventRegistrationSheet extends StatefulWidget {
  final EventCardItem event;
  final DateTime selectedDate;
  final String initialName;
  final String initialPassTier;
  final OnRegistrationComplete onComplete;

  const EventRegistrationSheet({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.initialName,
    required this.initialPassTier,
    required this.onComplete,
  });

  @override
  State<EventRegistrationSheet> createState() => _EventRegistrationSheetState();
}

class _EventRegistrationSheetState extends State<EventRegistrationSheet> {
  // 0 = Full Name, 1 = Attender count, 2 = Email, 3 = Success View
  int _currentStep = 0;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late FocusNode _nameFocusNode;
  late FocusNode _emailFocusNode;

  // Ruler scrubber state for Step 2
  int _attendeeCount = 1;
  late ScrollController _rulerScrollController;
  static const double _stepWidth = 48.0;
  static const int _minCount = 1;
  static const int _totalUnits = 25; // Extended range for smooth scrolling

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(
      text:
          '${widget.initialName.toLowerCase().replaceAll(' ', '.')}@gmail.com',
    );
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();

    // Initialize ruler scroll controller centered on _attendeeCount = 1
    _rulerScrollController = ScrollController(
      initialScrollOffset: (_attendeeCount - _minCount) * _stepWidth,
    );
    _rulerScrollController.addListener(_onRulerScroll);
  }

  void _onRulerScroll() {
    if (!_rulerScrollController.hasClients) return;
    final offset = _rulerScrollController.offset;
    final newCount = ((offset / _stepWidth).round() + _minCount).clamp(
      _minCount,
      _totalUnits,
    );

    if (newCount != _attendeeCount) {
      HapticFeedback.selectionClick();
      setState(() {
        _attendeeCount = newCount;
      });
    }
  }

  void _scrollToCount(int count) {
    if (!_rulerScrollController.hasClients) return;
    final target = (count - _minCount) * _stepWidth;
    _rulerScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _rulerScrollController.removeListener(_onRulerScroll);
    _rulerScrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      if (_currentStep == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCount(_attendeeCount);
        });
      }
    } else if (_currentStep == 2) {
      // Transition to Success Step (Step 3) in the same widget
      _onSubmit();
    } else {
      // Done / View Ticket on Success Step
      Navigator.of(context).pop();
    }
  }

  void _onBack() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    if (_currentStep > 0 && _currentStep < 3) {
      setState(() {
        _currentStep--;
      });
      if (_currentStep == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCount(_attendeeCount);
        });
      }
    }
  }

  void _onSubmit() {
    HapticFeedback.heavyImpact();

    final finalName = _nameController.text.trim().isEmpty
        ? widget.initialName
        : _nameController.text.trim();
    final finalEmail = _emailController.text.trim().isEmpty
        ? '${widget.initialName.toLowerCase()}@gmail.com'
        : _emailController.text.trim();

    widget.onComplete(
      fullName: finalName,
      email: finalEmail,
      phone: '+1 (555) 782-9901',
      passTier: widget.initialPassTier.isNotEmpty
          ? widget.initialPassTier
          : 'VIP Access',
      notes: 'Attendees: $_attendeeCount',
    );

    // Transition smoothly to Success Step in the same widget
    setState(() {
      _currentStep = 3;
    });
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
              // 1. Glowing Top Orb (Neon magenta/hot-pink, changes to brand red on success)
              _buildGlowingTopOrb(),
              const SizedBox(height: 14),

              // 2. Step Indicator Dots / Capsules
              _buildStepIndicator(),
              const SizedBox(height: 12),

              // 3. Dynamic Title based on current step
              Text(
                _getStepTitle(),
                textAlign: TextAlign.center,
                style: AppTypography.base.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // 4. Dynamic Subtitle based on current step
              Text(
                _getStepSubtitle(),
                textAlign: TextAlign.center,
                style: AppTypography.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8E8F96),
                  letterSpacing: -0.1,
                ),
              ),

              const Spacer(),

              // 5. Central Input per Step (Switcher)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _buildStepCenterInput(),
              ),

              const Spacer(),

              // 6. Action Button Bar (Back + Continue / View Ticket)
              _buildStepActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Full Name';
      case 1:
        return 'Attender count';
      case 2:
        return 'Email address';
      case 3:
      default:
        return 'Pass Confirmed!';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'This is how people will see you.';
      case 1:
        return 'Scroll ruler to select attendee count.';
      case 2:
        return "Where we'll send your admission pass.";
      case 3:
      default:
        return 'Your reservation is complete.';
    }
  }

  /// Step Indicator with 4 sleek animated pills
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentStep;
        final isPassed = index < _currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: _currentStep == 3
                ? AppColors
                      .primary // Brand Red on success
                : isActive
                ? const Color(0xFFE03BB8)
                : isPassed
                ? Colors.white.withValues(alpha: 0.60)
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  /// Central Input for the current step
  Widget _buildStepCenterInput() {
    switch (_currentStep) {
      case 0:
        // Step 1: Full Name (Centered editable text field matching reference)
        return TextField(
          key: const ValueKey('step_fullname'),
          controller: _nameController,
          focusNode: _nameFocusNode,
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
        );

      case 1:
        // Step 2: Attender count (Count on TOP, Scroller UNDER the count, NO +/- buttons)
        return _buildCountTopRulerUnder();

      case 2:
        // Step 3: Email (Centered editable text field)
        return TextField(
          key: const ValueKey('step_email'),
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.center,
          style: AppTypography.base.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          cursorColor: Colors.white,
          cursorWidth: 2.5,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'user@example.com',
            hintStyle: AppTypography.base.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF45454C),
              letterSpacing: -0.3,
            ),
          ),
          onChanged: (_) => setState(() {}),
        );

      case 3:
      default:
        // Step 4: Success Verification View matching media_1794970096550_fd60e9d1.png in Brand Red
        return _buildScallopedSuccessView();
    }
  }

  /// Step 2: Count on TOP, Auto-Drag Magnetic Ruler Scroller UNDER the count
  /// (Exact center alignment, solid center line with NO glow, NO +/- buttons)
  Widget _buildCountTopRulerUnder() {
    return LayoutBuilder(
      key: const ValueKey('step_count_top_ruler_under'),
      builder: (context, constraints) {
        final rulerWidth = constraints.maxWidth;
        final halfWidth = rulerWidth / 2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Large Bold Count on TOP
            Text(
              '$_attendeeCount',
              style: AppTypography.base.copyWith(
                fontSize: 60,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.5,
              ),
            ),

            const SizedBox(height: 4),

            // Subtitle directly below count
            Text(
              _attendeeCount == 1
                  ? '1 Attendee Pass'
                  : '$_attendeeCount Attendee Passes',
              style: AppTypography.base.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8E8F96),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Horizontal Ruler Scroller UNDER the count with Auto-Drag Magnetic Physics
            SizedBox(
              height: 64,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Ruler Ticks with Edge Fade Gradient (ShaderMask)
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.22, 0.78, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          // Auto-drag magnetic snap directly into center
                          final offset = _rulerScrollController.offset;
                          final snapCount =
                              ((offset / _stepWidth).round() + _minCount).clamp(
                                _minCount,
                                _totalUnits,
                              );
                          final target = (snapCount - _minCount) * _stepWidth;
                          if ((offset - target).abs() > 0.4) {
                            _rulerScrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: _rulerScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: RulerSnapScrollPhysics(
                          step: _stepWidth,
                          parent: const BouncingScrollPhysics(),
                        ),
                        // Exact padding so item major line x=0 aligns mathematically with center
                        padding: EdgeInsets.symmetric(
                          horizontal: halfWidth - 1.2,
                        ),
                        itemCount: _totalUnits,
                        itemBuilder: (context, index) {
                          final count = index + _minCount;
                          final isSelected = count == _attendeeCount;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _scrollToCount(count);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: _stepWidth,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.centerLeft,
                                children: [
                                  // Major tick mark centered at x = 0 (merges seamlessly under center line)
                                  Positioned(
                                    left: 0,
                                    child: Container(
                                      width: 2.4,
                                      height: isSelected ? 34 : 22,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF6E707B),
                                        borderRadius: BorderRadius.circular(
                                          1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Minor sub-ticks across the interval
                                  Positioned(
                                    left: _stepWidth * 0.25,
                                    child: Container(
                                      width: 1.0,
                                      height: 12,
                                      color: const Color(0xFF40424A),
                                    ),
                                  ),
                                  Positioned(
                                    left: _stepWidth * 0.50,
                                    child: Container(
                                      width: 1.2,
                                      height: 16,
                                      color: const Color(0xFF50525C),
                                    ),
                                  ),
                                  Positioned(
                                    left: _stepWidth * 0.75,
                                    child: Container(
                                      width: 1.0,
                                      height: 12,
                                      color: const Color(0xFF40424A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Fixed Center Indicator Line (Crisp solid needle, NO GLOW as requested!)
                  Positioned(
                    top: 4,
                    bottom: 4,
                    child: IgnorePointer(
                      child: Container(
                        width: 2.4,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE03BB8,
                          ), // Crisp clean solid needle, NO glow!
                          borderRadius: BorderRadius.circular(1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Success Verification View in Brand Red matching media_1794970096550_fd60e9d1.png
  Widget _buildScallopedSuccessView() {
    final finalName = _nameController.text.trim().isEmpty
        ? widget.initialName
        : _nameController.text.trim();
    final finalEmail = _emailController.text.trim().isEmpty
        ? '${widget.initialName.toLowerCase()}@gmail.com'
        : _emailController.text.trim();

    return Column(
      key: const ValueKey('step_scalloped_success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Soft Red Halo with 8-Point Scalloped Rosette Seal Checkmark in Brand Red (#FF0050)
        // (Matching exact visual from media_1794970096550_fd60e9d1.png in our brand color)
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(
              alpha: 0.16,
            ), // Soft brand red halo
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scalloped square 1 (Brand Red #FF0050)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Scalloped square 2 rotated 45 degrees to form 8-point rosette
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                // Center bold rounded white checkmark
                const BoldCheckmarkIcon(
                  size: 26,
                  color: Colors.white,
                  strokeWidth: 3.6,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. Bold Title matching reference
        Text(
          'Registration Successful!',
          textAlign: TextAlign.center,
          style: AppTypography.base.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 6),

        // 3. Subtitle matching reference
        Text(
          'Your pass to "${widget.event.title.replaceAll('\n', ' ')}" is confirmed.',
          textAlign: TextAlign.center,
          style: AppTypography.base.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF8E8F96),
            letterSpacing: -0.1,
          ),
        ),

        const SizedBox(height: 22),

        // 4. Sleek Summary Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C29),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.ticket_fill,
                color: Color(0xFFD4F239),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '$_attendeeCount ${_attendeeCount == 1 ? 'Pass' : 'Passes'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$finalName • $finalEmail',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Action buttons at bottom: Back + Next/View Ticket button
  Widget _buildStepActionBar() {
    final isSuccessStep = _currentStep == 3;
    final isEmailStep = _currentStep == 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back circular button (visible on steps 1 and 2, hidden on success)
        if (_currentStep > 0 && !isSuccessStep) ...[
          GestureDetector(
            onTap: _onBack,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2C2D33).withValues(alpha: 0.72),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: BoldBackArrowIcon(size: 20, strokeWidth: 2.8),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],

        // Primary White Pill Action Button
        GestureDetector(
          onTap: _onNext,
          child: Container(
            width: isSuccessStep
                ? 150
                : isEmailStep
                ? 140
                : 130,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isSuccessStep
                    ? 'View Ticket'
                    : isEmailStep
                    ? 'Confirm'
                    : 'Continue',
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
    );
  }

  /// Glowing Top Orb matching profile_view.dart lines 746-773 (turns brand red on success)
  Widget _buildGlowingTopOrb() {
    final isSuccess = _currentStep == 3;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSuccess
              ? const [
                  Color(0xFF8A002B), // Deep brand crimson
                  Color(0xFFFF0050), // Vivid brand red
                  Color(0xFFFF4D79), // Soft rose red
                  Color(0xFFFFF0F3), // Soft glowing white
                ]
              : const [
                  Color(0xFFB021A2), // Neon violet magenta
                  Color(0xFFE03BB8), // Neon bright hot pink
                  Color(0xFFFF92CF), // Soft rose pink
                  Color(0xFFFFF2EB), // Glowing soft peach white
                ],
          stops: const [0.0, 0.40, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.primary : const Color(0xFFE03BB8))
                .withValues(alpha: 0.50),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Shared Modal Scaffold (92% height, top specular blur, vector watermark)
  Widget _buildModalScaffold({
    required BuildContext context,
    required Widget child,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.92;

    return Stack(
      children: [
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
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2C2D33).withValues(alpha: 0.88),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

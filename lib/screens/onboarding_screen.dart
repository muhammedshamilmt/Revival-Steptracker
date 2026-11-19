import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'login_screen.dart';

/// 6-Second Cinematic Onboarding Screen
/// - Plays 'assets/videos/onboarding.mp4' filling the viewport with BoxFit.cover
/// - Rich multi-stop bottom black gradient overlay (no red lighting)
/// - Centered typing animation for '@revivalSteps' starting at 4 seconds
/// - At 6 seconds (or upon tapping Skip): Navigates directly to LoginScreen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timelineController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;

  static const double _totalDurationSec = 6.0;
  static const double _revealAtSec = 4.0;
  static const double _typingDurationSec = 0.9;
  static const String _appName = '@revivalSteps';

  @override
  void initState() {
    super.initState();

    // 6-second timeline controller
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    _timelineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToLogin();
      }
    });

    _timelineController.forward();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/videos/onboarding.mp4',
      );
      _videoController = controller;
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _isVideoInitialized = true;
      });

      await controller.setLooping(false);
      await controller.setVolume(1.0);
      await controller.play();
    } catch (e) {
      // Graceful fallback for test runners or devices without video codec
      debugPrint('Video player initialization: $e');
    }
  }

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    try {
      _videoController?.pause();
    } catch (_) {}

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _timelineController,
        builder: (context, child) {
          final progress = _timelineController.value;
          final elapsedSeconds = progress * _totalDurationSec;

          // Typing animation calculation (starts at 4.0s, types across 0.9s)
          String visibleText = '';
          bool showCursor = false;

          if (elapsedSeconds >= _revealAtSec) {
            final typingProgress =
                ((elapsedSeconds - _revealAtSec) / _typingDurationSec).clamp(
                  0.0,
                  1.0,
                );
            final charCount = (typingProgress * _appName.length).round();
            visibleText = _appName.substring(0, charCount);

            // Blinking cursor while typing and briefly after
            final cursorPhase =
                ((elapsedSeconds - _revealAtSec) * 3.5).floor() % 2 == 0;
            showCursor =
                (typingProgress < 1.0 || elapsedSeconds < 5.6) && cursorPhase;
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Video Layer (Fitted to cover full screen)
              if (_isVideoInitialized && _videoController != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width > 0
                          ? _videoController!.value.size.width
                          : 720,
                      height: _videoController!.value.size.height > 0
                          ? _videoController!.value.size.height
                          : 1280,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              else
                Container(color: const Color(0xFF0C0C0E)),

              // 2. Cinematic Atmospheric Bottom Black Gradient Overlay (NO red lighting)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.20),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.90),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.16, 0.40, 0.62, 0.78, 0.92, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Centered Typing Animation for "@revivalSteps" (In the Middle, Clean White, No Red Glow)
              if (visibleText.isNotEmpty)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        visibleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      if (showCursor)
                        Container(
                          margin: const EdgeInsets.only(left: 3, top: 2),
                          width: 3.2,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black87,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

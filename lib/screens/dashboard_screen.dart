import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_typography.dart';
import '../widgets/bold_rounded_icons.dart';

/// DashboardScreen with Overview & Streak tabs, precisely matching the user's
/// uploaded reference images:
/// - Pure black borderless card styling (no stroke borders)
/// - Top date scrubber & tab switcher
/// - 13,143 Steps + 3 metric cards (Distance, Active Time, Calories)
/// - Daily Updates with Trainings / Statistic / Challenges
/// - The Two Cards Section (Time asleep 4h 18m, Sleep quality 54%)
/// - Placed directly AFTER the two cards section:
///   - Step Activity Heatmap Card (M, T, W, T, F, S, S with date range)
///   - 2x2 Big Metric Cards (Streak 8, Total Check-Ins 558, Avg. Log Time 2:50 PM, Goal Progress 67%)
///   - Health Improvement Score (82)
/// - Streak Tab cloned from reference design (media_1795095145167_d45fd168.jpg):
///   - Horizontal Daily Streak Scrubber (07 Thu ... 11 Mon active ... 15 Fri)
///   - Animated Circular Radial Ray Gauge with dynamic color transitions
///   - 14 Days / Current Streak / 13,143 Steps Today
///   - "Great Job, kannapi! ⭐" celebration banner
///   - Goals Achieved card with 6 gradient icon badges & +18.4% growth
///   - Streak With Friends & Daily Activity routines
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const DashboardScreen(),
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
    );
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedTopTab = 0; // 0 = Overview, 1 = Streak
  int _selectedSubTab = 1; // 0 = Trainings, 1 = Statistic, 2 = Challenges

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  // Streak Tab Animated Radial Gauge Controller
  late final AnimationController _radialGaugeController;
  late final Animation<double> _radialGaugeAnimation;

  // Daily Streak Scrubber (Matching Image 2: June, 2024 with MON 14 ... WED 15 active ... SUN 13)
  String _currentMonthYear = 'June, 2024';
  int _selectedStreakDayIndex = 2; // WED 15 (default active)

  final List<Map<String, dynamic>> _streakWeekDays = const [
    {
      'weekday': 'MON',
      'date': '14',
      'hasFire': true,
      'isBlue': false,
      'steps': '10,240',
    },
    {
      'weekday': 'TUE',
      'date': '16',
      'hasFire': true,
      'isBlue': true,
      'steps': '12,580',
    },
    {
      'weekday': 'WED',
      'date': '15',
      'hasFire': false,
      'isBlue': false,
      'steps': '11,479',
    },
    {
      'weekday': 'THU',
      'date': '17',
      'hasFire': false,
      'isBlue': false,
      'steps': '8,920',
    },
    {
      'weekday': 'FRI',
      'date': '18',
      'hasFire': false,
      'isBlue': false,
      'steps': '11,479',
    },
    {
      'weekday': 'SAT',
      'date': '19',
      'hasFire': false,
      'isBlue': false,
      'steps': '9,600',
    },
    {
      'weekday': 'SUN',
      'date': '13',
      'hasFire': false,
      'isBlue': false,
      'steps': '7,450',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();

    _radialGaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _radialGaugeAnimation = CurvedAnimation(
      parent: _radialGaugeController,
      curve: Curves.easeOutCubic,
    );
    _radialGaugeController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _radialGaugeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E0010), // Atmospheric deep red brand aura
              Color(0xFF16020A),
              Color(0xFF0C090D),
              Color(0xFF000000), // Smooth black gradient at bottom
            ],
            stops: [0.0, 0.25, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Single Row containing Close Button on left & [ Overview | Streak ] Tabs in center
              _buildTopHeaderWithTabs(),

              const SizedBox(height: 14),

              // Tab View Content with Bottom Black Gradient
              Expanded(
                child: Stack(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _selectedTopTab == 0
                          ? _buildOverviewTab()
                          : _buildStreakTab(),
                    ),

                    // Smooth black gradient fade at the bottom of the screen
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 56,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP HEADER: Close button and [ Overview | Streak ] Tabs in the SAME row
  // ===========================================================================
  Widget _buildTopHeaderWithTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center: Top Two Tabs [ Overview | Streak ] (Matching reference image)
          Center(child: _buildTopTabs()),

          // Left Close ('X') button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1D1E25).withValues(alpha: 0.8),
                    ),
                    child: const Center(
                      child: BoldCloseIcon(size: 15, strokeWidth: 2.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP TWO TABS: [ Overview | Streak ] (Matching reference image)
  // ===========================================================================
  Widget _buildTopTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C131A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopTabItem(label: 'Overview', index: 0),
          _buildTopTabItem(label: 'Streak', index: 1),
        ],
      ),
    );
  }

  Widget _buildTopTabItem({required String label, required int index}) {
    final isSelected = _selectedTopTab == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTopTab == index) return;
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTopTab = index;
        });
        _animController.reset();
        _animController.forward();
        if (index == 1) {
          _radialGaugeController.reset();
          _radialGaugeController.forward();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.base.copyWith(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? Colors.black
                  : Colors.white.withValues(alpha: 0.65),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // OVERVIEW TAB:
  // 1. Central Hero Step Counter (13,143 Steps)
  // 2. 3 Metrics row (Distance, Active Time, Calories)
  // 3. Daily Updates (Trainings/Statistic/Challenges)
  // 4. Two cards section (Time asleep & Sleep quality)
  // 5. AFTER the two cards section: Heatmap Card + 2x2 Metric Cards Grid
  // 6. Health Improvement Score
  // ===========================================================================
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 40),
      child: Column(
        children: [
          const SizedBox(height: 46),

          // 1. Central Hero Big Step Counter: 13,143 Steps
          RepaintBoundary(child: _buildBigStepCounter()),

          const SizedBox(height: 28),

          // 2. Three Metric Cards: Distance (6.7 km), Active Time (1h 12m), Calories (1277)
          _buildThreeMetricCards(),

          const SizedBox(height: 28),

          // 3. Daily Updates Section Header (Matching Image 1)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Daily Updates',
              style: AppTypography.base.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sub-tabs: [ Trainings | Statistic | Challenges ] (Matching Image 1)
          _buildDailyUpdatesSubTabs(),

          const SizedBox(height: 16),

          // 4. THE TWO CARDS SECTION (Time asleep 4h 18m, Sleep quality 54%)
          _buildTwoCardsSection(),

          const SizedBox(height: 28),

          // 5. PLACED DIRECTLY AFTER THE TWO CARDS SECTION:
          // A) Step Activity Heatmap Card (Matching Image 2 top section)
          RepaintBoundary(child: _buildStepActivityHeatmapCard()),

          const SizedBox(height: 12),

          // Sub-tabs: [ Trainings | Statistic | Challenges ] (Matching Image 1)
          _buildDailyUpdatesSubTabs(),

          const SizedBox(height: 16),

          // 4. THE TWO CARDS SECTION (Time asleep 4h 18m, Sleep quality 54%)
          _buildTwoCardsSection(),

          const SizedBox(height: 14),

          // B) 2x2 Big Metric Cards Grid (Matching Image 2: Streak 8, Check-Ins 558, Avg Time 2:50 PM, Goal Progress 67%)
          RepaintBoundary(child: _buildTwoByTwoMetricsGrid()),

          const SizedBox(height: 16),

          // 6. Health Improvement Score Card (Matching Image 1 bottom)
          _buildHealthScoreCard(),
        ],
      ),
    );
  }

  // ===========================================================================
  // CENTRAL BIG HERO STEP COUNTER (Increased size & bold presence)
  // ===========================================================================
  Widget _buildBigStepCounter() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient radial glow behind the steps number
        Container(
          width: 320,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFF0050).withValues(alpha: 0.26),
                Colors.transparent,
              ],
              radius: 0.85,
            ),
          ),
        ),

        // Steps display
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '13,143',
              style: AppTypography.base.copyWith(
                fontSize: 88,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -2.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Steps',
              style: AppTypography.base.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. THREE METRIC CARDS ROW (Distance 6.7 km, Active Time 1h 12m, Calories 1277)
  // ===========================================================================
  Widget _buildThreeMetricCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSingleStatCard(label: 'Distance', value: '6.7 km'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleStatCard(label: 'Active Time', value: '1h 12m'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleStatCard(label: 'Calories', value: '1277'),
        ),
      ],
    );
  }

  Widget _buildSingleStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: _borderlessDarkCardDecoration(),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.base.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8E8F96),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.base.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. DAILY UPDATES SUB-TABS: [ Trainings | Statistic | Challenges ]
  // ===========================================================================
  Widget _buildDailyUpdatesSubTabs() {
    final tabs = ['Trainings', 'Statistic', 'Challenges'];

    return Container(
      height: 42,
      width: double.infinity,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF13141B),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedSubTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedSubTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: AppTypography.base.copyWith(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.black
                          : Colors.white.withValues(alpha: 0.55),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // 5. THE TWO CARDS SECTION (Time asleep 4h 18m, Sleep quality 54%)
  // ===========================================================================
  Widget _buildTwoCardsSection() {
    return Row(
      children: [
        // Card 1: Time asleep (4h 18m)
        Expanded(
          child: _buildHealthMetricCard(
            title: 'Time asleep',
            value: '4h 18m',
            sliderProgress: 0.35,
            statusColor: const Color(0xFFFF5252),
            statusLabel: 'Low',
          ),
        ),
        const SizedBox(width: 12),

        // Card 2: Sleep quality (54%)
        Expanded(
          child: _buildHealthMetricCard(
            title: 'Sleep quality',
            value: '54%',
            sliderProgress: 0.65,
            statusColor: const Color(0xFF00E676),
            statusLabel: 'Normal',
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricCard({
    required String title,
    required String value,
    required double sliderProgress,
    required Color statusColor,
    required String statusLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _borderlessDarkCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.base.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8E8F96),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.base.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),

          // Gradient Slider Track with indicator arrow (Matching Image 1)
          _buildRangeSlider(sliderProgress),

          const SizedBox(height: 10),

          // Status indicator (dot + label)
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: AppTypography.base.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSlider(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              height: 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF262732),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            // Active Gradient segment (Matching Image 1 orange-to-blue gradient)
            FractionallySizedBox(
              widthFactor: progress.clamp(0.1, 1.0),
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9100),
                      Color(0xFFFF5252),
                      Color(0xFF2979FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: AppTypography.base.copyWith(
                fontSize: 10,
                color: const Color(0xFF6E6F78),
                fontWeight: FontWeight.w600,
              ),
            ),
            Transform.translate(
              offset: const Offset(-8, 0),
              child: const Icon(
                Icons.arrow_drop_up_rounded,
                size: 14,
                color: Color(0xFF8E8F96),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 6A. STEP ACTIVITY HEATMAP CARD (Matching Image 2 Top Section)
  // ===========================================================================
  Widget _buildStepActivityHeatmapCard() {
    // 7 rows: M, T, W, T, F, S, S (matching reference Image 2)
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Contribution intensity pattern matching Image 2
    final heatmapPattern = [
      [2, 3, 3, 2, 0, 1, 3, 0, 0, 3, 3, 0, 3, 0, 2, 3, 0, 3],
      [0, 3, 2, 0, 0, 3, 0, 1, 0, 3, 0, 0, 3, 3, 3, 1, 3, 3],
      [1, 0, 3, 0, 3, 0, 2, 0, 3, 3, 0, 2, 3, 0, 3, 3, 3, 0],
      [0, 2, 0, 3, 0, 0, 2, 0, 3, 3, 0, 3, 3, 0, 3, 3, 2, 0],
      [0, 3, 0, 0, 3, 0, 3, 3, 0, 3, 3, 0, 0, 2, 0, 3, 3, 0],
      [3, 3, 2, 0, 3, 0, 3, 0, 0, 3, 3, 3, 0, 2, 0, 3, 3, 0],
      [3, 0, 0, 3, 3, 3, 0, 0, 0, 0, 3, 0, 0, 0, 3, 3, 3, 0],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: _borderlessDarkCardDecoration(
        customBg: const Color(0xFF0F1015),
      ),
      child: Column(
        children: [
          // Heatmap grid with weekday letters on left
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day letters column (M, T, W, T, F, S, S)
              Column(
                children: List.generate(daysOfWeek.length, (rowIndex) {
                  return Container(
                    height: 14,
                    margin: const EdgeInsets.only(bottom: 4),
                    alignment: Alignment.center,
                    child: Text(
                      daysOfWeek[rowIndex],
                      style: AppTypography.base.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8F96),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),

              // Squircle Heatmap columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Shows most recent weeks
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(heatmapPattern[0].length, (colIdx) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.5),
                        child: Column(
                          children: List.generate(7, (rowIdx) {
                            final level = heatmapPattern[rowIdx][colIdx];
                            return Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: _getHeatmapColor(level),
                                borderRadius: BorderRadius.circular(3.5),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date Range Navigation Pill (Matching Image 2)
          Row(
            children: [
              // '<' Circular Icon Button
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1B1C23),
                ),
                child: const Center(
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    'Sep 22, 2025 — Feb 3, 2026',
                    style: AppTypography.base.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 32),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF38151E); // Muted dark mauve
      case 2:
        return const Color(0xFF8C1D38); // Wine red
      case 3:
        return const Color(0xFFFF4868); // Vibrant coral pink
      case 0:
      default:
        return const Color(0xFF1A171D); // Inactive dark cell
    }
  }

  // ===========================================================================
  // 6B. 2x2 METRIC CARDS GRID (Matching Image 2: Streak 8, Check-Ins 558, Avg 2:50, Goal 67%)
  // ===========================================================================
  Widget _buildTwoByTwoMetricsGrid() {
    return Column(
      children: [
        // Row 1: Streak (8) & Total Check-Ins (558)
        Row(
          children: [
            Expanded(
              child: _buildBigMetricCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Streak',
                value: '8',
                bottomText: 'Longest: 8',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBigMetricCard(
                icon: Icons.check_box_rounded,
                title: 'Total Check-Ins',
                value: '558',
                bottomText: 'Started: Apr 13',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Avg. Log Time (2:50 PM) & Goal Progress (67%)
        Row(
          children: [
            Expanded(
              child: _buildBigMetricCard(
                icon: Icons.access_time_filled_rounded,
                title: 'Avg. Log Time',
                value: '2:50',
                bottomText: 'PM',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBigMetricCard(
                icon: Icons.emoji_events_rounded,
                title: 'Goal Progress',
                value: '67%',
                hasProgressBar: true,
                progress: 0.67,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBigMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? bottomText,
    bool hasProgressBar = false,
    double progress = 0.0,
  }) {
    return Container(
      height: 154,
      padding: const EdgeInsets.all(16),
      decoration: _borderlessDarkCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon + Title
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.base.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Big bold coral/pink number (Matching Image 2: color #FF4868)
          Text(
            value,
            style: AppTypography.base.copyWith(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF4868),
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),

          const Spacer(),

          // Bottom section: text or horizontal progress bar
          if (hasProgressBar)
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                width: double.infinity,
                color: const Color(0xFF282933),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4868),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            )
          else if (bottomText != null)
            Text(
              bottomText,
              style: AppTypography.base.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8E8F96),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. HEALTH IMPROVEMENT SCORE CARD (Matching Image 1 Bottom)
  // ===========================================================================
  Widget _buildHealthScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _borderlessDarkCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Improvement Score',
                  style: AppTypography.base.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E8F96),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Optimal Vitality',
                  style: AppTypography.base.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your daily consistency is up 14% this week.',
                  style: AppTypography.base.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6E6F78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Score Badge (82)
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFFFF3373),
                  Color(0xFFFF0050),
                  Color(0xFF8A002B),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0050).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '82',
                style: AppTypography.base.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STREAK TAB: Cloned from Reference Designs:
  // - Day Step Scrubber (media_1795096103438_a52bb151.png):
  //   Month row (< June, 2024 >), MON 14 🔥, TUE 16 🔥, WED 15 (Active capsule
  //   with white circular 15 badge and glowing bottom rim), THU 17..SUN 13
  // - Segmented Chunky Rounded Brick Arc Hero (media_1795096461583_c1966d5f.jpg):
  //   24 chunky rounded blocks arching across, 14, 14 Days Current Streak 🔥
  // - 2x2 Metrics Cards:
  //   Calories (1896 KCAL), Inactive Time (1 HRS 58 MINS OPTIMAL),
  //   Active Hours (14 / 16 HOURS POOR), Active Minutes (0 MINS)
  // - Steps Hourly Distribution Bar Chart (Steps • Fri, 18 Sep, 11, 479 / 9000)
  // - Score Contributors Card (Daily Steps EXCELLENT ⌄, Streak Consistency PERFECT 🔥)
  // ===========================================================================
  Widget _buildStreakTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 50),
      child: Column(
        children: [
          const SizedBox(height: 6),

          // 1. Day Step Scrubber (Matching Image 2: < June, 2024 > + MON 14..WED 15..SUN 13)
          _buildStreakMonthAndDayScrubber(),

          const SizedBox(height: 18),

          // 2. Segmented Chunky Rounded Arc Hero Card (Matching Image: 14 Days, Current Streak 🔥)
          _buildHeroDomeArcCard(),

          const SizedBox(height: 16),

          // 3. 2x2 Metrics Cards Grid (Calories, Inactive Time, Active Hours, Active Minutes)
          _buildTwoByTwoMetrics(),

          const SizedBox(height: 16),

          // 4. Steps Hourly Distribution Bar Chart Card (11,479 / 9000 with 12AM..11PM bars)
          _buildStepsHourlyChartCard(),

          const SizedBox(height: 16),

          // 5. Score Contributors Card (Daily Steps EXCELLENT, Streak PERFECT)
          _buildScoreContributorsCard(),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. DAY STEP SCRUBBER (Matching Image 2: < June, 2024 > with MON 14..WED 15)
  // ===========================================================================
  Widget _buildStreakMonthAndDayScrubber() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: _borderlessDarkCardDecoration(
        customBg: const Color(0xFF111218),
      ),
      child: Column(
        children: [
          // Month navigation row: < June, 2024 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left '<' Chevron
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentMonthYear = 'May, 2024';
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E2029),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Center Month & Year text
              Text(
                _currentMonthYear,
                style: AppTypography.base.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),

              // Right '>' Chevron
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentMonthYear = 'July, 2024';
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E2029),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Days Row: MON 14 🔥 | TUE 16 🔥 | WED 15 (Active) | THU 17 | FRI 18 | SAT 19 | SUN 13
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_streakWeekDays.length, (index) {
              final item = _streakWeekDays[index];
              final isSelected = _selectedStreakDayIndex == index;
              final hasFire = item['hasFire'] as bool;
              final isBlue = item['isBlue'] as bool;

              if (isSelected) {
                // Active Selected Day (WED 15): Elongated pill capsule with white circular badge
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    width: 48,
                    height: 84,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131826),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF2979FF).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2979FF,
                          ).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          item['weekday'] as String,
                          style: AppTypography.base.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF90CAF9),
                            letterSpacing: -0.1,
                          ),
                        ),
                        // Circular white badge with bold date number
                        Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              item['date'] as String,
                              style: AppTypography.base.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Inactive Days: Stacked MON 14 with optional flame 🔥
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedStreakDayIndex = index;
                  });
                  _radialGaugeController.reset();
                  _radialGaugeController.forward();
                },
                child: Container(
                  width: 40,
                  height: 74,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['weekday'] as String,
                        style: AppTypography.base.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8E8F96),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['date'] as String,
                        style: AppTypography.base.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isBlue
                              ? const Color(0xFF81D4FA)
                              : const Color(0xFFB0B1B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasFire)
                        const Text('🔥', style: TextStyle(fontSize: 11))
                      else
                        const SizedBox(height: 14),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. CHUNKY SEGMENTED STREAK ARC HERO (Cloned from Reference UI: Streak Volume)
  // ===========================================================================
  Widget _buildHeroDomeArcCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: _borderlessDarkCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: "Streak Volume" + "..." (Exact clone of reference image)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Streak Volume',
                style: AppTypography.base.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF8E8F96),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. Chunky Segmented Arc with Center Content
          Stack(
            alignment: Alignment.center,
            children: [
              // Atmospheric top warm ambient glow
              Positioned(
                top: -20,
                left: 30,
                right: 30,
                height: 150,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF0050).withValues(alpha: 0.12),
                        const Color(0xFFFF9100).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      radius: 0.7,
                    ),
                  ),
                ),
              ),

              // Animated Chunky Segmented Arc Canvas
              AnimatedBuilder(
                animation: _radialGaugeAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _SegmentedChunkyArcPainter(
                      progress: _radialGaugeAnimation.value,
                    ),
                  );
                },
              ),

              // Center Content inside the Arc (Matching Image: Number + Subtitle)
              Positioned(
                bottom: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Huge Bold Number: 14 (Matching Reference UI chunky style)
                    Text(
                      '14',
                      style: AppTypography.base.copyWith(
                        fontSize: 62,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -2.0,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle: 14 Days • Current Streak 🔥
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '14 Days',
                          style: AppTypography.base.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF4868),
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          ' • Current Streak 🔥',
                          style: AppTypography.base.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Bottom Pill Banner (Exact Clone of Image: "Your customer volume has increased" -> "Your streak volume has increased" + [↗ +15%])
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF171822),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF232533),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Your streak volume has increased',
                    style: AppTypography.base.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC7C9D3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E3222),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_outward_rounded,
                        size: 13,
                        color: Color(0xFF00E676),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '+15%',
                        style: AppTypography.base.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00E676),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. 2x2 METRICS CARDS (Calories, Inactive Time, Active Hours, Active Minutes)
  // ===========================================================================
  Widget _buildTwoByTwoMetrics() {
    return Column(
      children: [
        // Row 1: Calories & Inactive Time
        Row(
          children: [
            // Card 1: Calories (1896 KCAL, ACTIVE: 351KCAL)
            Expanded(
              child: _buildFitnessMetricTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF9100),
                title: 'Calories',
                value: '1896',
                unit: 'KCAL',
                subtitle: 'ACTIVE: 351KCAL',
              ),
            ),
            const SizedBox(width: 12),

            // Card 2: Inactive Time (1 HRS 58 MINS, OPTIMAL)
            Expanded(
              child: _buildFitnessMetricTile(
                icon: Icons.accessibility_new_rounded,
                iconColor: const Color(0xFF8E8F96),
                title: 'Inactive Time',
                value: '1',
                unit: 'HRS',
                secondValue: '58',
                secondUnit: 'MINS',
                status: 'OPTIMAL',
                statusColor: const Color(0xFF00E676),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Active Hours & Active Minutes
        Row(
          children: [
            // Card 3: Active Hours (14 / 16 HOURS, POOR)
            Expanded(
              child: _buildFitnessMetricTile(
                icon: Icons.directions_run_rounded,
                iconColor: const Color(0xFF8E8F96),
                title: 'Active Hours',
                hasChevron: true,
                value: '14',
                unit: '/ 16 HOURS',
                status: 'POOR',
                statusColor: const Color(0xFFFF4081),
              ),
            ),
            const SizedBox(width: 12),

            // Card 4: Active Minutes (0 MINS)
            Expanded(
              child: _buildFitnessMetricTile(
                icon: Icons.directions_run_rounded,
                iconColor: const Color(0xFF8E8F96),
                title: 'Active Minutes',
                hasChevron: true,
                value: '0',
                unit: 'MINS',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFitnessMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    String? secondValue,
    String? secondUnit,
    String? subtitle,
    String? status,
    Color? statusColor,
    bool hasChevron = false,
  }) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(14),
      decoration: _borderlessDarkCardDecoration(
        customBg: const Color(0xFF111218),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.base.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E8F96),
                  ),
                ),
              ),
              if (hasChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF6E6F78),
                ),
            ],
          ),

          // Main values row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.base.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.base.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8E8F96),
                ),
              ),
              if (secondValue != null) ...[
                const SizedBox(width: 6),
                Text(
                  secondValue,
                  style: AppTypography.base.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  secondUnit ?? '',
                  style: AppTypography.base.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8E8F96),
                  ),
                ),
              ],
            ],
          ),

          // Footer: Subtitle or status badge
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTypography.base.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6E6F78),
                letterSpacing: 0.5,
              ),
            )
          else if (status != null && statusColor != null)
            Text(
              status,
              style: AppTypography.base.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: statusColor,
                letterSpacing: 0.6,
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. STEPS HOURLY DISTRIBUTION BAR CHART (Matching Image 1: 11, 479 / 9000)
  // ===========================================================================
  Widget _buildStepsHourlyChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _borderlessDarkCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Steps • Fri, 18 Sep
          Text(
            'Steps • Fri, 18 Sep',
            style: AppTypography.base.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8E8F96),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),

          // Hero number: 11, 479 / 9000
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '11, 479',
                style: AppTypography.base.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/9000',
                style: AppTypography.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E6F78),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Hourly Bars with Y-Axis Labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 24 Hourly Step Bars Canvas
              Expanded(
                child: SizedBox(
                  height: 110,
                  child: AnimatedBuilder(
                    animation: _radialGaugeAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(double.infinity, 110),
                        painter: _StepsHourlyBarsPainter(
                          progress: _radialGaugeAnimation.value,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Y-Axis markers: 1500, 1125, 750, 375, 0 (Matching Image 1)
              SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '1500',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6E6F78)),
                    ),
                    Text(
                      '1125',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6E6F78)),
                    ),
                    Text(
                      '750',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6E6F78)),
                    ),
                    Text(
                      '375',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6E6F78)),
                    ),
                    Text(
                      '0',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6E6F78)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // X-Axis Time Markers: 12 AM | 6 AM | 12 PM | 6 PM | 11 PM
          Padding(
            padding: const EdgeInsets.only(right: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '12 AM',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF6E6F78)),
                ),
                Text(
                  '6 AM',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF6E6F78)),
                ),
                Text(
                  '12 PM',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF6E6F78)),
                ),
                Text(
                  '6 PM',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF6E6F78)),
                ),
                Text(
                  '11 PM',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF6E6F78)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. SCORE CONTRIBUTORS CARD (Matching Image 1: EXCELLENT ⌄)
  // ===========================================================================
  Widget _buildScoreContributorsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _borderlessDarkCardDecoration(
        customBg: const Color(0xFF111218),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score contributors',
            style: AppTypography.base.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),

          // Contributor 1: Daily Steps (11,479 steps -> EXCELLENT ⌄)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Steps',
                    style: AppTypography.base.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E8F96),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '11,479 steps',
                    style: AppTypography.base.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'EXCELLENT',
                    style: AppTypography.base.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00E676),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF00E676),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Color(0xFF1D1F28), height: 1),
          ),

          // Contributor 2: Consistency Rate (14 Days -> PERFECT 🔥)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consistency Rate',
                    style: AppTypography.base.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E8F96),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '14 Days Active Streak',
                    style: AppTypography.base.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                'PERFECT 🔥',
                style: AppTypography.base.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF4868),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REUSABLE PURE DARK CARD DECORATION (Matching Swatch: #111218 across all widgets)
  // ===========================================================================
  BoxDecoration _borderlessDarkCardDecoration({Color? customBg}) {
    return BoxDecoration(
      color: customBg ?? const Color(0xFF111218), // Pure Dark Matching Swatch
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}

// =============================================================================
// CHUNKY SEGMENTED ARC PAINTER (Matching Reference Image Chunky Rounded Blocks)
// =============================================================================
class _SegmentedChunkyArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 animation

  _SegmentedChunkyArcPainter({required this.progress});

  static const int totalSegments = 24;
  static const int targetActiveSegments = 17; // ~71% active for 14-day streak

  @override
  void paint(Canvas canvas, Size size) {
    // Arc center placed slightly below bottom baseline
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width * 0.38;

    // Semi-circular arc from 180° (math.pi) to 360° (2 * math.pi)
    const startAngle = math.pi + 0.04;
    const sweepAngle = math.pi - 0.08;
    final angleStep = sweepAngle / (totalSegments - 1);

    // Chunky block dimensions
    const blockLength = 22.0; // Radial thickness of each chunky segment
    const blockBreadth = 9.5; // Tangential breadth of each pill
    const cornerRadius = Radius.circular(4.8);

    final activeCount = (targetActiveSegments * progress).round();

    for (int i = 0; i < totalSegments; i++) {
      final angle = startAngle + i * angleStep;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final isFilled = i < activeCount;
      final paint = Paint()..style = PaintingStyle.fill;

      if (isFilled) {
        // Gradient interpolation across active segments: Flame Amber -> Neon Red
        final t = targetActiveSegments > 1
            ? (i / (targetActiveSegments - 1)).clamp(0.0, 1.0)
            : 0.0;
        paint.color = Color.lerp(
          const Color(0xFFFF9100), // Vibrant amber/orange
          const Color(0xFFFF0050), // Brand neon red
          t,
        )!;
      } else {
        // Unfilled inactive dark charcoal segments
        paint.color = const Color(0xFF222430);
      }

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(radius, 0),
          width: blockLength,
          height: blockBreadth,
        ),
        cornerRadius,
      );

      canvas.drawRRect(rrect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedChunkyArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// STEPS HOURLY BARS PAINTER (Matching Image 1 Steps Distribution Chart)
// =============================================================================
class _StepsHourlyBarsPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 animation

  _StepsHourlyBarsPainter({required this.progress});

  // 26 bar heights representing realistic active walking peaks throughout the day
  static const List<double> _relativeHeights = [
    0.05,
    0.02,
    0.00,
    0.00,
    0.00,
    0.00,
    0.04,
    0.12,
    0.18,
    0.32,
    0.16,
    0.22,
    0.12,
    0.48,
    0.14,
    0.30,
    0.26,
    0.08,
    0.12,
    0.85,
    0.34,
    0.46,
    0.38,
    0.42,
    0.22,
    0.06,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = _relativeHeights.length;
    final totalWidth = size.width;
    final barWidth = (totalWidth / (barCount * 1.55)).clamp(3.0, 7.0);
    final spacing = (totalWidth - (barWidth * barCount)) / (barCount - 1);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final rawHeight = _relativeHeights[i] * size.height;
      final animatedHeight = (rawHeight * progress).clamp(3.0, size.height);
      final y = size.height - animatedHeight;

      final isPeak = _relativeHeights[i] > 0.4;

      paint.color = isPeak
          ? const Color(0xFFFF5722)
          : const Color(0xFFFF9100).withValues(alpha: 0.85);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, animatedHeight),
        Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StepsHourlyBarsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

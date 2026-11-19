import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bold_rounded_icons.dart';
import 'event_detail_screen.dart';

/// Event card data model matching reference design
class EventCardItem {
  final int day;
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageAsset;
  final double tiltAngle; // in radians

  const EventCardItem({
    required this.day,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageAsset,
    required this.tiltAngle,
  });
}

/// Full-screen or embedded Event & Routine Screen matching the reference design:
/// - Main white canvas with deep 48px rounded bottom corners
/// - Zero buttons in the blur area (pure clean card deck)
/// - Perfectly feathered, smoothly blending blur gradient (ShaderMask + progressive blur overlay)
/// - Margin-top (mt) added for breathing room
/// - Bottom dark section with exact timeline ruler from Image 1:
///   - 9 minor ticks between each major day tick (10 equal subdivisions)
///   - Numbers 4, 5, 6, 7, 8 centered directly under their major ticks
///   - Bright white active center tick pill with subtle glow and bold white number directly underneath
///   - Wide black gradient fades on both left and right edges
///   - Centered white iOS home indicator line
class EventRoutineScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onClose;

  const EventRoutineScreen({super.key, this.isEmbedded = false, this.onClose});

  @override
  State<EventRoutineScreen> createState() => _EventRoutineScreenState();
}

class _EventRoutineScreenState extends State<EventRoutineScreen> {
  late DateTime _selectedDate;
  late ScrollController _rulerScrollController;
  late ScrollController _cardsScrollController;
  late ScrollController _monthsScrollController;

  final int _totalDays = 31;
  final double _dayStep =
      72.0; // Distance between each day tick (fits 9 minor ticks)
  final double _monthStep =
      130.0; // Step width per month for centered magnetic snapping
  static const double _cardExtent =
      420.0; // Card height (380) + vertical padding (40 gap)

  bool _isSyncingFromRuler = false;
  bool _isSyncingFromCards = false;

  /// 10 Event Cards across days with alternating tilt angles (right, left, right, left...)
  static const List<EventCardItem> _eventCards = [
    EventCardItem(
      day: 1,
      title: 'The Lotus\nReading Club',
      subtitle: "This month's pick: Klara and the Sun\nby Kazuo Ishiguro",
      buttonText: 'Join the club',
      imageAsset: 'assets/images/cards/image-.png',
      tiltAngle: 0.035, // ~ +2.0°
    ),
    EventCardItem(
      day: 4,
      title: 'Sunrise\nTennis Open',
      subtitle: 'Center court matchplay & rally drills\nwith coach Marcus',
      buttonText: 'Book court',
      imageAsset: 'assets/images/cards/image-2.png',
      tiltAngle: -0.038, // ~ -2.2°
    ),
    EventCardItem(
      day: 7,
      title: 'Metabolic\nEndurance 5K',
      subtitle: 'Fast-tempo riverfront morning run\nwith sub-20 pacers',
      buttonText: 'Register run',
      imageAsset: 'assets/images/cards/image-.png',
      tiltAngle: 0.032, // ~ +1.8°
    ),
    EventCardItem(
      day: 11,
      title: 'Alpine Trail\nUltra Hike',
      subtitle: 'Vertical ascent: 1,200m elevation push\nthrough pine ridge',
      buttonText: 'Join expedition',
      imageAsset: 'assets/images/cards/image-2.png',
      tiltAngle: -0.036, // ~ -2.1°
    ),
    EventCardItem(
      day: 14,
      title: 'Aero Track\nCycling Tour',
      subtitle: '45 km paceline draft & hill climbs\nwith peloton safety leads',
      buttonText: 'Reserve peloton',
      imageAsset: 'assets/images/cards/image-.png',
      tiltAngle: 0.040, // ~ +2.3°
    ),
    EventCardItem(
      day: 18,
      title: 'Zen Core\nPilates Flow',
      subtitle:
          'Reformer precision: Spine posture &\ndeep core stabilizer control',
      buttonText: 'Book reformer',
      imageAsset: 'assets/images/cards/image-2.png',
      tiltAngle: -0.034, // ~ -1.9°
    ),
    EventCardItem(
      day: 21,
      title: 'Nightfall\nSprint Session',
      subtitle: 'Interval sprint drills on tartan track\nunder floodlights',
      buttonText: 'RSVP track',
      imageAsset: 'assets/images/cards/image-.png',
      tiltAngle: 0.036, // ~ +2.1°
    ),
    EventCardItem(
      day: 24,
      title: 'Pulse Beat\nBoxing Club',
      subtitle: 'Heavy bag combos, agile footwork &\ncore power conditioning',
      buttonText: 'Join session',
      imageAsset: 'assets/images/cards/image-2.png',
      tiltAngle: -0.038, // ~ -2.2°
    ),
    EventCardItem(
      day: 26,
      title: 'Hydro Peak\nSwim Series',
      subtitle:
          'Freestyle stroke mechanics & high-aerobic\nlap intervals in olympic pool',
      buttonText: 'Claim lane',
      imageAsset: 'assets/images/cards/image-.png',
      tiltAngle: 0.032, // ~ +1.8°
    ),
    EventCardItem(
      day: 29,
      title: 'Twilight\nYoga Sanctuary',
      subtitle: 'Sunset vinyasa flow & sound bath\nmeditation to restore mind',
      buttonText: 'Reserve mat',
      imageAsset: 'assets/images/cards/image-2.png',
      tiltAngle: -0.035, // ~ -2.0°
    ),
  ];

  int _findClosestCardIndex(int day) {
    int closestIndex = 0;
    int minDiff = 999;
    for (int i = 0; i < _eventCards.length; i++) {
      final diff = (_eventCards[i].day - day).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2025, 2, 26);

    final initialCardIndex = _findClosestCardIndex(_selectedDate.day);
    _cardsScrollController = ScrollController(
      initialScrollOffset: initialCardIndex * _cardExtent,
    );

    final initialMonthOffset = (_selectedDate.month - 1) * _monthStep;
    _monthsScrollController = ScrollController(
      initialScrollOffset: initialMonthOffset,
    );
    _monthsScrollController.addListener(_onMonthsScroll);

    // Center on day 26 initially
    final initialDayIndex = _selectedDate.day - 1;
    final initialOffset = initialDayIndex * _dayStep;
    _rulerScrollController = ScrollController(
      initialScrollOffset: initialOffset,
    );

    _rulerScrollController.addListener(_onRulerScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm image cache to eliminate any first-open asset decoding delays
    precacheImage(const AssetImage('assets/images/cards/image-.png'), context);
    precacheImage(const AssetImage('assets/images/cards/image-2.png'), context);
  }

  @override
  void dispose() {
    _rulerScrollController.removeListener(_onRulerScroll);
    _rulerScrollController.dispose();
    _cardsScrollController.dispose();
    _monthsScrollController.removeListener(_onMonthsScroll);
    _monthsScrollController.dispose();
    super.dispose();
  }

  void _onMonthsScroll() {
    if (!_monthsScrollController.hasClients) return;
    final offset = _monthsScrollController.offset;
    final monthIndex = (offset / _monthStep).round().clamp(0, 11);
    final newMonth = monthIndex + 1;

    if (newMonth != _selectedDate.month) {
      HapticFeedback.selectionClick();
      final maxDays = DateTime(_selectedDate.year, newMonth + 1, 0).day;
      final newDay = _selectedDate.day.clamp(1, maxDays);
      setState(() {
        _selectedDate = DateTime(_selectedDate.year, newMonth, newDay);
      });
      _scrollToDay(newDay);
    }
  }

  void _onRulerScroll() {
    if (!_rulerScrollController.hasClients) return;
    final offset = _rulerScrollController.offset;
    final dayIndex = (offset / _dayStep).round().clamp(0, _totalDays - 1);
    final newDay = dayIndex + 1;

    if (newDay != _selectedDate.day) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          newDay,
        );
      });
      _scrollCardsToDay(newDay);
    }
  }

  void _scrollToDay(int day) {
    final clampedDay = day.clamp(1, _totalDays);
    if (clampedDay != _selectedDate.day) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          clampedDay,
        );
      });
    }
    if (_rulerScrollController.hasClients) {
      final targetOffset = (clampedDay - 1) * _dayStep;
      if ((_rulerScrollController.offset - targetOffset).abs() >= 0.5) {
        HapticFeedback.lightImpact();
        _rulerScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    }
    _scrollCardsToDay(clampedDay);
  }

  void _scrollCardsToDay(int day) {
    if (_isSyncingFromCards) return;
    _isSyncingFromRuler = true;
    final cardIndex = _findClosestCardIndex(day);
    final targetOffset = cardIndex * _cardExtent;
    if (_cardsScrollController.hasClients) {
      if ((_cardsScrollController.offset - targetOffset).abs() > 4.0) {
        _cardsScrollController
            .animateTo(
              targetOffset.clamp(
                0.0,
                _cardsScrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            )
            .then((_) {
              _isSyncingFromRuler = false;
            });
        return;
      }
    }
    _isSyncingFromRuler = false;
  }

  void _snapCardsToIndex(int index) {
    if (!_cardsScrollController.hasClients || _isSyncingFromRuler) return;
    final targetOffset = index * _cardExtent;
    _isSyncingFromCards = true;
    _cardsScrollController
        .animateTo(
          targetOffset.clamp(
            0.0,
            _cardsScrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _isSyncingFromCards = false;
          });
        });
  }

  void _onCardsUserScroll() {
    if (!_cardsScrollController.hasClients || _isSyncingFromRuler) return;
    _isSyncingFromCards = true;
    final activeIndex = (_cardsScrollController.offset / _cardExtent)
        .round()
        .clamp(0, _eventCards.length - 1);
    final card = _eventCards[activeIndex];
    if (card.day != _selectedDate.day) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          card.day,
        );
      });
      if (_rulerScrollController.hasClients) {
        final targetOffset = (card.day - 1) * _dayStep;
        if ((_rulerScrollController.offset - targetOffset).abs() >= 0.5) {
          _rulerScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 260), () {
      _isSyncingFromCards = false;
    });
  }

  String _formatPillDate(DateTime date) {
    if (date.day == 26 && date.month == 2 && date.year == 2025) {
      return 'Today';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          Colors.black, // Dark canvas under the rounded white container
      body: Column(
        children: [
          // ==================================================================
          // 1. MAIN SECTION: White canvas with 48px rounded bottom & smooth blur
          // ==================================================================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(
                    48,
                  ), // Deep 48px rounded bottom corners
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.40),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Scrollable Cards List with ShaderMask for ultra-smooth edge dissolution
                  // Dynamically centers cards vertically in viewport with generous breathing mt
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final topSafeArea = MediaQuery.of(context).padding.top;
                        final headerHeight = topSafeArea + 56.0;
                        const bottomHeight = 50.0;
                        const cardHeight = 380.0;
                        final availableHeight =
                            constraints.maxHeight - headerHeight - bottomHeight;
                        final verticalMargin = math.max(
                          24.0,
                          (availableHeight - cardHeight) / 2,
                        );
                        final topPadding = math.max(
                          145.0,
                          headerHeight + verticalMargin - 20.0,
                        );
                        final bottomPadding = math.max(
                          60.0,
                          bottomHeight + verticalMargin - 20.0,
                        );

                        return NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (_isSyncingFromRuler) return false;
                            if (notification is ScrollUpdateNotification &&
                                notification.dragDetails != null) {
                              _onCardsUserScroll();
                            } else if (notification is ScrollEndNotification) {
                              _onCardsUserScroll();
                              final targetIndex =
                                  (_cardsScrollController.offset / _cardExtent)
                                      .round()
                                      .clamp(0, _eventCards.length - 1);
                              final targetOffset = targetIndex * _cardExtent;
                              if ((_cardsScrollController.offset - targetOffset)
                                      .abs() >
                                  0.5) {
                                _snapCardsToIndex(targetIndex);
                              }
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: _cardsScrollController,
                            physics: const RulerSnapScrollPhysics(
                              step: _cardExtent,
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(
                              top:
                                  topPadding, // Generous mt and centered alignment
                              bottom: bottomPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: _eventCards
                                  .map(
                                    (event) =>
                                        _buildEventCard(event, screenWidth),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Pinned Top Frosted Glass Header:
                  // Centered Month Names + 'X' close button (smooth blur gradient)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildPinnedTopHeader(screenWidth),
                  ),

                  // Bottom Pure Frosted Glass Blur Gradient (NO buttons, smooth gradient blending into rounded bottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildWhiteSectionBottomBlur(),
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // 2. BOTTOM SECTION: Date Pill + Next Arrow [➔] + Scrubber Ruler
          // + Centered White iOS Home Indicator (Pixel clone of Image 1)
          // ==================================================================
          _buildBottomSection(screenWidth),
        ],
      ),
    );
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _scrollToMonth(int monthIndex) {
    if (!_monthsScrollController.hasClients) return;
    final target = monthIndex * _monthStep;
    if ((_monthsScrollController.offset - target).abs() < 0.5) return;
    HapticFeedback.lightImpact();
    _monthsScrollController.animateTo(
      target.clamp(0.0, _monthsScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  /// Pinned Top Frosted Glass Header:
  /// Close button 'X' + Centered Month names row with auto-drag magnetic snapping
  /// High opacity white header shielding cards underneath, dissolving smoothly into opacity 0
  Widget _buildPinnedTopHeader(double screenWidth) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
            Color.fromARGB(250, 255, 255, 255),
            Color.fromARGB(220, 255, 255, 255),
            Color.fromARGB(150, 255, 255, 255),
            Color.fromARGB(0, 255, 255, 255),
          ],
          stops: [0.0, 0.52, 0.72, 0.86, 0.94, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Centered Horizontal Month Names Row spanning full screen with Auto-Drag Magnetic Snapping
              _buildMonthNamesHeader(screenWidth),

              // Left Frosted Close Button ('X')
              Positioned(left: 18, child: _buildCloseButton()),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal Month Names Row:
  /// The active month is centered horizontally on screen, with adjacent months displayed in soft grey.
  /// Magically auto-drags and snaps to the nearest month when dragged or scrolled.
  Widget _buildMonthNamesHeader(double screenWidth) {
    final horizontalPadding = (screenWidth - _monthStep) / 2;

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final offset = _monthsScrollController.offset;
                final targetMonth = (offset / _monthStep).round().clamp(0, 11);
                final targetOffset = targetMonth * _monthStep;
                if ((offset - targetOffset).abs() > 0.5) {
                  _scrollToMonth(targetMonth);
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _monthsScrollController,
              scrollDirection: Axis.horizontal,
              physics: RulerSnapScrollPhysics(
                step: _monthStep,
                parent: const BouncingScrollPhysics(),
              ),
              clipBehavior: Clip.none,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: _monthNames.length,
              itemBuilder: (context, index) {
                final isSelected = (_selectedDate.month - 1) == index;
                final monthName = _monthNames[index];

                return GestureDetector(
                  onTap: () {
                    _scrollToMonth(index);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: _monthStep,
                    child: Center(
                      child: Text(
                        monthName,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSelected ? 26 : 24,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFB0B0B8).withValues(alpha: 0.50),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Left Gradient Fade (Increased opacity)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 70,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Color.fromARGB(230, 255, 255, 255),
                      Color.fromARGB(140, 255, 255, 255),
                      Color.fromARGB(0, 255, 255, 255),
                    ],
                    stops: [0.0, 0.40, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Right Gradient Fade (Increased opacity)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 70,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.white,
                      Color.fromARGB(230, 255, 255, 255),
                      Color.fromARGB(140, 255, 255, 255),
                      Color.fromARGB(0, 255, 255, 255),
                    ],
                    stops: [0.0, 0.40, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Circular Frosted 'X' Close Button
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onClose != null) {
          widget.onClose!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          _scrollToDay(26);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2C2D35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(child: BoldCloseIcon(size: 16, strokeWidth: 2.8)),
      ),
    );
  }

  /// Smoothly Blending Bottom Blur Gradient (NO buttons inside):
  /// High opacity gradient fading cleanly into solid white at the 48px rounded bottom curve
  Widget _buildWhiteSectionBottomBlur() {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
        child: Container(
          height: 56,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(0, 255, 255, 255),
                Color.fromARGB(75, 255, 255, 255),
                Color.fromARGB(180, 255, 255, 255),
                Color.fromARGB(245, 255, 255, 255),
                Colors.white,
                Colors.white,
              ],
              stops: [0.0, 0.25, 0.55, 0.80, 0.94, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  void _openEventDetail(EventCardItem event, DateTime cardDate) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) =>
            EventDetailScreen(event: event, selectedDate: cardDate),
      ),
    );
  }

  /// Event Card: Pixel-accurate clone of reference design (Image 10)
  /// - Full bleed image asset with deep dark bottom gradient
  /// - Top-left calendar date badge (Month, Day, Weekday)
  /// - Top-right frosted translucent share button
  /// - Editorial Serif event title
  /// - Event description
  /// - Full-width white action button
  /// - Alternating tilt angle (right / left / right / left)
  Widget _buildEventCard(EventCardItem event, double screenWidth) {
    final cardWidth = math.min(screenWidth - 44, 345.0);
    final cardDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      event.day,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20.0,
      ), // Increased gap between cards to 40px
      child: Center(
        child: Transform.rotate(
          angle: event.tiltAngle,
          child: GestureDetector(
            onTap: () => _openEventDetail(event, cardDate),
            child: Container(
              width: cardWidth,
              height: 380, // Decreased card height from 440 to 380
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Stack(
                  children: [
                    // Background cover image
                    Positioned.fill(
                      child: Image.asset(
                        event.imageAsset,
                        width: cardWidth,
                        height: 380,
                        fit: BoxFit.cover,
                        cacheWidth: 690,
                        filterQuality: FilterQuality.low,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1E1E24),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white38,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Smooth dark gradient overlay for text legibility
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.30),
                              Colors.black.withValues(alpha: 0.85),
                              Colors.black,
                            ],
                            stops: const [0.0, 0.25, 0.52, 0.80, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Date Badge (Left) + Frosted Share Button (Right)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardCalendarBadge(cardDate, event.day),
                              _buildCardShareButton(),
                            ],
                          ),

                          const Spacer(),

                          // Event Serif Title
                          Text(
                            event.title,
                            style: GoogleFonts.newsreader(
                              textStyle: const TextStyle(
                                fontFamily: 'Georgia',
                                fontFamilyFallback: [
                                  'Times New Roman',
                                  'serif',
                                ],
                              ),
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1.12,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Event Subtitle / Description
                          Text(
                            event.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Full-width Solid White Action Pill Button
                          _buildCardActionButton(
                            event.buttonText,
                            onTap: () => _openEventDetail(event, cardDate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calendar Date Badge: Top black month header, bottom white day & weekday
  Widget _buildCardCalendarBadge(DateTime date, int day) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekdayStr = weekdays[date.weekday - 1];
    const monthsAbbr = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final monthStr = monthsAbbr[date.month - 1];

    return Container(
      width: 52,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top black month bar
          Container(
            height: 19,
            width: double.infinity,
            color: const Color(0xFF141518),
            alignment: Alignment.center,
            child: Text(
              monthStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          // Bottom white day & weekday section
          Expanded(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    weekdayStr,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Frosted glass share button with rounded square shape matching reference image
  Widget _buildCardShareButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: BoldShareIcon(size: 20, strokeWidth: 2.6)),
    );
  }

  /// Full-width White Action Pill Button ("Join the club", "Book court", etc.)
  Widget _buildCardActionButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 2. BOTTOM SECTION:
  // Date Pill [📅 Today] / [📅 1 Jun] + Next Button [➔]
  // + Timeline Ruler matching Image 1:
  //   - 9 minor ticks between each major tick (10 subdivisions)
  //   - Centered numbers (4, 5, 6, 7, 8) directly under major ticks
  //   - Bright white active center tick pill with glow and bold white number
  //   - Left and right black gradient edge fades
  // ==========================================================================
  Widget _buildBottomSection(double screenWidth) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(
        top: 20, // Added mt (margin-top) for comfortable breathing room
        bottom: 8,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Navigation Row: [📅 Today] + [➔]
            _buildDateNavigationRow(),

            const SizedBox(height: 18), // Added mt between pill and ruler
            // Horizontal Date Ruler with Left and Right Black Gradient Fades (Image 1)
            _buildRulerScrubberWithGradients(screenWidth),
          ],
        ),
      ),
    );
  }

  /// Date Navigation Row: [📅 1 Jun] + [➔]
  Widget _buildDateNavigationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Arrow (only when not on day 1)
        if (_selectedDate.day > 1)
          GestureDetector(
            onTap: () => _scrollToDay(_selectedDate.day - 1),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1F26),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: const Center(
                child: BoldBackArrowIcon(size: 15, strokeWidth: 2.8),
              ),
            ),
          ),

        // Main Date Pill: [📅 Today] or [📅 1 Jun]
        GestureDetector(
          onTap: () => _scrollToDay(26),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF282933),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatPillDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Right Arrow circular button: [➔]
        GestureDetector(
          onTap: () {
            if (_selectedDate.day < _totalDays) {
              _scrollToDay(_selectedDate.day + 1);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1F26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            child: const Center(
              child: BoldForwardArrowIcon(size: 15, strokeWidth: 2.8),
            ),
          ),
        ),
      ],
    );
  }

  /// Interactive Horizontal Timeline Ruler:
  /// - Auto-drag & magnetic snap physics to merge smoothly with the nearest big line as one
  /// - Fixed center bright white active indicator line (crisp, solid white, no glow)
  /// - The ruler ticks and numbers drag smoothly to and underneath the fixed center line
  /// - Starts directly from the big line (Day 1) with NO small lines before it
  /// - Exactly 9 minor ticks between each major day tick (10 equal intervals)
  /// - Day number closest to the fixed center line turns bold white
  Widget _buildRulerScrubberWithGradients(double screenWidth) {
    final halfScreenWidth = screenWidth / 2;

    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Scrollable Ruler Ticks with Native Magnetic Snap Physics
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final offset = _rulerScrollController.offset;
                final targetDay =
                    (offset / _dayStep).round().clamp(0, _totalDays - 1) + 1;
                final targetOffset = (targetDay - 1) * _dayStep;
                if ((offset - targetOffset).abs() > 0.5) {
                  _scrollToDay(targetDay);
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _rulerScrollController,
              scrollDirection: Axis.horizontal,
              physics: RulerSnapScrollPhysics(
                step: _dayStep,
                parent: const BouncingScrollPhysics(),
              ),
              clipBehavior: Clip.none,
              padding: EdgeInsets.symmetric(horizontal: halfScreenWidth),
              itemCount: _totalDays,
              itemBuilder: (context, index) {
                final dayNumber = index + 1;
                final isFocused = dayNumber == _selectedDate.day;
                final isLast = index == _totalDays - 1;

                return GestureDetector(
                  onTap: () => _scrollToDay(dayNumber),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: isLast ? 40.0 : _dayStep,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Centered Major Line + Day Number Directly Under It (starts exactly at x = 0)
                        Positioned(
                          left: -20,
                          width: 40,
                          top: 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 2.0,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5A5B64),
                                  borderRadius: BorderRadius.circular(1.0),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$dayNumber',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isFocused ? 14 : 13,
                                  fontWeight: isFocused
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isFocused
                                      ? Colors.white
                                      : const Color(0xFF6E707B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Exactly 9 Minor Ticks spaced between this day and next (10 equal intervals)
                        if (!isLast)
                          for (int i = 1; i <= 9; i++)
                            Positioned(
                              left: _dayStep * (i / 10.0) - 1.0,
                              top: 14,
                              child: _buildMinorTick(),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed Center Active Indicator Line (Crisp, solid white, NO glow)
          Positioned(
            top: 8,
            child: IgnorePointer(
              child: Container(
                width: 3.0,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),

          // Left Black Gradient Fade (Fades ticks into black towards edge)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 84,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black, Colors.black87, Colors.transparent],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Right Black Gradient Fade (Fades ticks into black towards edge)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 84,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.black, Colors.black87, Colors.transparent],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinorTick() {
    return Container(
      width: 2.0,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF383A46),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Custom hybrid scroll physics:
/// - Fast flicks / flings coast with full, unrestricted free scrolling across days
/// - When slowing down or dragged slowly, it magnetically auto-drags and snaps to the nearest big line
class RulerSnapScrollPhysics extends ScrollPhysics {
  final double step;

  const RulerSnapScrollPhysics({required this.step, super.parent});

  @override
  RulerSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RulerSnapScrollPhysics(step: step, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If out of range (bouncing at bounds), let parent handle bounce
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Fast flick / fling: let it scroll completely free across days with natural momentum
    if (velocity.abs() >= 160.0) {
      return super.createBallisticSimulation(position, velocity);
    }

    // Slowed down / slow drag: magnetically auto-drag and snap to nearest tick
    final double target = (position.pixels / step).round() * step;
    final clampedTarget = target.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if ((clampedTarget - position.pixels).abs() < 0.2) {
      return null;
    }

    return ScrollSpringSimulation(
      const SpringDescription(mass: 1.0, stiffness: 220.0, damping: 24.0),
      position.pixels,
      clampedTarget,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/bold_rounded_icons.dart';
import 'event_routine_screen.dart';
import 'ticket_screen.dart';

/// Detailed Event Page matching reference designs (Image 1 & Image 2):
/// - Main background: AppColors.redToBlackGradient (as used in WalkView)
/// - Transparent top bar and transparent bottom bar (NO blue or blur overlay covering background)
/// - Real photo imagery for event hero, host avatar, attendee avatars, and event moments gallery
/// - Frosted glass cards with refraction over the red-to-black gradient
/// - Hero Header: squircle event thumbnail + bold title
/// - Quick stats card: 3-column metrics (Spots | Joined | Hours) matching Image 1
/// - Date & Time section with frosted date badge pill and clock range
/// - Location Card with real map preview, address, "Get Direction", and globe button
/// - Hosted By & People Going card with real portraits and overlapping attendee faces
/// - "About The Event" section with emoji headers and rich descriptions
/// - "Event Moments" horizontal gallery strip with real photography
/// - Pinned bottom vivid electric cobalt blue "Join the Event" button floating seamlessly
class EventDetailScreen extends StatefulWidget {
  final EventCardItem event;
  final DateTime selectedDate;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.selectedDate,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isJoined = false;

  static const List<String> _attendeePhotos = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=120&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=120&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop&q=80',
  ];

  static const List<String> _galleryPhotos = [
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1526676037777-05a232554f77?w=400&auto=format&fit=crop&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        // Main Red to Black Gradient as used in WalkView
        decoration: const BoxDecoration(gradient: AppColors.redToBlackGradient),
        child: Stack(
          children: [
            // 1. Scrollable Main Content
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 104, // Space below floating top nav buttons
                  bottom: 110, // Space above floating bottom Join button
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Event Header: Squircle Thumbnail + Bold Title
                      _buildHeroHeader(),

                      const SizedBox(height: 18),

                      // Quick Stats Metrics Card (from Image 1 design)
                      _buildQuickStatsCard(),

                      const SizedBox(height: 18),

                      // Date & Time Row: Frosted Date Badge + Date string + Clock range
                      _buildDateTimeSection(),

                      const SizedBox(height: 18),

                      // Location Card: Real Map Preview + Address + Get Direction + Globe Button
                      _buildLocationCard(),

                      const SizedBox(height: 18),

                      // Host & Attendees Card: "Hosted By" + "People Going" overlapping avatars
                      _buildHostAndAttendeesCard(),

                      const SizedBox(height: 24),

                      // "About The Event" Detailed Section
                      _buildAboutEventSection(),

                      const SizedBox(height: 24),

                      // "Event Moments" Real Photos Gallery (from Image 1 design)
                      _buildEventMomentsGallery(),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Floating Top Navigation Bar (Transparent background, NO blur overlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTransparentTopNavBar(context),
            ),

            // 3. Floating Bottom Join Button (Transparent background, NO blur overlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildTransparentBottomJoinBar(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating Top Navigation Bar with completely transparent background
  Widget _buildTransparentTopNavBar(BuildContext context) {
    return Container(
      color: Colors
          .transparent, // Completely transparent, letting red-to-black gradient shine
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              _buildFrostedCircleButton(
                icon: CupertinoIcons.arrow_left,
                customIcon: const BoldBackArrowIcon(size: 20, strokeWidth: 2.8),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              ),

              // Share Button
              _buildFrostedCircleButton(
                icon: CupertinoIcons.paperplane,
                customIcon: const BoldSendIcon(size: 20, strokeWidth: 2.6),
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sharing "${widget.event.title.replaceAll('\n', ' ')}"...',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(0xFF1E202B),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedCircleButton({
    required IconData icon,
    Widget? customIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.38),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.0,
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
          child: customIcon ?? Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  /// Hero Event Header: Squircle Thumbnail + Bold Multi-line Title
  Widget _buildHeroHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Squircle Thumbnail
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              widget.event.imageAsset,
              fit: BoxFit.cover,
              cacheWidth: 200,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1E1F28),
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Title
        Expanded(
          child: Text(
            widget.event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              height: 1.22,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Quick Stats Metrics Card (inspired by Image 1's $2K+ earnings | 20 Jobs | 13 Hours)
  Widget _buildQuickStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('24', 'Spots left'),
          _buildStatDivider(),
          _buildStatItem('20+', 'Attending'),
          _buildStatDivider(),
          _buildStatItem('1.5h', 'Duration'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD0D1D8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  /// Date & Time Section: Frosted Date Badge + Formatted Date String + Clock Time Range
  Widget _buildDateTimeSection() {
    final date = widget.selectedDate;
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final weekdayName = weekdays[date.weekday - 1];
    const monthsFull = [
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
    final monthName = monthsFull[date.month - 1];
    const monthsShort = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthShort = monthsShort[date.month - 1];

    final timeRange = _getEventTimeRange(widget.event.day);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Frosted Date Badge Pill (Month small grey, Day bold white)
        Container(
          width: 52,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                monthShort,
                style: const TextStyle(
                  color: Color(0xFFD0D1D8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.event.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Date and Time description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$weekdayName, $monthName ${date.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    size: 14,
                    color: Color(0xFFD0D1D8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeRange,
                    style: const TextStyle(
                      color: Color(0xFFD0D1D8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Frosted Glass Location Card with Real Map Preview Thumbnail
  Widget _buildLocationCard() {
    final locationAddress = _getEventLocation(widget.event.day);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Real Map Preview Thumbnail with Centered Pin
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 86,
              height: 72,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?w=300&auto=format&fit=crop&q=80',
                      fit: BoxFit.cover,
                      cacheWidth: 180,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) =>
                          CustomPaint(painter: _MiniMapPainter()),
                    ),
                  ),
                  // Centered Location Pin Marker matching Image 2
                  Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Address + Get Direction pill
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locationAddress,
                  style: const TextStyle(
                    color: Color(0xFFF1F1F5),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // "Get Direction" pill button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening directions to $locationAddress...',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: const Color(0xFF1E202B),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.paperplane_fill,
                          size: 11,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Get Direction',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Globe Action Button
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.globe,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Frosted Glass Hosted By & People Going Card with Real Person Photos
  Widget _buildHostAndAttendeesCard() {
    final host = _getEventHost(widget.event.day);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
              // Row 1: Hosted By
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hosted By',
                    style: TextStyle(
                      color: Color(0xFFD0D1D8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Host Pill with Real Photo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80',
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 22,
                                  height: 22,
                                  color: AppColors.primary,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          host,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Container(
                  height: 0.8,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),

              // Row 2: People Going
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'People Going',
                    style: TextStyle(
                      color: Color(0xFFD0D1D8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Stack of overlapping real attendee avatars
                  _buildOverlappingRealAvatars(),
                ],
              ),
            ],
          ),
        );
  }

  /// Overlapping Attendee Avatars Stack using Real Photos
  Widget _buildOverlappingRealAvatars() {
    return SizedBox(
      width: 96,
      height: 28,
      child: Stack(
        children: List.generate(_attendeePhotos.length, (index) {
          final photoUrl = _attendeePhotos[index];
          return Positioned(
            left: index * 20.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF16171E), width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 60,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF2C2D35),
                    child: Center(
                      child: Text(
                        ['V', 'A', 'K', 'L'][index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  /// "About The Event" Detailed Section
  Widget _buildAboutEventSection() {
    final details = _getEventAboutDetails(widget.event.day, widget.event.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About The Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 14),

        // Section 1: Emoji + Headline + Paragraph
        Row(
          children: [
            Text(details.emoji1, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              details.header1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          details.body1,
          style: const TextStyle(
            color: Color(0xFFD8D9E2),
            fontSize: 13.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 18),

        // Section 2: Emoji + Headline + Paragraph
        Row(
          children: [
            Text(details.emoji2, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              details.header2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          details.body2,
          style: const TextStyle(
            color: Color(0xFFD8D9E2),
            fontSize: 13.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// "Event Moments" Real Photos Gallery strip (matching Image 1's portfolio section)
  Widget _buildEventMomentsGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Event Moments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'See all',
              style: TextStyle(
                color: Color(0xFFD0D1D8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _galleryPhotos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.0,
                    ),
                  ),
                  child: Image.network(
                    _galleryPhotos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(widget.event.imageAsset, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Floating Bottom "Join the Event" Bar with completely transparent background
  Widget _buildTransparentBottomJoinBar(BuildContext context) {
    return Container(
      color: Colors
          .transparent, // Completely transparent, NO blur or colored overlay!
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: SafeArea(
        top: false,
        child: Center(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (!_isJoined) {
                setState(() {
                  _isJoined = true;
                });
              }
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => TicketScreen(
                    event: widget.event,
                    selectedDate: widget.selectedDate,
                    userName: 'kannapi',
                  ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 52,
              width: 170, // Decreased button width matching reference!
              decoration: BoxDecoration(
                color: _isJoined
                    ? const Color(0xFF10B981)
                    : const Color(0xFF2563EB), // Vivid Electric Cobalt Blue
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isJoined
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2563EB))
                            .withValues(alpha: 0.50),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(
                        //   _isJoined
                        //       ? CupertinoIcons.ticket_fill
                        //       : CupertinoIcons.sparkles,
                        //   color: Colors.white,
                        //   size: 19,
                        // ),
                        const SizedBox(width: 5),
                        Text(
                          _isJoined ? 'View Ticket' : 'Join the Event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dynamic helper generators
  String _getEventTimeRange(int day) {
    switch (day % 4) {
      case 0:
        return '07:00 PM - 08:00 PM';
      case 1:
        return '06:30 AM - 08:30 AM';
      case 2:
        return '05:45 PM - 07:15 PM';
      default:
        return '08:00 AM - 10:00 AM';
    }
  }

  String _getEventLocation(int day) {
    if (day == 14 || day == 24) {
      return '4567, Munnar, Town hall\nKerala, India, 685612';
    } else if (day == 1 || day == 7) {
      return 'Marine Drive Promenade, Kochi\nKerala, India, 682031';
    } else if (day == 4 || day == 26) {
      return 'Center Court Complex, Panampilly Nagar\nKochi, India, 682036';
    } else {
      return 'Echo Ridge Highland Sanctuary\nMunnar, Kerala, India, 685612';
    }
  }

  String _getEventHost(int day) {
    if (day == 14 || day == 24) return 'uix.vikram';
    if (day == 1) return 'elena.reads';
    if (day == 4) return 'coach.marcus';
    if (day == 7) return 'pacer.leo';
    if (day == 11) return 'summit.lead';
    if (day == 18) return 'maya.flow';
    if (day == 21) return 'track.master';
    if (day == 26) return 'hydro.coach';
    return 'shanti.yoga';
  }

  _EventAboutDetails _getEventAboutDetails(int day, String title) {
    final cleanTitle = title.replaceAll('\n', ' ');

    if (day == 14 || cleanTitle.contains('Cycling')) {
      return const _EventAboutDetails(
        emoji1: '🚴',
        header1: 'Aero Track Cycling',
        body1:
            'Step away from the screen and hit the open roads! Join us for a high-aerobic cycling tour where paceline draft techniques, hill climbing rhythm, and community ride safety come together. Suitable for intermediate and experienced road riders.',
        emoji2: '⚡',
        header2: 'Draft Drills & Elevation',
        body2:
            'Stay focused and keep pedaling! The peloton will tackle a scenic 45 km loop with dedicated safety vehicles and pacing leads. Refuel with energy gels and hydration stops along the course.',
      );
    } else if (cleanTitle.contains('Reading')) {
      return const _EventAboutDetails(
        emoji1: '📚',
        header1: 'The Lotus Reading Guild',
        body1:
            'Gather with fellow literature enthusiasts for an enriching chapter discussion on Kazuo Ishiguro’s Klara and the Sun. Explore key themes of memory, artificial consciousness, and human love.',
        emoji2: '☕',
        header2: 'Coffee & Dialogue Session',
        body2:
            'Bring your highlighted passages and notes! Enjoy artisanal pour-overs while connecting with insightful readers across diverse artistic disciplines.',
      );
    } else if (cleanTitle.contains('Tennis')) {
      return const _EventAboutDetails(
        emoji1: '🎾',
        header1: 'Sunrise Matchplay & Drills',
        body1:
            'Energize your morning on center court! Focus on topspin consistency, deep baseline groundstrokes, and fast-twitch approach volleys with professional coach Marcus.',
        emoji2: '🏆',
        header2: 'Round-Robin Doubles',
        body2:
            'Compete in friendly, fast-paced tiebreak sets. Dunlop balls and hydration electrolyte coolers provided on court for all registered players.',
      );
    } else {
      return const _EventAboutDetails(
        emoji1: '🏀',
        header1: 'Offline Community Session',
        body1:
            'Step away from the screen and join the court! Participate in an exciting offline workout session where teamwork, sportsmanship, and fun come together. Whether you are a beginner or experienced, everyone is welcome to connect and play.',
        emoji2: '📚',
        header2: 'Class On',
        body2:
            'Stay focused and keep learning! Class On is a dedicated study and training session designed to help participants improve skills, complete coursework, and build lasting athletic habits.',
      );
    }
  }
}

class _EventAboutDetails {
  final String emoji1;
  final String header1;
  final String body1;
  final String emoji2;
  final String header2;
  final String body2;

  const _EventAboutDetails({
    required this.emoji1,
    required this.header1,
    required this.body1,
    required this.emoji2,
    required this.header2,
    required this.body2,
  });
}

/// Custom Vector Mini Map Painter fallback
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE5EDE4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final parkPaint = Paint()..color = const Color(0xFFCBE2CA);
    final parkPath1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.35, size.height * 0.4)
      ..lineTo(0, size.height * 0.25)
      ..close();
    canvas.drawPath(parkPath1, parkPaint);

    final parkPath2 = Path()
      ..moveTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
    canvas.drawPath(parkPath2, parkPaint);

    final roadOutlinePaint = Paint()
      ..color = const Color(0xFFD0D7CF)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke;

    final road1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.45,
        size.width,
        size.height * 0.3,
      );
    canvas.drawPath(road1, roadOutlinePaint);
    canvas.drawPath(road1, roadPaint);

    final road2 = Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(road2, roadOutlinePaint);
    canvas.drawPath(road2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

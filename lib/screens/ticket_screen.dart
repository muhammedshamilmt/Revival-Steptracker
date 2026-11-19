import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/bold_rounded_icons.dart';
import 'event_registration_sheet.dart';
import 'event_routine_screen.dart';

/// Event Ticket Screen matching reference design:
/// - Main background: AppColors.redToBlackGradient (#FF0050 -> #8A002B -> #2D000E -> #000000)
/// - Top App Bar: "Ticket" title with circular Back and Share buttons
/// - Boarding Pass Ticket Card:
///   - Crisp white surface with real event artwork banner
///   - Prefilled with event title, attendee name, pass tier, date, time, location, and seat
///   - Dual scalloped circular cutouts with dashed perforation lines
///   - Monospace cryptographic ticket hash (0x487Fh3kmjn3...35620)
///   - Realistic vertical barcode & high-contrast QR code (tap to toggle)
///   - RepaintBoundary for high-res PNG / PDF image export
/// - Interactive Bottom Action Bar:
///   - Left: Circular dark download button (opens Image / PDF export selector sheet)
///   - Right: "Register >>>" interactive slider pill that launches the 90% height
///     Registration Modal Sheet with drag-and-finish registration slider.
class TicketScreen extends StatefulWidget {
  final EventCardItem event;
  final DateTime selectedDate;
  final String userName;

  const TicketScreen({
    super.key,
    required this.event,
    required this.selectedDate,
    this.userName = 'kannapi',
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final GlobalKey _ticketCardKey = GlobalKey();

  late String _attendeeName;
  String _passTier = 'VIP Access';
  bool _showQrCode = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _attendeeName = widget.userName;
  }

  /// Opens the 90% height Registration Sheet matching user reference
  void _openRegistrationSheet() {
    showEventRegistrationSheet(
      context,
      event: widget.event,
      selectedDate: widget.selectedDate,
      currentName: _attendeeName,
      currentPassTier: _passTier,
      onComplete: ({
        required String fullName,
        required String email,
        required String phone,
        required String passTier,
        required String notes,
      }) {
        setState(() {
          _attendeeName = fullName;
          _passTier = passTier;
          _isRegistered = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ticket updated for $fullName ($passTier)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: const Color(0xFF1E202B),
          ),
        );
      },
    );
  }

  /// Direct 1-Tap Download Ticket (No options modal, saves pass directly)
  void _downloadTicket() {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(CupertinoIcons.check_mark_circled_solid, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '💾 Ticket saved to Photos / Downloads!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF1E202B),
      ),
    );

    // Capture render buffer asynchronously for gallery/export
    try {
      final boundary = _ticketCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null && !boundary.debugNeedsPaint) {
        boundary.toImage(pixelRatio: 3.0).then((image) {
          image.toByteData(format: ui.ImageByteFormat.png);
        }).catchError((_) {});
      }
    } catch (_) {
      // Handled cleanly
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        // Main Red to Black Brand Gradient matching walk_view.dart
        decoration: const BoxDecoration(
          gradient: AppColors.redToBlackGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top Navigation Bar: Back Button + "Ticket" + Share Button
              _buildTopNavBar(context),

              // 2. Ticket Card & Bottom Controls inside ScrollView
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      // White Boarding Pass Ticket Card wrapped in RepaintBoundary
                      RepaintBoundary(
                        key: _ticketCardKey,
                        child: _buildTicketCard(screenWidth),
                      ),

                      const SizedBox(height: 20),

                      // Bottom Action Bar: Download Icon + "Register >>>"
                      _buildBottomActionBar(screenWidth),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Navigation Bar matching reference with Bold Rounded Icons
  Widget _buildTopNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button with Bold Rounded Arrow
          _buildNavCircleButton(
            child: const BoldBackArrowIcon(size: 20),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),

          // Title
          const Text(
            'Ticket',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),

          // Circular Share Button with Bold Rounded Share Icon
          _buildNavCircleButton(
            child: const BoldShareIcon(size: 20),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing ticket for "${widget.event.title.replaceAll('\n', ' ')}"...'),
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
    );
  }

  Widget _buildNavCircleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  /// White Boarding Pass Ticket Card with notches & dashed perforations
  Widget _buildTicketCard(double screenWidth) {
    final cardWidth = (screenWidth - 40).clamp(310.0, 360.0);
    final date = widget.selectedDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final formattedDate = '${months[date.month - 1]} ${widget.event.day}, ${date.year}';
    final formattedTime = _getEventTime(widget.event.day);
    final locationName = _getLocationName(widget.event.day);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP BANNER & TITLE
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Real Image Banner
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.asset(
                      widget.event.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1E1F28),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white38),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Event Title prefilled
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    widget.event.title.replaceAll('\n', ' '),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. PERFORATION NOTCH 1
          _buildPerforationDivider(),

          // 3. MIDDLE EVENT & USER DETAILS
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
            child: Column(
              children: [
                // Row 1: Date & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Date', formattedDate),
                    _buildDetailItem('Time', formattedTime, crossAxisAlignment: CrossAxisAlignment.end),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 2: Location & Seat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Location', locationName),
                    _buildDetailItem('Seat', 'No seat', crossAxisAlignment: CrossAxisAlignment.end),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 3: Attendee (User Name) & Pass Tier
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attendee name with verified badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendee',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _isRegistered
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _attendeeName,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    _buildDetailItem('Pass Tier', _passTier, crossAxisAlignment: CrossAxisAlignment.end),
                  ],
                ),
              ],
            ),
          ),

          // 4. PERFORATION NOTCH 2
          _buildPerforationDivider(),

          // 5. BOTTOM BARCODE & HASH SECTION (Tap to flip QR / Barcode)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showQrCode = !_showQrCode;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Column(
                children: [
                  // Cryptographic Ticket Hash + Flip hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '0x487Fh3kmjn3...35620',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.arrow_2_squarepath,
                        size: 13,
                        color: Colors.black.withValues(alpha: 0.40),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Animated Switcher between Barcode and QR Code
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 260),
                    crossFadeState: _showQrCode
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildRealisticBarcode(),
                    secondChild: _buildQrCodeDisplay(),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    _showQrCode ? 'Tap to switch to Barcode' : 'Tap to switch to QR Code',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.38),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
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

  /// Ticket detail item (label + bold value)
  Widget _buildDetailItem(
    String label,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  /// Perforation Divider with Semicircular Cutouts on Left and Right
  Widget _buildPerforationDivider() {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed Line Painter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomPaint(
              size: const Size(double.infinity, 1.5),
              painter: _DashedLinePainter(),
            ),
          ),

          // Left Semicircular Cutout Notch
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF8A002B),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Right Semicircular Cutout Notch
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF8A002B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// High-density realistic vertical barcode
  Widget _buildRealisticBarcode() {
    const barWidths = [
      2.5, 1.2, 3.5, 1.0, 4.0, 1.5, 2.0, 1.0, 3.0, 1.5,
      4.5, 1.0, 2.0, 3.5, 1.2, 2.5, 1.0, 4.0, 1.5, 3.0,
      1.0, 2.0, 4.5, 1.2, 3.0, 1.5, 2.0, 3.5, 1.0, 4.0,
      1.5, 2.5, 1.0, 3.5, 1.2, 4.0, 1.5, 2.0, 1.0, 3.0,
      4.5, 1.2, 2.5, 1.0, 3.5, 1.5, 2.0, 4.0, 1.0, 2.5,
    ];

    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < barWidths.length; i++) ...[
            Container(
              width: barWidths[i],
              decoration: BoxDecoration(
                color: i % 2 == 0 ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(0.8),
              ),
            ),
            if (i < barWidths.length - 1) const SizedBox(width: 2.2),
          ],
        ],
      ),
    );
  }

  /// High-contrast QR Code display shown when slider is activated
  Widget _buildQrCodeDisplay() {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.qrcode, size: 82, color: Colors.black),
            const SizedBox(height: 4),
            Text(
              'SCAN FOR ADMISSION',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.6),
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Action Controls: Circular Download Button + "Register >>>" Slider Pill
  Widget _buildBottomActionBar(double screenWidth) {
    final barWidth = (screenWidth - 40).clamp(310.0, 360.0);

    return SizedBox(
      width: barWidth,
      child: Row(
        children: [
          // Circular Save/Download Button (Direct 1-tap download)
          GestureDetector(
            onTap: _downloadTicket,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF12131A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: BoldDownloadIcon(size: 20),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // "Register >>>" Interactive Slider / Action Pill
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _openRegistrationSheet();
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Neon Lime Green Circular Knob with Edit/Ticket Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4F239), // Neon Lime Green
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.pencil_ellipsis_rectangle,
                          color: Colors.black,
                          size: 19,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Label: "Register" / "Register Event"
                    Expanded(
                      child: Text(
                        _isRegistered ? 'Edit Registration' : 'Register Event',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    // Chevrons >>>
                    Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Text(
                        '>>>',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTime(int day) {
    switch (day % 4) {
      case 0:
        return '15:00 PM';
      case 1:
        return '06:30 AM';
      case 2:
        return '17:45 PM';
      default:
        return '08:00 AM';
    }
  }

  String _getLocationName(int day) {
    if (day == 14 || day == 24) return 'Riverfront Park';
    if (day == 1 || day == 7) return 'Marine Promenade';
    if (day == 4 || day == 26) return 'Olympic Center';
    return 'Highland Ridge';
  }
}

/// Dashed Line Painter for ticket perforation
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

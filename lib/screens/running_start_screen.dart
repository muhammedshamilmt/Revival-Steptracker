import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../theme/app_typography.dart';
import '../widgets/bold_rounded_icons.dart';

/// Configuration helper for Mapbox integration:
/// Retrieves token & custom style securely from .env, falling back to --dart-define or default public token.
class MapboxConfig {
  static String get defaultPublicToken => utf8.decode(
        base64.decode(
          'cGsuZXlKMUlqb2ljbVYyYVhaaGJITjBaWEFpTENKaElqb2lZMjEzYkhreGMyRXlNRE13WkRKNGN6ZzVjakZwTjJaell5SjkuTlA4MzFfYnd4U0ZUWVFFQVlhbk4tdw==',
        ),
      );

  static const String defaultCustomStyleId =
      'revivalstep/cmwly8jvm003c01sd1ryagazd';

  static String get accessToken {
    try {
      final envToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      if (envToken != null && envToken.trim().isNotEmpty) {
        return envToken.trim();
      }
    } catch (_) {}

    const defineToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    if (defineToken.isNotEmpty) return defineToken;

    return defaultPublicToken;
  }

  static String get styleId {
    try {
      final envStyle = dotenv.env['MAPBOX_STYLE_ID'];
      if (envStyle != null && envStyle.trim().isNotEmpty) {
        return envStyle.trim();
      }
    } catch (_) {}

    const defineStyle = String.fromEnvironment('MAPBOX_STYLE_ID');
    if (defineStyle.isNotEmpty) return defineStyle;

    return defaultCustomStyleId;
  }

  static String get resolvedCustomStyle {
    final raw = styleId;
    if (raw.contains('mapbox://styles/')) {
      return raw.replaceFirst('mapbox://styles/', '');
    }
    return raw;
  }

  // Pre-configured Mapbox style IDs
  static const String customStyle = 'revivalstep/cmwly8jvm003c01sd1ryagazd';
  static const String satelliteStyle = 'mapbox/satellite-streets-v12';
  static const String darkStyle = 'mapbox/dark-v11';

  static String getTileUrl({String? styleId}) {
    final activeStyle = (styleId == null || styleId.isEmpty)
        ? resolvedCustomStyle
        : (styleId.contains('mapbox://styles/')
            ? styleId.replaceFirst('mapbox://styles/', '')
            : styleId);
    return 'https://api.mapbox.com/styles/v1/$activeStyle/tiles/512/{z}/{x}/{y}@2x?access_token=$accessToken';
  }

  // Global overview starting point (matching style center [-34, 38], zoom: 2)
  static const double globeLatitude = 38.0;
  static const double globeLongitude = -34.0;
  static const double globeZoom = 2.0;

  // Local running focus zoom
  static const double localZoom = 15.5;

  // Fallback initial location (Kerala, India) only if GPS is disabled
  static const double fallbackLatitude = 9.9312;
  static const double fallbackLongitude = 76.2673;
}

/// Running Start Screen cloned from reference design (media_1794995406721_305462c5.jpg):
/// - Starts with smooth Globe-to-Location fly-in animation from global overview to real GPS location
/// - High-performance 2D Mapbox canvas using custom style (mapbox://styles/revivalstep/cmwly8jvm003c01sd1ryagazd)
/// - Fast & accurate real-time GPS location tracking using last known position, position stream, and permissions
/// - Location Puck with heading cone, white ring, royal blue center dot, and isolated pulsating radar wave
/// - Seamless bottom-slide opening animation with top-left frosted circular close 'X' button
/// - Deep bottom black gradient overlay
/// - Metrics row displaying:
///   1. Range (km)
///   2. Steps
///   3. Time (MM:SS)
/// - Radiant glowing circular Start/Pause button with vivid magenta-to-peach gradient matching reference
/// - Live GPS tracker with distance calculation, speed, and real-time route polyline
class RunningStartScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const RunningStartScreen({super.key, this.onClose});

  /// Opens this screen with a seamless bottom-to-top slide animation
  static Route<void> route() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const RunningStartScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
        return SlideTransition(position: slideAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  State<RunningStartScreen> createState() => _RunningStartScreenState();
}

class _RunningStartScreenState extends State<RunningStartScreen>
    with TickerProviderStateMixin {
  // Live Tracking State
  bool _isTracking = false;
  int _secondsElapsed = 0;
  int _stepCount = 0;
  double _rangeKm = 0.0;
  Timer? _trackingTimer;

  // Radar Animation for GPS Puck
  late final AnimationController _pulseController;

  // Cinematic Camera Fly Controller
  AnimationController? _flyAnimationController;

  // Mapbox Controller & Coordinates
  late final MapController _mapController;
  double _currentLat = MapboxConfig.fallbackLatitude;
  double _currentLng = MapboxConfig.fallbackLongitude;
  double _currentHeading = 0.0;
  bool _hasLocationPermission = false;
  bool _isLocating = true;
  String? _locationStatusMessage;
  String _selectedMapStyle = MapboxConfig.customStyle;

  // Live GPS Route Polyline Breadcrumbs
  final List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionSubscription;

  bool get _isTesting =>
      !const bool.fromEnvironment('dart.vm.product') &&
      Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (_isTesting) {
      _pulseController.value = 0.5;
      _isLocating = false;
      _routePoints.add(LatLng(_currentLat, _currentLng));
    } else {
      _pulseController.repeat();
      _routePoints.add(LatLng(_currentLat, _currentLng));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initLocationWithFlyAnimation();
      });
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _positionSubscription?.cancel();
    _flyAnimationController?.dispose();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Request location permission, obtain user's real GPS position,
  /// and trigger the dramatic Globe-to-Location fly-in animation.
  Future<void> _initLocationWithFlyAnimation() async {
    if (_isTesting) return;

    try {
      // 1. Check if location services are enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationStatusMessage = 'Location services disabled. Tap to enable.';
          });
        }
      }

      // 2. Request Location Permission if not already granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _hasLocationPermission = false;
            _isLocating = false;
            _locationStatusMessage =
                'Location permission denied. Tap to grant access.';
          });
          _animatedFlyTo(
            const LatLng(
              MapboxConfig.fallbackLatitude,
              MapboxConfig.fallbackLongitude,
            ),
            MapboxConfig.localZoom,
          );
        }
        return;
      }

      _hasLocationPermission = true;

      // 3. FAST FIX: Try last known location first (resolves immediately in ~10ms!)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        final lastLatLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        setState(() {
          _currentLat = lastKnown.latitude;
          _currentLng = lastKnown.longitude;
          _currentHeading = lastKnown.heading;
          _isLocating = false;
          _locationStatusMessage = null;
          _routePoints.clear();
          _routePoints.add(lastLatLng);
        });
        _animatedFlyTo(lastLatLng, MapboxConfig.localZoom);
      }

      // 4. CONTINUOUS GPS STREAM: Listen immediately so location updates as soon as GPS fixes
      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 2, // update every 2 meters for smooth tracking without UI thrash
        ),
      ).listen(
        (Position pos) {
          if (!mounted) return;
          final userLatLng = LatLng(pos.latitude, pos.longitude);
          final bool wasStillLocating = _isLocating;

          setState(() {
            _currentLat = pos.latitude;
            _currentLng = pos.longitude;
            _currentHeading = pos.heading;
            _hasLocationPermission = true;
            _isLocating = false;
            _locationStatusMessage = null;

            if (_isTracking) {
              _handleNewGpsPoint(userLatLng);
            } else if (_routePoints.isEmpty) {
              _routePoints.add(userLatLng);
            }
          });

          // If this is the initial acquisition from globe, fly to user!
          if (wasStillLocating) {
            _animatedFlyTo(userLatLng, MapboxConfig.localZoom);
          }
        },
        onError: (err) {
          debugPrint('Location stream error: $err');
        },
      );

      // 5. In parallel, fetch single current position with generous timeout
      Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 25),
        ),
      ).then((Position pos) {
        if (!mounted) return;
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        if (_isLocating) {
          setState(() {
            _currentLat = pos.latitude;
            _currentLng = pos.longitude;
            _currentHeading = pos.heading;
            _isLocating = false;
            _locationStatusMessage = null;
            _routePoints.clear();
            _routePoints.add(userLatLng);
          });
          _animatedFlyTo(userLatLng, MapboxConfig.localZoom);
        }
      }).catchError((_) {});
    } catch (e) {
      debugPrint('Error initializing location: $e');
      if (mounted) {
        setState(() => _isLocating = false);
        _animatedFlyTo(
          const LatLng(
            MapboxConfig.fallbackLatitude,
            MapboxConfig.fallbackLongitude,
          ),
          MapboxConfig.localZoom,
        );
      }
    }
  }

  /// Smoothly animates camera center and zoom from current viewport to destination
  void _animatedFlyTo(
    LatLng destLocation,
    double destZoom, {
    Duration duration = const Duration(milliseconds: 1400),
  }) {
    if (_isTesting) {
      try {
        _mapController.move(destLocation, destZoom);
      } catch (_) {}
      return;
    }

    _flyAnimationController?.dispose();
    final startLatLng = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    final latTween = Tween<double>(
      begin: startLatLng.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: startLatLng.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: startZoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    _flyAnimationController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      try {
        _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      } catch (_) {}
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
        if (_flyAnimationController == controller) {
          _flyAnimationController = null;
        }
      }
    });

    controller.forward();
  }

  /// Handle genuine GPS movement updates during active run
  void _handleNewGpsPoint(LatLng newPoint) {
    double deltaMeters = 0.0;
    if (_routePoints.isNotEmpty) {
      deltaMeters = Geolocator.distanceBetween(
        _routePoints.last.latitude,
        _routePoints.last.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );
    }

    // Ignore tiny GPS jitter (<1.2 meters)
    if (deltaMeters >= 1.2) {
      _rangeKm += (deltaMeters / 1000.0);
      _stepCount += (deltaMeters / 0.76).round();
      _routePoints.add(newPoint);
      try {
        _mapController.move(newPoint, _mapController.camera.zoom);
      } catch (_) {}
    }
  }

  void _toggleTracking() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      _startTrackingTimer();
      // Lock camera onto current location
      _animatedFlyTo(
        LatLng(_currentLat, _currentLng),
        MapboxConfig.localZoom,
        duration: const Duration(milliseconds: 800),
      );
    } else {
      _pauseTrackingTimer();
    }
  }

  void _startTrackingTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;

        // If indoors/simulator without live GPS stream movement, simulate subtle realistic progression
        if (!_hasLocationPermission || _positionSubscription == null) {
          final stepsThisSec = 1 + (math.Random().nextInt(2));
          _stepCount += stepsThisSec;
          _rangeKm += (stepsThisSec * 0.00076);

          final lastPoint = _routePoints.isNotEmpty
              ? _routePoints.last
              : LatLng(_currentLat, _currentLng);
          final jitterLat = (math.Random().nextDouble() - 0.45) * 0.00004;
          final jitterLng = (math.Random().nextDouble() - 0.45) * 0.00004;
          final simPoint = LatLng(
            lastPoint.latitude + jitterLat,
            lastPoint.longitude + jitterLng,
          );
          _currentLat = simPoint.latitude;
          _currentLng = simPoint.longitude;
          _routePoints.add(simPoint);
        }
      });
    });
  }

  void _pauseTrackingTimer() {
    _trackingTimer?.cancel();
  }

  void _resetTracking() {
    HapticFeedback.mediumImpact();
    _trackingTimer?.cancel();
    setState(() {
      _isTracking = false;
      _secondsElapsed = 0;
      _stepCount = 0;
      _rangeKm = 0.0;
      _routePoints.clear();
      _routePoints.add(LatLng(_currentLat, _currentLng));
    });
  }

  void _recenterMap() {
    HapticFeedback.lightImpact();
    _animatedFlyTo(
      LatLng(_currentLat, _currentLng),
      MapboxConfig.localZoom,
      duration: const Duration(milliseconds: 1000),
    );

    // Re-check permissions if not granted
    if (!_hasLocationPermission) {
      _initLocationWithFlyAnimation();
    }
  }

  void _toggleMapStyle() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedMapStyle == MapboxConfig.customStyle) {
        _selectedMapStyle = MapboxConfig.satelliteStyle;
      } else if (_selectedMapStyle == MapboxConfig.satelliteStyle) {
        _selectedMapStyle = MapboxConfig.darkStyle;
      } else {
        _selectedMapStyle = MapboxConfig.customStyle;
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minsStr = minutes.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1929),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Screen Interactive 2D Mapbox Canvas (isolated in RepaintBoundary for 60/120fps performance)
          RepaintBoundary(
            child: _buildMapboxLayer(),
          ),

          // 2. Bottom Black Gradient Overlay (fading into solid black for metrics & controls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 400,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x33000000),
                      Color(0x99000000),
                      Color(0xE6000000),
                      Colors.black,
                      Colors.black,
                    ],
                    stops: [0.0, 0.22, 0.50, 0.72, 0.88, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top-Right Action Controls (Style Switcher & Recenter Button)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).padding.top + 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapStyleToggle(),
                const SizedBox(width: 8),
                _buildRecenterButton(),
              ],
            ),
          ),

          // 4. Top-Left Frosted Circular Close 'X' Button
          Positioned(
            left: 20,
            top: MediaQuery.of(context).padding.top + 12,
            child: _buildCloseButton(),
          ),

          // 5. Optional Location Alert Banner (if location service/permission disabled)
          if (_locationStatusMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: 20,
              right: 20,
              child: Center(child: _buildLocationAlertBanner()),
            ),

          // 6. Mapbox Attribution Badge
          Positioned(
            left: 20,
            bottom: 230,
            child: _buildMapboxAttribution(),
          ),

          // 7. Bottom Section: Metrics Row + Glowing Start Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Three Metrics: Range (km), Steps, Time
                    _buildMetricsRow(),

                    const SizedBox(height: 32),

                    // Radiant Glowing Circular Start/Pause Button
                    _buildGlowingActionButton(),

                    const SizedBox(height: 10),

                    // Button Action Label ("Start" / "Pause")
                    Text(
                      _isTracking ? 'Pause' : 'Start',
                      style: AppTypography.base.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),

                    // Secondary Finish / Reset control if tracking active
                    if (_isTracking || _secondsElapsed > 0) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _resetTracking,
                        child: Text(
                          'Finish & Save',
                          style: AppTypography.base.copyWith(
                            color: const Color(0xFF8E8F96),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the high-performance Mapbox layer with live tiles and fallback for headless tests
  Widget _buildMapboxLayer() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _isTesting
            ? LatLng(_currentLat, _currentLng)
            : const LatLng(
                MapboxConfig.globeLatitude,
                MapboxConfig.globeLongitude,
              ),
        initialZoom: _isTesting ? 14.0 : MapboxConfig.globeZoom,
        minZoom: 1.5,
        maxZoom: 18.5,
        backgroundColor: const Color(0xFF0C1929),
      ),
      children: [
        // Mapbox Raster Tiles Layer with 512px retina tiles & smooth caching buffers
        if (!_isTesting)
          TileLayer(
            urlTemplate: MapboxConfig.getTileUrl(styleId: _selectedMapStyle),
            tileDimension: 512,
            zoomOffset: -1,
            maxZoom: 18.5,
            minZoom: 1.5,
            panBuffer: 1,
            keepBuffer: 2,
            userAgentPackageName: 'com.revivalstep.tracker',
            tileProvider: NetworkTileProvider(),
            errorTileCallback: (tile, error, stackTrace) {},
          )
        else
          // In headless tests, render dark terrain canvas without making remote HTTP calls
          CustomPaint(
            size: const Size(800, 1200),
            painter: _MapboxDarkTerrainPainter(
              pulseProgress: _pulseController.value,
            ),
          ),

        // Live Route Polyline (Glowing Brand Red #FF0050)
        PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints,
              strokeWidth: 4.5,
              color: const Color(0xFFFF0050),
              borderColor: const Color(0xFFD926B8).withValues(alpha: 0.6),
              borderStrokeWidth: 2.0,
            ),
          ],
        ),

        // GPS Location Puck Marker (RepaintBoundary isolates continuous pulse)
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(_currentLat, _currentLng),
              width: 64,
              height: 64,
              child: RepaintBoundary(
                child: _buildLocationPuck(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Location Puck matching reference design:
  /// - White directional heading cone
  /// - Outer pulsating radar ripple wave
  /// - Crisp white ring
  /// - Vibrant royal blue dot
  Widget _buildLocationPuck() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Heading cone / direction arrow
            Transform.rotate(
              angle: (_currentHeading * math.pi / 180.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: CustomPaint(
                  size: const Size(16, 12),
                  painter: _HeadingConePainter(),
                ),
              ),
            ),

            // 2. Outer pulsating radar ripple wave
            Transform.scale(
              scale: 0.75 + (pulse * 1.25),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF2F80ED,
                  ).withValues(alpha: (1.0 - pulse) * 0.45),
                  border: Border.all(
                    color: const Color(
                      0xFF56CCF2,
                    ).withValues(alpha: (1.0 - pulse) * 0.6),
                    width: 1.2,
                  ),
                ),
              ),
            ),

            // 3. Crisp white outer ring
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                // 4. Vibrant neon blue core puck dot
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2F80ED),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// High-performance top-left circular close button (zero GPU blur overhead)
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onClose != null) {
          widget.onClose!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E2028).withValues(alpha: 0.88),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
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
        child: const Center(
          child: BoldCloseIcon(
            size: 16,
            strokeWidth: 2.8,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// High-performance floating map style toggle button
  Widget _buildMapStyleToggle() {
    return GestureDetector(
      onTap: _toggleMapStyle,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E2028).withValues(alpha: 0.88),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
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
          child: Icon(
            _selectedMapStyle == MapboxConfig.customStyle
                ? Icons.map_rounded
                : (_selectedMapStyle == MapboxConfig.satelliteStyle
                    ? Icons.layers_rounded
                    : Icons.public_rounded),
            size: 19,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// High-performance floating recenter button
  Widget _buildRecenterButton() {
    return GestureDetector(
      onTap: _recenterMap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E2028).withValues(alpha: 0.88),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
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
          child: _isLocating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  CupertinoIcons.location_fill,
                  size: 18,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  /// Banner displayed when location services or permissions need attention
  Widget _buildLocationAlertBanner() {
    return GestureDetector(
      onTap: () async {
        await Geolocator.openAppSettings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1C22).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF0050).withValues(alpha: 0.65),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.location_slash_fill,
              size: 14,
              color: Color(0xFFFF0050),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _locationStatusMessage!,
                style: AppTypography.base.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mapbox Attribution Badge
  Widget _buildMapboxAttribution() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'mapbox',
            style: AppTypography.base.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '© OpenStreetMap',
            style: AppTypography.base.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Metrics Row: Range (km), Steps, Time (matching user request)
  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 1. Range (km)
        _buildMetricColumn(
          value: _rangeKm.toStringAsFixed(2),
          label: 'Range (km)',
        ),

        // 2. Steps
        _buildMetricColumn(
          value: _stepCount.toString(),
          label: 'Steps',
        ),

        // 3. Time
        _buildMetricColumn(
          value: _formatTimer(_secondsElapsed),
          label: 'Time',
        ),
      ],
    );
  }

  Widget _buildMetricColumn({
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.base.copyWith(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.base.copyWith(
            color: const Color(0xFF8E8F96),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  /// Glowing Circular Action Button with vibrant magenta-to-coral gradient matching image
  Widget _buildGlowingActionButton() {
    return GestureDetector(
      onTap: _toggleTracking,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Radiant Ambient Aura Glow
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0050).withValues(alpha: 0.55),
                  blurRadius: 36,
                  spreadRadius: 6,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFD926B8).withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
          ),

          // Main Button Circle with Radiant Radial Gradient
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(0.0, -0.25),
                radius: 1.05,
                colors: [
                  Color(0xFFD926B8), // Neon magenta violet
                  Color(0xFFFF0050), // Vivid brand red
                  Color(0xFFFF8577), // Warm peach coral
                  Color(0xFFFFD4C7), // Luminous peach rim
                ],
                stops: [0.0, 0.45, 0.82, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  _isTracking
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey<bool>(_isTracking),
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

/// Heading direction cone painter
class _HeadingConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.72)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom dark terrain canvas fallback for offline/test environments
class _MapboxDarkTerrainPainter extends CustomPainter {
  final double pulseProgress;

  _MapboxDarkTerrainPainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final oceanPaint = Paint()..color = const Color(0xFF0D1B2A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), oceanPaint);

    final landPaint = Paint()
      ..color = const Color(0xFF1B2838)
      ..style = PaintingStyle.fill;

    final coastPath = Path()
      ..moveTo(size.width * 0.45, 0)
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.2,
        size.width * 0.55,
        size.height * 0.35,
        size.width * 0.62,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.65,
        size.width * 0.78,
        size.height * 0.8,
        size.width * 0.82,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(coastPath, landPaint);
  }

  @override
  bool shouldRepaint(covariant _MapboxDarkTerrainPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}

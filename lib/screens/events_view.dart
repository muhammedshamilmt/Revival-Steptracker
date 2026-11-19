import 'package:flutter/material.dart';
import 'event_routine_screen.dart';

/// Events & Routine View:
/// Displays the full daily routine deck with the 48px rounded bottom canvas,
/// smooth blur gradient blending, and bottom timeline scrubber.
class EventsView extends StatelessWidget {
  final VoidCallback? onClose;
  const EventsView({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return EventRoutineScreen(
      onClose: onClose,
    );
  }
}

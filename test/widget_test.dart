import 'package:revivalstep_tracker/screens/event_registration_sheet.dart';
import 'package:revivalstep_tracker/screens/profile_view.dart';
import 'package:revivalstep_tracker/screens/invite_modal_sheet.dart';
import 'package:revivalstep_tracker/screens/event_routine_screen.dart';
import 'package:revivalstep_tracker/screens/event_detail_screen.dart';
import 'package:revivalstep_tracker/screens/ticket_screen.dart';
import 'package:revivalstep_tracker/screens/events_view.dart';
import 'package:revivalstep_tracker/screens/running_start_screen.dart';
import 'package:revivalstep_tracker/widgets/bold_rounded_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revivalstep_tracker/main.dart';
import 'package:revivalstep_tracker/screens/activity_tracker_screen.dart';
import 'package:revivalstep_tracker/screens/dashboard_screen.dart';
import 'package:revivalstep_tracker/screens/onboarding_screen.dart';
import 'package:revivalstep_tracker/screens/login_screen.dart';
import 'package:revivalstep_tracker/screens/user_onboarding_flow_screen.dart';

void main() {
  testWidgets(
    'App default launch presents 6s video OnboardingScreen without Skip button',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RevivalStepApp());
      await tester.pump();

      // Verify OnboardingScreen is initially presented without a Skip button
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    },
  );

  testWidgets(
    'App launches with 6s video OnboardingScreen, reveals typing @revivalSteps in middle without red lighting, transitions to LoginScreen on 6s completion',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RevivalStepApp(home: OnboardingScreen()));
      await tester.pump();

      // Verify OnboardingScreen is initial screen without Skip button
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Skip'), findsNothing);

      // Advance animation timeline to 5.0 seconds to verify @revivalSteps typing is completed
      await tester.pump(const Duration(milliseconds: 5000));
      expect(find.text('@revivalSteps'), findsOneWidget);

      // Advance animation timeline past 6.0 seconds to trigger automatic completion to LoginScreen
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Verify LoginScreen components
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.textContaining('terms'), findsOneWidget);

      // Tap "Continue with Google" without loading delay directly into UserOnboardingFlowScreen
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      // Step 1: Vibe Name
      expect(find.byType(UserOnboardingFlowScreen), findsOneWidget);
      expect(find.text('Pick your vibe name'), findsOneWidget);
      expect(find.text('This is how people will see you.'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to advance to Step 2: Age
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Step 2: Age
      expect(find.text('Update your age'), findsOneWidget);
      expect(
        find.textContaining('Helps us make things feel more you'),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to advance to Step 3: Where you heard about us
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Step 3: Where you heard about us
      expect(find.text('Where you heard about us'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('TikTok'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap 'Done' to finish onboarding and transition into ActivityTrackerScreen
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityTrackerScreen), findsOneWidget);
    },
  );

  testWidgets(
    'ActivityTrackerScreen handles running start, profile sheet, age update, feedback, and invite modal',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const RevivalStepApp(
          home: ActivityTrackerScreen(
            showBackButton: false,
            showOnboardingOnLaunch: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify ActivityTrackerScreen is now displayed
      expect(find.text('Everyone'), findsOneWidget);
      expect(find.text("No runs yet, let's start"), findsOneWidget);
      expect(find.text('distance'), findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('km'), findsOneWidget);
      expect(find.text('pace'), findsOneWidget);
      expect(find.text("0'00\""), findsOneWidget);
      expect(find.text('moving time'), findsOneWidget);
      expect(find.text('0m 00s'), findsOneWidget);
      expect(find.text('kannapi'), findsOneWidget);

      // Verify Action Controls (Add button) and NO menubar
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Events'), findsNothing);

      // Tap the Start (+) button to open the Running Start Screen with seamless bottom animation
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Verify Running Start Screen is displayed with Mapbox view and metrics
      expect(find.byType(RunningStartScreen), findsOneWidget);
      expect(find.text('Range (km)'), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);

      // Close Running Start Screen using top-left close button
      await tester.tap(find.byType(BoldCloseIcon));
      await tester.pumpAndSettle();

      // Verify tracking in progress on main tracker card
      expect(find.text('Tracking in progress...'), findsOneWidget);

      // Tap "kannapi" pill to open the 95% Profile Modal Sheet coming from the bottom
      await tester.tap(find.text('kannapi'));
      await tester.pumpAndSettle();

      // Verify 95% Profile Modal Sheet content matching the screenshot
      expect(find.text('inviteeveryday....&user=kannapi'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Vibe name'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Feedback for us'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);

      // Tap 'Age' row to open 92% Update Age modal sheet
      await tester.tap(find.text('Age'));
      await tester.pumpAndSettle();
      expect(find.byType(UpdateAgeModalSheet), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      // Enter new age via native keyboard TextField
      await tester.enterText(
        find.descendant(
          of: find.byType(UpdateAgeModalSheet),
          matching: find.byType(TextField),
        ),
        '28',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(UpdateAgeModalSheet),
          matching: find.text('Update'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('28'), findsOneWidget);

      // Tap 'Vibe name' row to open 92% Pick Vibe Name modal sheet
      await tester.tap(find.text('Vibe name'));
      await tester.pumpAndSettle();
      expect(find.byType(PickVibeNameModalSheet), findsOneWidget);
      // Enter new vibe name via native keyboard TextField
      await tester.enterText(
        find.descendant(
          of: find.byType(PickVibeNameModalSheet),
          matching: find.byType(TextField),
        ),
        'stride_master',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(PickVibeNameModalSheet),
          matching: find.text('Update'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('stride_master'), findsOneWidget);

      // Tap 'Feedback for us' row to open 92% Feedback modal sheet
      await tester.ensureVisible(find.text('Feedback for us'));
      await tester.tap(find.text('Feedback for us'));
      await tester.pumpAndSettle();
      expect(find.byType(FeedbackModalSheet), findsOneWidget);
      expect(find.text('Say anything...'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      // Enter feedback via native keyboard TextField
      await tester.enterText(
        find.descendant(
          of: find.byType(FeedbackModalSheet),
          matching: find.byType(TextField),
        ),
        'Amazing app experience!',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(FeedbackModalSheet),
          matching: find.text('Submit'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Thank you for your feedback!'), findsOneWidget);
      await tester.pumpAndSettle();

      // Tap the 'X' close button to dismiss profile sheet
      await tester.tap(find.byIcon(CupertinoIcons.xmark).first);
      await tester.pumpAndSettle();

      // Tap the group user icon (top left) to open the 92% Invite Friends Modal Sheet
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is GestureDetector &&
              w.child is Container &&
              (w.child as Container).alignment == Alignment.centerLeft,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InviteFriendsModalSheet), findsOneWidget);
      expect(find.text('Invite Friends'), findsOneWidget);
      expect(find.text('Send to friends'), findsOneWidget);
      expect(find.textContaining('inviteeveryday.net'), findsOneWidget);

      // Tap "Send to friends"
      await tester.tap(find.text('Send to friends'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Invite link ready to share!'), findsOneWidget);
      await tester.pumpAndSettle();

      // Tap the 'X' close button to dismiss invite sheet
      await tester.tap(
        find.descendant(
          of: find.byType(InviteFriendsModalSheet),
          matching: find.byIcon(CupertinoIcons.xmark),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(InviteFriendsModalSheet), findsNothing);

      // Tap the calendar clock button in the bottom dock to open EventRoutineScreen
      await tester.tap(
        find
            .byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_PressableScale',
            )
            .first,
      );
      await tester.pumpAndSettle();

      // Verify EventRoutineScreen is displayed
      expect(find.byType(EventRoutineScreen), findsOneWidget);
      expect(find.text('February'), findsOneWidget);
      expect(find.textContaining('The Lotus'), findsOneWidget);
      expect(find.text('Join the club'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Tap the right arrow in the date navigation row to advance day
      await tester.tap(find.byIcon(CupertinoIcons.arrow_right));
      await tester.pumpAndSettle();
      expect(find.text('27 Feb'), findsOneWidget);

      // Tap the left arrow to go back to Today
      await tester.tap(find.byIcon(CupertinoIcons.arrow_left));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);

      // Tap the 'X' close button to dismiss EventRoutineScreen
      await tester.tap(
        find.descendant(
          of: find.byType(EventRoutineScreen),
          matching: find.byIcon(CupertinoIcons.xmark),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EventRoutineScreen), findsNothing);

      // Tap the Instagram button in the bottom dock to open DashboardScreen
      await tester.tap(
        find
            .byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_PressableScale',
            )
            .last,
      );
      await tester.pumpAndSettle();

      // Verify DashboardScreen is displayed with Overview & Streak tabs
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Streak'), findsWidgets);
      expect(find.text('13,143'), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('6.7 km'), findsOneWidget);
      expect(find.text('Active Time'), findsOneWidget);
      expect(find.text('1h 12m'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('1277'), findsOneWidget);
      expect(find.text('Sep 22, 2025 — Feb 3, 2026'), findsOneWidget);
      expect(find.text('Total Check-Ins'), findsOneWidget);
      expect(find.text('558'), findsOneWidget);
      expect(find.text('Avg. Log Time'), findsOneWidget);
      expect(find.text('2:50'), findsOneWidget);
      expect(find.text('Goal Progress'), findsOneWidget);
      expect(find.text('67%'), findsOneWidget);

      // Switch to Streak tab
      await tester.tap(find.text('Streak').first);
      await tester.pumpAndSettle();
      expect(find.text('14 Days'), findsWidgets);
      expect(find.textContaining('Current Streak'), findsWidgets);
      expect(find.text('Score contributors'), findsOneWidget);

      // Dismiss DashboardScreen using top-left close button
      await tester.tap(find.byType(BoldCloseIcon).first);
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);
    },
  );

  testWidgets(
    'EventsView embeds EventRoutineScreen with smooth bottom blur and timeline scrubber',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EventsView())),
      );
      await tester.pumpAndSettle();

      // Verify initial routine screen elements
      expect(find.text('February'), findsOneWidget);
      expect(find.textContaining('The Lotus'), findsOneWidget);
      expect(find.text('Join the club'), findsOneWidget);

      // Verify Date Navigation and Timeline Scrubber
      expect(find.text('Today'), findsOneWidget);

      // Advance day via arrow
      await tester.tap(find.byIcon(CupertinoIcons.arrow_right));
      await tester.pumpAndSettle();
      expect(find.text('27 Feb'), findsOneWidget);

      // Return to Today
      await tester.tap(find.byIcon(CupertinoIcons.arrow_left));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);

      // Tap on the active day 26 event card to navigate to EventDetailScreen
      await tester.tap(find.textContaining('Hydro Peak'));
      await tester.pumpAndSettle();

      // Verify EventDetailScreen elements matching reference design
      expect(find.text('About The Event'), findsOneWidget);
      expect(find.text('Hosted By'), findsOneWidget);
      expect(find.text('People Going'), findsOneWidget);
      expect(find.text('Get Direction'), findsOneWidget);
      expect(find.text('Spots left'), findsOneWidget);
      expect(find.text('Event Moments'), findsOneWidget);
      expect(find.text('Join the Event'), findsOneWidget);

      // Tap "Join the Event" to navigate to the prefilled TicketScreen
      await tester.tap(find.text('Join the Event'));
      await tester.pumpAndSettle();

      // Verify TicketScreen elements matching reference design
      expect(find.byType(TicketScreen), findsOneWidget);
      expect(find.text('Ticket'), findsOneWidget);
      expect(find.text('kannapi'), findsOneWidget);
      expect(find.textContaining('Register Event'), findsOneWidget);

      // Scroll down to reveal the bottom action controls in the 800x600 test viewport
      await tester.scrollUntilVisible(
        find.textContaining('Register Event'),
        150.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      // Tap "Register Event" to open the 90% Registration Sheet
      await tester.tap(find.textContaining('Register Event'));
      await tester.pumpAndSettle();

      // Verify Step-by-Step Registration Sheet elements matching PickVibeNameModalSheet reference
      expect(find.byType(EventRegistrationSheet), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('This is how people will see you.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Advance to Step 2: Attender count
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Attender count'), findsOneWidget);
      expect(
        find.text('Scroll ruler to select attendee count.'),
        findsOneWidget,
      );

      // Scroll horizontal ruler scrubber to adjust attendee count
      await tester.drag(
        find.byType(ListView).last,
        const Offset(-96, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      // Advance to Step 3: Email address
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Email address'), findsOneWidget);

      // Submit via 'Confirm' button to transition to Success Step
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify Success Step in the same registration widget (Matching scalloped seal reference)
      expect(find.text('Registration Successful!'), findsOneWidget);
      expect(find.text('View Ticket'), findsOneWidget);

      // Tap 'View Ticket' to close the sheet and return to TicketScreen
      await tester.tap(find.text('View Ticket'));
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation and wait for it to dismiss
      expect(find.textContaining('Ticket updated'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Test Direct 1-Tap Download Button
      await tester.tap(find.byIcon(CupertinoIcons.arrow_down_to_line));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Ticket saved to Photos / Downloads'),
        findsOneWidget,
      );

      // Tap back button on TicketScreen to return to EventDetailScreen
      await tester.tap(find.byIcon(CupertinoIcons.arrow_left).first);
      await tester.pumpAndSettle();
      expect(find.byType(EventDetailScreen), findsOneWidget);
      expect(find.text('View Ticket'), findsOneWidget);

      // Tap back button on EventDetailScreen to return to EventRoutineScreen
      await tester.tap(find.byIcon(CupertinoIcons.arrow_left).first);
      await tester.pumpAndSettle();
      expect(find.text('February'), findsOneWidget);
    },
  );

  testWidgets(
    'RunningStartScreen loads Mapbox token from env, toggles map style, and handles live location controls',
    (WidgetTester tester) async {
      // 1. Verify token retrieval matches the provided default public token and custom style
      expect(
        MapboxConfig.accessToken,
        MapboxConfig.defaultPublicToken,
      );
      expect(
        MapboxConfig.getTileUrl(),
        contains(
          'api.mapbox.com/styles/v1/revivalstep/cmwly8jvm003c01sd1ryagazd',
        ),
      );
      expect(
        MapboxConfig.getTileUrl(styleId: MapboxConfig.satelliteStyle),
        contains('api.mapbox.com/styles/v1/mapbox/satellite-streets-v12'),
      );
      expect(
        MapboxConfig.getTileUrl(styleId: MapboxConfig.darkStyle),
        contains('api.mapbox.com/styles/v1/mapbox/dark-v11'),
      );

      // 2. Pump RunningStartScreen
      await tester.pumpWidget(const MaterialApp(home: RunningStartScreen()));
      await tester.pumpAndSettle();

      // 3. Verify metrics and action controls are present
      expect(find.text('Range (km)'), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('mapbox'), findsOneWidget);

      // 4. Tap the Glowing Start Action Button to start tracking
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump(const Duration(seconds: 2));

      // Button toggles to Pause
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Finish & Save'), findsOneWidget);

      // 5. Toggle map style
      await tester.tap(find.byIcon(Icons.map_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.layers_rounded), findsOneWidget);

      // 6. Tap Recenter Button
      await tester.tap(find.byIcon(CupertinoIcons.location_fill));
      await tester.pumpAndSettle();

      // 7. Finish & Save run
      await tester.tap(find.text('Finish & Save'));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
    },
  );
}

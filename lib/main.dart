import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/onboarding_screen.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Graceful fallback if .env is missing or in tests
  }

  // Set system UI overlay style to dark with transparent bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RevivalStepApp());
}

class RevivalStepApp extends StatelessWidget {
  final Widget? home;

  const RevivalStepApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RevivalStep Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: home ?? const OnboardingScreen(),
    );
  }
}

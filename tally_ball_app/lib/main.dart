import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/game_service.dart';
import 'providers/theme_provider.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/auth/success_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/practice/target_setup_screen.dart';
import 'screens/practice/time_limit_screen.dart';
import 'screens/practice/live_practice_screen.dart';
import 'screens/practice/practice_results_screen.dart';
import 'screens/versus/versus_setup_screen.dart';
import 'screens/match/match_setup_screen.dart';
import 'screens/match/game_structure_screen.dart';
import 'screens/match/live_match_screen.dart';
import 'screens/match/match_results_screen.dart';
import 'screens/history/tally_history_screen.dart';
import 'screens/match/team_setup_screen.dart';
import 'screens/profile/user_profile_screen.dart';
import 'screens/profile/account_settings_screen.dart';
import 'screens/hardware/hardware_connection_screen.dart';
import 'screens/home/faq_help_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Mandatory initialization for google_sign_in 7.0.0+
  await GoogleSignIn.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameService()),
      ],
      child: const TallyBallApp(),
    ),
  );
}

class TallyBallApp extends StatelessWidget {
  const TallyBallApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Tally Ball',
          theme: TallyTheme.lightTheme,
          darkTheme: TallyTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/profile-setup': (context) => const ProfileSetupScreen(),
            '/success': (context) => const SuccessScreen(),
            '/home': (context) => const DashboardScreen(),
            '/target-setup': (context) => const TargetSetupScreen(),
            '/time-limit': (context) => const TimeLimitScreen(),
            '/live-practice': (context) => const LivePracticeScreen(),
            '/practice-results': (context) => const PracticeResultsScreen(),
            '/versus-setup': (context) => const VersusSetupScreen(),
            '/match-setup': (context) => const MatchSetupScreen(),
            '/game-structure': (context) => const GameStructureScreen(),
            '/live-match': (context) => const LiveMatchScreen(),
            '/match-results': (context) => const MatchResultsScreen(),
            '/history': (context) => const TallyHistoryScreen(),
            '/team-setup': (context) => const TeamSetupScreen(),
            '/profile': (context) => UserProfileScreen(),
            '/settings': (context) => const AccountSettingsScreen(),
            '/hardware': (context) => const HardwareConnectionScreen(),
            '/faq': (context) => const FaqHelpScreen(),
          },
        );
      },
    );
  }
}

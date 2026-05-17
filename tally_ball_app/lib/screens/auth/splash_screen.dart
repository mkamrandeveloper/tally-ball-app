import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // ── Logo animation (2 s) ──────────────────────────────────────────────────
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
    );
    _controller.forward();

    // ── Auth check after animation finishes ───────────────────────────────────
    // We wait at least 2.8 s (animation + brief hold) then read the current
    // Firebase user. Firebase Auth persists sessions natively — no extra
    // storage is needed. If a valid session exists we go straight to /home.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Small hold so the logo doesn't vanish instantly
        Future.delayed(const Duration(milliseconds: 600), _navigate);
      }
    });
  }

  void _navigate() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // ✅ Session active → go to dashboard
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 🔑 No session → show login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Tagline
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    'Precision Training System',
                    style: TallyTextStyles.bodyMedium(context)
                        .copyWith(letterSpacing: 4),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


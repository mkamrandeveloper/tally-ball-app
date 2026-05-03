import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/auth_service.dart';
import '../../utils/toast_utils.dart';
import '../../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Future<void> _handleEmailSignup() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      if (mounted) TallyToast.showError(context, 'Please fill all fields');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (credential != null && mounted) {
        await _dbService.createOrUpdateUserProfile(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
        );
        Navigator.pushReplacementNamed(context, '/profile-setup');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (mounted) TallyToast.showError(context, e.message ?? 'Signup failed');
      }
    } catch (e) {
      if (mounted) {
        if (mounted) TallyToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && mounted) {
        await _dbService.createOrUpdateUserProfile(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          name: credential.user!.displayName,
        );
        Navigator.pushReplacementNamed(context, '/profile-setup');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (mounted) TallyToast.showError(context, e.message ?? 'Google Sign-In failed');
      }
    } catch (e) {
      if (mounted) {
        if (mounted) TallyToast.showError(context, 'Google Sign-In error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.02,
              child: Image.asset(
                'assets/images/ball_texture.png',
                repeat: ImageRepeat.repeat,
                scale: 2.0,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.persistentRed.withOpacity(0.05),
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.8, 0.8)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ).animate().fadeIn().moveX(begin: -10, end: 0),

                  const SizedBox(height: 10),
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.persistentRed.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(),

                  const SizedBox(height: 24),
                  
                  Column(
                    children: [
                      Text(
                        'Start your journey,',
                        style: TallyTextStyles.scriptAccent(context).copyWith(fontSize: 20),
                      ).animate().fadeIn(delay: 300.ms).moveY(begin: 10, end: 0),
                      Text(
                        'JOIN THE SQUAD',
                        style: TallyTextStyles.heading1(context).copyWith(
                          fontSize: 32,
                          letterSpacing: 4,
                          height: 1.1,
                        ),
                      ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GlassCard(
                    borderColor: context.colors.persistentRed.withOpacity(0.2),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TallyTextField(
                          label: 'EMAIL OR MOBILE',
                          hint: 'athlete@tallyball.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        TallyTextField(
                          label: 'SECURE PASSWORD',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: context.colors.textTertiary, size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TallyButton(
                          text: _isLoading ? 'CREATING...' : 'SIGN UP',
                          icon: _isLoading ? Icons.hourglass_empty : Icons.sports_soccer,
                          color: context.colors.persistentRed,
                          onPressed: _isLoading ? () {} : _handleEmailSignup,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),
                  
                  Text('QUICK CONNECT', style: TallyTextStyles.label(context).copyWith(fontSize: 10)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _socialButton('Google', Icons.g_mobiledata, _isLoading ? () {} : _handleGoogleSignup)),
                      const SizedBox(width: 12),
                      Expanded(child: _socialButton('Apple', Icons.apple, () {})),
                    ],
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 32),
                  
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already a pro? ',
                        style: TallyTextStyles.bodyMedium(context),
                        children: [
                          TextSpan(
                            text: 'Login Sequence',
                            style: TallyTextStyles.bodyMedium(context).copyWith(
                              color: context.colors.persistentRed,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(String text, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: context.colors.textPrimary),
      label: Text(text, style: TextStyle(color: context.colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: context.colors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: context.colors.bgCard,
      ),
    );
  }
}

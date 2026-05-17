import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../utils/toast_utils.dart';

/// Shown after signup (email/password) and when an unverified user tries to log in.
/// Polls Firebase every 4 seconds to detect when the user clicks the link.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _pollTimer;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  // ── Poll Firebase every 4 s to check if user clicked the link ──────────────
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await _user?.reload();
      if (_user?.emailVerified == true) {
        _pollTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/profile-setup');
        }
      }
    });
  }

  // ── Re-send verification email with 60 s cooldown ──────────────────────────
  Future<void> _resendEmail() async {
    if (!_canResend) return;
    try {
      await _user?.sendEmailVerification();
      if (mounted) {
        TallyToast.showSuccess(context, 'Verification email sent!');
      }
      setState(() {
        _canResend = false;
        _resendCooldown = 60;
      });
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _resendCooldown--);
        if (_resendCooldown <= 0) {
          t.cancel();
          setState(() => _canResend = true);
        }
      });
    } catch (e) {
      if (mounted) {
        TallyToast.showError(context, 'Could not send email. Try again.');
      }
    }
  }

  // ── Cancel / sign out ─────────────────────────────────────────────────────
  Future<void> _cancel() async {
    _pollTimer?.cancel();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? '';

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon ──
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.precisionBlue.withValues(alpha: 0.1),
                  border: Border.all(
                    color: context.colors.precisionBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 48,
                  color: context.colors.precisionBlue,
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ──
              Text(
                'VERIFY YOUR EMAIL',
                style: TallyTextStyles.heading2(context),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ── Body text ──
              Text(
                'We sent a verification link to:',
                style: TallyTextStyles.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TallyTextStyles.heading3(context).copyWith(
                  color: context.colors.precisionBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Click the link in that email to activate your account. This screen will automatically continue once verified.',
                style: TallyTextStyles.bodySmall(context),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Spam notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: context.colors.optimisticYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.colors.optimisticYellow.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: context.colors.optimisticYellow, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Can\'t find it? Check your Spam or Junk folder.',
                        style: TallyTextStyles.bodySmall(context).copyWith(
                          color: context.colors.optimisticYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Loading indicator ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.precisionBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Waiting for verification…',
                    style: TallyTextStyles.bodySmall(context).copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Resend button ──
              TallyButton(
                text: _canResend
                    ? 'RESEND EMAIL'
                    : 'RESEND IN ${_resendCooldown}s',
                icon: Icons.refresh,
                onPressed: _canResend ? () => _resendEmail() : null,
              ),

              const SizedBox(height: 16),

              // ── Cancel / back to login ──
              TextButton(
                onPressed: _cancel,
                child: Text(
                  'Use a different account',
                  style: TallyTextStyles.bodySmall(context).copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

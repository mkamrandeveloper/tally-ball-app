import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            borderColor: context.colors.precisionBlue.withOpacity(0.2),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Medal icon
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.optimisticYellow.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.military_tech, color: context.colors.optimisticYellow, size: 48),
                ),
                const SizedBox(height: 32),
                Text("YOU'RE ALL SET\nUP", style: TallyTextStyles.heading1(context), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Start your journey to elite performance.', style: TallyTextStyles.bodyMedium(context), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text("Let's get to work!", style: TallyTextStyles.scriptAccent(context).copyWith(fontSize: 18)),
                const Spacer(),
                TallyButton(
                  text: 'GET STARTED',
                  icon: Icons.arrow_forward,
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

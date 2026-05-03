import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('HELP & FAQ'),
        titleTextStyle: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('FREQUENTLY ASKED QUESTIONS', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2)),
          const SizedBox(height: 16),
          _buildExpansionTile(
            context,
            'How do I connect my Tally Ball targets?',
            'Navigate to the Hardware screen and turn on your physical targets. Tap "Scan" to find available devices via Bluetooth. Once found, tap "Connect".',
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            context,
            'How is the score calculated in Practice Mode?',
            'Points are awarded based on the specific zones hit on the target. The center is worth 30 points, top corners 20 points, and bottom zones 10 points.',
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            context,
            'Can I play against a friend remotely?',
            'Currently, Versus Mode is designed for local multiplayer with connected hardware targets. Remote play is planned for a future update.',
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            context,
            'How do I reset my account data?',
            'Go to your Profile, tap the Settings icon, and select "Delete Account" to wipe all data permanently.',
          ),
          const SizedBox(height: 32),
          Text('STILL NEED HELP?', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2)),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 48, color: context.colors.precisionBlue),
                const SizedBox(height: 16),
                Text('Contact Support', style: TallyTextStyles.heading3(context)),
                const SizedBox(height: 8),
                Text('Our team is available 24/7 to assist you.',
                  style: TallyTextStyles.bodyMedium(context), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TallyButton(
                  text: 'EMAIL SUPPORT',
                  icon: Icons.email,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: ExpansionTile(
        title: Text(question, style: TallyTextStyles.bodyLarge(context)),
        iconColor: context.colors.precisionBlue,
        collapsedIconColor: context.colors.textSecondary,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer, style: TallyTextStyles.bodyMedium(context)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';

class PracticeResultsScreen extends StatelessWidget {
  const PracticeResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final result = game.practiceHistory.isNotEmpty ? game.practiceHistory.last : null;
    final totalTally = result?.totalTally ?? game.score;
    final shotPower = result?.avgShotPower ?? game.shotPower;
    final accuracy = result?.accuracy ?? 92;
    final aiSummary = result?.aiSummary ?? 'Your accuracy in top corners has improved by 15% since last session. Focus on lower-left velocity for optimal performance.';

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        ),
        title: const Text('PRACTICE_COMPLETE'),
        titleTextStyle: TallyTextStyles.heading3(context).copyWith(color: context.colors.precisionBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Final Score Side
                Expanded(
                  flex: 2,
                  child: GlassCard(
                    borderColor: context.colors.precisionBlue.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        Text('FINAL SCORE', style: TallyTextStyles.label(context)),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('$totalTally', style: TallyTextStyles.scoreDisplay(context).copyWith(fontSize: 48, color: context.colors.precisionBlue)),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: context.colors.border),
                        const SizedBox(height: 16),
                        Text('GOAL DISTANCE', style: TallyTextStyles.label(context).copyWith(color: context.colors.textSecondary)),
                        const SizedBox(height: 8),
                        Text('${game.userProfile.totalTallyTarget - totalTally}', style: TallyTextStyles.heading2(context)),
                        Text('to total goal', style: TallyTextStyles.bodySmall(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // AI Summary Side
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.smart_toy, color: context.colors.optimisticYellow, size: 18),
                            const SizedBox(width: 8),
                            Text('AI SUMMARY', style: TallyTextStyles.label(context).copyWith(color: context.colors.optimisticYellow)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PROGRESS: Your accuracy in top corners has improved by 15%.',
                          style: TallyTextStyles.bodySmall(context).copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SUGGESTED: Focus on lower-left velocity for optimal performance.',
                          style: TallyTextStyles.bodySmall(context).copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Row (Accuracy & Power)
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AVG POWER', style: TallyTextStyles.label(context)),
                        const SizedBox(height: 8),
                        Text('${shotPower.toInt()}%', style: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCURACY', style: TallyTextStyles.label(context)),
                        const SizedBox(height: 8),
                        Text('${accuracy.toInt()}%', style: TallyTextStyles.heading2(context).copyWith(color: context.colors.optimisticYellow)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            TallyButton(
              text: 'STORE & RETURN HOME',
              icon: Icons.home,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

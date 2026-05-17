import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class PracticeResultsScreen extends StatelessWidget {
  const PracticeResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final result = game.practiceHistory.isNotEmpty ? game.practiceHistory.last : null;
    final totalTally = result?.totalTally ?? game.score;
    final shotPower = result?.avgShotPower ?? game.shotPower;
    final accuracy = result?.accuracy ?? 92;

    // Personalised AI feedback based on session data
    String aiProgress = 'Keep targeting corner zones to improve your score.';
    String aiSuggestion = 'Focus on lower-left velocity for optimal performance.';
    if (totalTally >= 400) {
      aiProgress = 'Outstanding session! Top-corner consistency is excellent.';
      aiSuggestion = 'Challenge yourself with the Elite target tier next session.';
    } else if (totalTally >= 200) {
      aiProgress = 'Solid accuracy. Top corners improving — bottom zones need work.';
      aiSuggestion = 'Increase bottom-left shot frequency to balance zone coverage.';
    } else if (totalTally > 0) {
      aiProgress = 'Good first effort. Shot power and corner targeting need refinement.';
      aiSuggestion = 'Aim for top-left and top-right corners for 20-pt bonus shots.';
    }

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        ),
        title: const Text('PRACTICE COMPLETE'),
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
                    borderColor: context.colors.precisionBlue.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        Text('FINAL SCORE', style: TallyTextStyles.label(context)),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('$totalTally',
                            style: TallyTextStyles.scoreDisplay(context)
                                .copyWith(fontSize: 48, color: context.colors.precisionBlue)),
                        ),
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
                          'PROGRESS: $aiProgress',
                          style: TallyTextStyles.bodySmall(context)
                              .copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SUGGESTED: $aiSuggestion',
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
                        Text('${shotPower.toInt()}%',
                          style: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue)),
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
                        Text('${accuracy.toInt()}%',
                          style: TallyTextStyles.heading2(context).copyWith(color: context.colors.optimisticYellow)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Primary action: STORE session ──
            TallyButton(
              text: 'STORE & RETURN HOME',
              icon: Icons.save_alt,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
            ),

            const SizedBox(height: 16),

            // ── Divider with label ──
            Row(
              children: [
                Expanded(child: Divider(color: context.colors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR', style: TallyTextStyles.bodySmall(context).copyWith(color: context.colors.textTertiary)),
                ),
                Expanded(child: Divider(color: context.colors.border)),
              ],
            ),

            const SizedBox(height: 16),

            // ── Secondary action: DELETE session (outlined, destructive) ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: context.colors.bgCard,
                      title: Text('Delete Session?', style: TallyTextStyles.heading3(context)),
                      content: Text('This session will NOT be saved to your history.', style: TallyTextStyles.bodyMedium(context)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('DELETE', style: TextStyle(color: context.colors.persistentRed, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    try {
                      final uid = AuthService().currentUser?.uid;
                      if (uid != null) await DatabaseService().deleteLastSession(uid);
                    } catch (_) {}
                    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                  }
                },
                icon: Icon(Icons.delete_outline, color: context.colors.persistentRed, size: 20),
                label: Text('DELETE SESSION', style: TallyTextStyles.button(context).copyWith(color: context.colors.persistentRed)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colors.persistentRed.withValues(alpha: 0.6), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

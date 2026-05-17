import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../../widgets/target_diagram.dart';

class MatchResultsScreen extends StatelessWidget {
  const MatchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final isDraw = game.teamAScore == game.teamBScore;
    final winnerName = game.teamAScore > game.teamBScore ? game.teamAName : game.teamBName;
    final winnerColor = game.teamAScore > game.teamBScore ? context.colors.precisionBlue : context.colors.persistentRed;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('MATCH REPORT'),
        titleTextStyle: TallyTextStyles.heading3(context).copyWith(color: context.colors.precisionBlue),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Winner Card
            GlassCard(
              borderColor: winnerColor.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Icon(isDraw ? Icons.handshake : Icons.emoji_events, color: isDraw ? context.colors.optimisticYellow : winnerColor, size: 48),
                  const SizedBox(height: 16),
                  Text(isDraw ? 'MATCH DRAW' : '$winnerName WINS', style: TallyTextStyles.heading1(context)),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _scoreText(context, '${game.teamAScore}', context.colors.precisionBlue),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('-', style: TallyTextStyles.heading1(context).copyWith(color: context.colors.textTertiary)),
                        ),
                        _scoreText(context, '${game.teamBScore}', context.colors.persistentRed),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shot Breakdown Heading
            Row(
              children: [
                Container(width: 4, height: 20, color: context.colors.precisionBlue),
                const SizedBox(width: 8),
                Text('SHOT BREAKDOWN', style: TallyTextStyles.heading2(context)),
              ],
            ),
            const SizedBox(height: 16),

            // Target Visualization
            const TargetDiagram(height: 200),
            const SizedBox(height: 16),

            // Team A Breakdown
            _teamBreakdown(context, game.teamAName, context.colors.precisionBlue, game),
            const SizedBox(height: 16),
            // Team B Breakdown
            _teamBreakdown(context, game.teamBName, context.colors.persistentRed, game),

            const SizedBox(height: 28),

            // ── Primary: STORE session ──
            TallyButton(
              text: 'STORE & RETURN HOME',
              icon: Icons.save_alt,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
            ),

            const SizedBox(height: 16),
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

            // ── Secondary: DELETE session (outlined, destructive) ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: context.colors.bgCard,
                      title: Text('Delete Match?', style: TallyTextStyles.heading3(context)),
                      content: Text('This match will NOT be saved to history.', style: TallyTextStyles.bodyMedium(context)),
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
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
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

  Widget _scoreText(BuildContext context, String score, Color color) {
    return Text(score, style: TallyTextStyles.scoreDisplay(context).copyWith(color: color, fontSize: 64));
  }

  Widget _teamBreakdown(BuildContext context, String teamName, Color color, GameService game) {
    final zoneHits = teamName == game.teamAName ? game.teamAZoneHits : game.teamBZoneHits;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(teamName, style: TallyTextStyles.heading3(context).copyWith(color: color)),
          const SizedBox(height: 12),
          Divider(color: context.colors.border),
          const SizedBox(height: 8),
          if (zoneHits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('NO HITS RECORDED', style: TallyTextStyles.bodySmall(context))),
            )
          else
            ...zoneHits.entries.map((entry) => _breakdownRow(
              context, 
              entry.key.name.replaceAll('Zone.', '').split(RegExp('(?=[A-Z])')).join(' ').toUpperCase(), 
              '${entry.value}x', 
              color
            )),
        ],
      ),
    );
  }

  Widget _breakdownRow(BuildContext context, String zone, String hits, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zone, style: TallyTextStyles.bodyLarge(context)),
          Text(hits, style: TallyTextStyles.heading3(context).copyWith(color: color)),
        ],
      ),
    );
  }
}

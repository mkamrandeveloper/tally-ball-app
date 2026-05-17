import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../models/game_models.dart';
import '../../services/game_service.dart';

class GameStructureScreen extends StatelessWidget {
  const GameStructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const TallyLogo(height: 36),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('INITIALIZE SEQUENCE', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('GAME\nSTRUCTURE', style: TallyTextStyles.heading1(context)),
            const SizedBox(height: 32),

            SelectionCard(
              title: MatchFormat.twoHalves.name,
              subtitle: null,
              isSelected: game.matchFormat == MatchFormat.twoHalves,
              onTap: () => game.setMatchFormat(MatchFormat.twoHalves),
              selectedBorderColor: context.colors.optimisticYellow,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(MatchFormat.twoHalves.description, style: TallyTextStyles.bodyMedium(context)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 4, color: game.matchFormat == MatchFormat.twoHalves ? context.colors.optimisticYellow : context.colors.bgSurface)),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 4, color: game.matchFormat == MatchFormat.twoHalves ? context.colors.optimisticYellow : context.colors.bgSurface)),
              ],
            ),
            const SizedBox(height: 24),

            SelectionCard(
              title: MatchFormat.fourQuarters.name,
              subtitle: null,
              isSelected: game.matchFormat == MatchFormat.fourQuarters,
              onTap: () => game.setMatchFormat(MatchFormat.fourQuarters),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(MatchFormat.fourQuarters.description, style: TallyTextStyles.bodyMedium(context)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 4, color: game.matchFormat == MatchFormat.fourQuarters ? context.colors.precisionBlue : context.colors.bgSurface)),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 4, color: game.matchFormat == MatchFormat.fourQuarters ? context.colors.precisionBlue : context.colors.bgSurface)),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 4, color: game.matchFormat == MatchFormat.fourQuarters ? context.colors.precisionBlue : context.colors.bgSurface)),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 4, color: game.matchFormat == MatchFormat.fourQuarters ? context.colors.precisionBlue : context.colors.bgSurface)),
              ],
            ),
            const SizedBox(height: 40),

            TallyButton(
              text: 'START MATCH',
              icon: Icons.sports_score,
              onPressed: () {
                game.startMatch();
                Navigator.pushNamed(context, '/live-match');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

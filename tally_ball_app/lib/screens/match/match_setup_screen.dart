import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final _teamAController = TextEditingController(text: 'TEAM A');
  final _teamBController = TextEditingController(text: 'TEAM B');

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/pitch_grass.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: context.colors.bgPrimary.withValues(alpha: 0.85),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text('SETUP MATCH', style: TallyTextStyles.heading1(context), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text('Initialize squad parameters. Designate home\nand away teams for tracking.',
                  style: TallyTextStyles.bodyMedium(context), textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Home Squad
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: context.colors.precisionBlue25.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.precisionBlue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.home, color: context.colors.precisionBlue),
                      const SizedBox(height: 8),
                      Text('HOME SQUAD', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2, color: context.colors.precisionBlue)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _teamAController,
                        textAlign: TextAlign.center,
                        style: TallyTextStyles.heading1(context).copyWith(color: context.colors.precisionBlue),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.precisionBlue.withValues(alpha: 0.3))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.precisionBlue)),
                          filled: false,
                        ),
                        onChanged: (v) => game.setTeamAName(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // VS badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colors.optimisticYellow.withValues(alpha: 0.1),
                    border: Border.all(color: context.colors.optimisticYellow.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('VS', style: TallyTextStyles.heading2(context).copyWith(color: context.colors.optimisticYellow, fontStyle: FontStyle.italic)),
                ),
                const SizedBox(height: 16),

                // Away Squad
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: context.colors.persistentRed25.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.colors.persistentRed.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.flight_takeoff, color: context.colors.persistentRed),
                      const SizedBox(height: 8),
                      Text('AWAY SQUAD', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2, color: context.colors.persistentRed)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _teamBController,
                        textAlign: TextAlign.center,
                        style: TallyTextStyles.heading1(context).copyWith(color: context.colors.persistentRed),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.persistentRed.withValues(alpha: 0.3))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.colors.persistentRed)),
                          filled: false,
                        ),
                        onChanged: (v) => game.setTeamBName(v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                TallyButton(
                  text: 'NEXT PHASE',
                  icon: Icons.arrow_forward,
                  color: context.colors.precisionBlue.withValues(alpha: 0.8),
                  onPressed: () {
                    if (_teamAController.text.isEmpty) game.setTeamAName('TEAM A');
                    if (_teamBController.text.isEmpty) game.setTeamBName('TEAM B');
                    Navigator.pushNamed(context, '/game-structure');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

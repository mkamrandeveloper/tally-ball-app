import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../../models/game_models.dart';

class VersusSetupScreen extends StatefulWidget {
  const VersusSetupScreen({super.key});

  @override
  State<VersusSetupScreen> createState() => _VersusSetupScreenState();
}

class _VersusSetupScreenState extends State<VersusSetupScreen> {
  final _playerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('VERSUS MODE'),
        titleTextStyle: TallyTextStyles.heading3(context),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(radius: 18, backgroundColor: context.colors.bgCard, child: Icon(Icons.person, size: 20, color: context.colors.textSecondary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Warning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.persistentRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.persistentRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: context.colors.optimisticYellow, size: 18),
                      const SizedBox(width: 8),
                      Text('CRITICAL SYSTEM CHECK', style: TallyTextStyles.label(context).copyWith(color: context.colors.persistentRed)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Targets must be connected or data may be lost. Please ensure your hardware is synced before starting.',
                    style: TallyTextStyles.bodyMedium(context).copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Competitors section
            Text('■ COMPETITORS', style: TallyTextStyles.label(context)),
            const SizedBox(height: 12),
            // Team Alpha
            _teamCard('TEAM ALPHA', 'BLUE', context.colors.precisionBlue, game.teamA, true),
            const SizedBox(height: 12),
            // Team Beta
            _teamCard('TEAM BETA', 'RED', context.colors.persistentRed, game.teamB, false),

            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.optimisticYellow.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('VS', style: TallyTextStyles.heading2(context).copyWith(color: context.colors.textTertiary, fontStyle: FontStyle.italic)),
              ),
            ),
            const SizedBox(height: 20),

            // Match Parameters
            Text('■ MATCH PARAMETERS', style: TallyTextStyles.label(context)),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TARGET AIM', style: TallyTextStyles.label(context)),
                  const SizedBox(height: 12),
                  Row(
                    children: TargetAim.values.map((aim) {
                      final isSelected = game.targetAim == aim;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => game.setTargetAim(aim),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? context.colors.precisionBlue.withOpacity(0.1) : context.colors.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? context.colors.precisionBlue : context.colors.border),
                            ),
                            child: Column(
                              children: [
                                Text('${aim.target}', style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700,
                                  color: isSelected ? context.colors.precisionBlue : context.colors.textSecondary,
                                )),
                                const SizedBox(height: 4),
                                Text('FIRST TO', style: TallyTextStyles.bodySmall(context)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TIME LIMIT', style: TallyTextStyles.label(context)),
                      Row(
                        children: [
                          Switch(
                            value: game.noTimeLimit,
                            onChanged: (v) => game.setNoTimeLimit(v),
                            activeThumbColor: context.colors.precisionBlue,
                            inactiveThumbColor: context.colors.textTertiary,
                            inactiveTrackColor: context.colors.bgSurface,
                          ),
                          Text('NO LIMIT', style: TallyTextStyles.bodySmall(context)),
                        ],
                      ),
                    ],
                  ),
                  if (!game.noTimeLimit) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${game.timeLimitMinutes ?? 15} MIN', style: TallyTextStyles.heading2(context)),
                        TextButton(
                          onPressed: () {
                            _showCustomTimeDialog(context, game);
                          },
                          child: Text('CUSTOM', style: TallyTextStyles.label(context)),
                        ),
                      ],
                    ),
                    Slider(
                      value: (game.timeLimitMinutes ?? 15).toDouble().clamp(1, 60),
                      min: 1, max: 60,
                      divisions: 59,
                      activeColor: context.colors.precisionBlue,
                      inactiveColor: context.colors.bgSurface,
                      onChanged: (v) => game.setTimeLimit(v.toInt()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Keep it tight!", style: TallyTextStyles.scriptAccent(context)),
            ),
            const SizedBox(height: 16),
            TallyButton(
              text: 'INITIATE MATCH',
              icon: Icons.double_arrow,
              onPressed: () {
                game.startVersus();
                Navigator.pushNamed(context, '/live-practice');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _teamCard(String teamName, String colorLabel, Color color, List<Player> players, bool isTeamA) {
    final game = context.read<GameService>();
    return GlassCard(
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(teamName, style: TallyTextStyles.heading3(context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(colorLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...players.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text(
                    String.fromCharCode(65 + entry.key),
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.value.name, style: TallyTextStyles.bodyLarge(context))),
                GestureDetector(
                  onTap: () => isTeamA ? game.removePlayerFromTeamA(entry.key) : game.removePlayerFromTeamB(entry.key),
                  child: Icon(Icons.close, color: context.colors.textTertiary, size: 18),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _addPlayerDialog(isTeamA),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.border, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('+ ADD PLAYER', style: TallyTextStyles.bodySmall(context).copyWith(letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addPlayerDialog(bool isTeamA) {
    _playerNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgCard,
        title: Text('Add Player', style: TallyTextStyles.heading3(context)),
        content: TextField(
          controller: _playerNameController,
          style: TextStyle(color: context.colors.textPrimary),
          decoration: const InputDecoration(hintText: 'Player name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final game = context.read<GameService>();
              final name = _playerNameController.text.trim();
              if (name.isNotEmpty) {
                isTeamA ? game.addPlayerToTeamA(name) : game.addPlayerToTeamB(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCustomTimeDialog(BuildContext context, GameService game) {
    final controller = TextEditingController(text: '${game.timeLimitMinutes ?? 15}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgCard,
        title: Text('Custom Time Limit', style: TallyTextStyles.heading3(context)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: context.colors.textPrimary),
          decoration: const InputDecoration(hintText: 'Minutes (1-60)'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 1 && val <= 60) {
                game.setTimeLimit(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}

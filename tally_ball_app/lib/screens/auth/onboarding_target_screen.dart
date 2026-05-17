import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../../models/game_models.dart';

/// Shown once after signup/login to let the user pick their long-term
/// Total Tally Target objective before entering the main dashboard.
class OnboardingTargetScreen extends StatefulWidget {
  const OnboardingTargetScreen({super.key});

  @override
  State<OnboardingTargetScreen> createState() => _OnboardingTargetScreenState();
}

class _OnboardingTargetScreenState extends State<OnboardingTargetScreen> {
  DifficultyLevel _selected = DifficultyLevel.amateur;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.4),
                  radius: 1.0,
                  colors: [
                    context.colors.precisionBlue.withValues(alpha: 0.12),
                    context.colors.bgPrimary,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo
                  const TallyLogo(height: 40),
                  const SizedBox(height: 32),

                  // Heading
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SET YOUR', style: TallyTextStyles.scriptAccent(context).copyWith(fontSize: 20)),
                        Text('TOTAL TARGET', style: TallyTextStyles.heading1(context)),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your long-term scoring objective.\nThis defines your elite performance benchmark.',
                          style: TallyTextStyles.bodyMedium(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Divider(color: context.colors.border),
                  const SizedBox(height: 16),

                  // Difficulty selection
                  Expanded(
                    child: ListView(
                      children: DifficultyLevel.values.map((d) {
                        final isSelected = _selected == d;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SelectionCard(
                            title: d.name,
                            subtitle: d.rangeDisplay,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selected = d),
                            selectedBorderColor: d == DifficultyLevel.elite
                                ? context.colors.optimisticYellow
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TallyButton(
                    text: 'CONFIRM & ENTER DASHBOARD',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      game.setDifficulty(_selected);
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

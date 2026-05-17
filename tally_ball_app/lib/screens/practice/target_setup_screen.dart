import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/target_diagram.dart';
import '../../models/game_models.dart';
import '../../services/game_service.dart';
import 'package:provider/provider.dart';

class TargetSetupScreen extends StatefulWidget {
  const TargetSetupScreen({super.key});

  @override
  State<TargetSetupScreen> createState() => _TargetSetupScreenState();
}

class _TargetSetupScreenState extends State<TargetSetupScreen> {
  final TextEditingController _customTargetController = TextEditingController(text: '50');

  @override
  void dispose() {
    _customTargetController.dispose();
    super.dispose();
  }

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
            Text('SET UP TARGETS', style: TallyTextStyles.heading1(context)),
            const SizedBox(height: 12),
            // Warning banner (Interactive)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/hardware'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.optimisticYellow.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.optimisticYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: context.colors.optimisticYellow, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Please ensure targets are connected before starting.',
                            style: TallyTextStyles.bodyMedium(context).copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                          const SizedBox(height: 4),
                          Text('Tap here to connect your hardware.',
                            style: TallyTextStyles.bodySmall(context).copyWith(
                              color: context.colors.textSecondary,
                            )),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: context.colors.textTertiary, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const TargetDiagram(height: 260),
            const SizedBox(height: 24),
            Text('SESSION TALLY TARGET', style: TallyTextStyles.label(context)),
            const SizedBox(height: 12),
            // Session Target Selection
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: SessionTallyTarget.values.map((target) {
                final isSelected = game.sessionTarget == target;
                return GestureDetector(
                  onTap: () => game.setSessionTarget(target),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.precisionBlue.withValues(alpha: 0.1) : context.colors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? context.colors.precisionBlue : context.colors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      target.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? context.colors.precisionBlue : context.colors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (game.sessionTarget == SessionTallyTarget.custom) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Custom Target:', style: TallyTextStyles.bodyMedium(context)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _customTargetController,
                      keyboardType: TextInputType.number,
                      style: TallyTextStyles.bodyLarge(context),
                      decoration: const InputDecoration(
                        hintText: 'Enter target (min 50)',
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 50;
                        game.setCustomSessionTarget(parsed);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            TallyButton(
              text: 'CONFIRM TARGETS',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.pushNamed(context, '/time-limit'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}

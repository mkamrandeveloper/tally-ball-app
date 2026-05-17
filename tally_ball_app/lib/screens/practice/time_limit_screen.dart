import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';

class TimeLimitScreen extends StatefulWidget {
  const TimeLimitScreen({super.key});

  @override
  State<TimeLimitScreen> createState() => _TimeLimitScreenState();
}

class _TimeLimitScreenState extends State<TimeLimitScreen> {
  static const _timeOptions = [1, 5, 10, 15, 30];
  bool _isCustom = false;
  final TextEditingController _customTimeController = TextEditingController(text: '60');

  @override
  void dispose() {
    _customTimeController.dispose();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text('TIME LIMIT', style: TallyTextStyles.heading1(context), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Select duration for this session', style: TallyTextStyles.bodyMedium(context), textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // No limit toggle
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NO LIMIT', style: TallyTextStyles.heading3(context)),
                        const SizedBox(height: 4),
                        Text('Train continuously until manually\nstopped', style: TallyTextStyles.bodySmall(context)),
                      ],
                    ),
                  ),
                  Switch(
                    value: game.noTimeLimit,
                    onChanged: (v) {
                      game.setNoTimeLimit(v);
                      if (v) setState(() => _isCustom = false);
                    },
                    activeThumbColor: context.colors.precisionBlue,
                    inactiveThumbColor: context.colors.textTertiary,
                    inactiveTrackColor: context.colors.bgSurface,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Time grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  ..._timeOptions.map((mins) {
                    final isSelected = !_isCustom && !game.noTimeLimit && game.timeLimitMinutes == mins;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _isCustom = false);
                        game.setNoTimeLimit(false);
                        game.setTimeLimit(mins);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? context.colors.precisionBlue.withValues(alpha: 0.08) : context.colors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? context.colors.precisionBlue : context.colors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Icon(Icons.gps_fixed, color: context.colors.precisionBlue, size: 14),
                              ),
                            Text(
                              '$mins',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? context.colors.precisionBlue : context.colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('MIN', style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: isSelected ? context.colors.precisionBlue : context.colors.textTertiary,
                            )),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Custom button
                  GestureDetector(
                    onTap: () {
                      setState(() => _isCustom = true);
                      game.setNoTimeLimit(false);
                      final parsed = int.tryParse(_customTimeController.text) ?? 60;
                      game.setTimeLimit(parsed);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCustom ? context.colors.precisionBlue.withValues(alpha: 0.08) : context.colors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCustom ? context.colors.precisionBlue : context.colors.border,
                          width: _isCustom ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isCustom)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Icon(Icons.gps_fixed, color: context.colors.precisionBlue, size: 14),
                            ),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _isCustom ? context.colors.precisionBlue : context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('MIN', style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: _isCustom ? context.colors.precisionBlue : context.colors.textTertiary,
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isCustom) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Time (1-60 mins):', style: TallyTextStyles.bodyMedium(context)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _customTimeController,
                      keyboardType: TextInputType.number,
                      style: TallyTextStyles.bodyLarge(context),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 45',
                      ),
                      onChanged: (val) {
                        int parsed = int.tryParse(val) ?? 60;
                        if (parsed < 1) parsed = 1;
                        if (parsed > 60) parsed = 60;
                        game.setTimeLimit(parsed);
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            TallyButton(
              text: 'START PRACTICE',
              icon: Icons.rocket_launch,
              onPressed: () {
                final game = context.read<GameService>();
                game.startPractice();
                Navigator.pushNamed(context, '/live-practice');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

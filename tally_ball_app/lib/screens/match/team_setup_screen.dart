import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';

class TeamSetupScreen extends StatefulWidget {
  const TeamSetupScreen({super.key});

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  final List<String> _teamMembers = ['Player 1', 'Player 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('TEAM ROSTER'),
        titleTextStyle: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _teamMembers.length + 1,
              itemBuilder: (context, index) {
                if (index == _teamMembers.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _teamMembers.add('Player ${_teamMembers.length + 1}');
                        });
                      },
                      icon: Icon(Icons.add, color: context.colors.precisionBlue),
                      label: Text('ADD PLAYER', style: TallyTextStyles.button(context).copyWith(color: context.colors.precisionBlue)),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: context.colors.bgCardLight,
                              child: Icon(Icons.person, color: context.colors.textSecondary),
                            ),
                            const SizedBox(width: 16),
                            Text(_teamMembers[index], style: TallyTextStyles.bodyLarge(context)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.colors.error),
                          onPressed: () {
                            setState(() {
                              _teamMembers.removeAt(index);
                            });
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TallyButton(
              text: 'CONFIRM ROSTER',
              icon: Icons.check,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

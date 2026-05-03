import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../../models/game_models.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../profile/user_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _navIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _navIndex != 0) {
          setState(() => _navIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.bgPrimary,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.5, -0.2),
                    radius: 1.2,
                    colors: [
                      context.colors.precisionBlue.withOpacity(0.15),
                      context.colors.bgPrimary,
                      context.colors.bgPrimary,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: IndexedStack(
                index: _navIndex,
                children: [
                  _buildHomeTab(),
                  _buildModesTab(),
                  _buildHistoryTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: TallyBottomNav(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: [
            TallyNavItem(icon: Icons.home_outlined, label: 'HOME'),
            TallyNavItem(icon: Icons.gps_fixed, label: 'MODES'),
            TallyNavItem(icon: Icons.bar_chart, label: 'HISTORY'),
            TallyNavItem(icon: Icons.person_outline, label: 'PROFILE'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final game = context.watch<GameService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // App Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: context.colors.textPrimary),
                onPressed: () {},
              ),
              Text('TALLY BALL', style: TallyTextStyles.heading3(context).copyWith(color: context.colors.precisionBlue)),
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.bgCard,
                child: Icon(Icons.person, color: context.colors.textSecondary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text('WELCOME BACK,', style: TallyTextStyles.scriptAccent(context).copyWith(fontSize: 18)),
          Text(game.userProfile.name.toUpperCase(), 
            style: TallyTextStyles.heading1(context).copyWith(fontSize: 28, letterSpacing: 2)),

          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _dbService.getGameSessionsStream(_authService.currentUser?.uid ?? ''),
            builder: (context, snapshot) {
              int latestScore = 0;
              String timeStr = DateFormat('MMM dd, HH:mm').format(DateTime.now()).toUpperCase();
              
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data = snapshot.data!.docs.first.data();
                latestScore = data['score'] ?? 0;
                final ts = data['timestamp'] as Timestamp?;
                if (ts != null) {
                  timeStr = DateFormat('MMM dd, HH:mm').format(ts.toDate()).toUpperCase();
                }
              }

              return GlassCard(
                borderColor: context.colors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CURRENT TALLY', style: TallyTextStyles.labelYellow(context)),
                        Text(timeStr, style: TallyTextStyles.bodySmall(context)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat('#,###').format(latestScore),
                          style: TallyTextStyles.scoreDisplay(context).copyWith(color: context.colors.precisionBlue),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('PTS', style: TallyTextStyles.heading3(context).copyWith(color: context.colors.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: context.colors.border),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => setState(() => _navIndex = 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.optimisticYellow),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('VIEW HISTORY', style: TallyTextStyles.label(context).copyWith(color: context.colors.optimisticYellow, fontSize: 12)),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: context.colors.optimisticYellow, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          // Select Mode
          Row(
            children: [
              Icon(Icons.gps_fixed, color: context.colors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text('SELECT MODE', style: TallyTextStyles.heading3(context)),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _modeCard('PRACTICE', Icons.gps_fixed, context.colors.precisionBlue, () {
                setState(() => _navIndex = 1);
              }),
              const SizedBox(width: 12),
              _modeCard('FRIENDS\n(VS)', Icons.people, context.colors.optimisticYellow, () {
                Navigator.pushNamed(context, '/versus-setup');
              }),
              const SizedBox(width: 12),
              _modeCard('MATCH', Icons.verified, context.colors.persistentRed, () {
                Navigator.pushNamed(context, '/match-setup');
              }),
            ],
          ),

          const SizedBox(height: 24),
          // Your Progress
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _dbService.getGameSessionsStream(_authService.currentUser?.uid ?? ''),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              final hasData = docs.isNotEmpty;
              
              String aiMessage = 'Welcome to Tally Ball! Start your first session to begin tracking your performance metrics.';
              if (hasData) {
                final lastScore = docs.first.data()['score'] ?? 0;
                aiMessage = 'Last session: $lastScore pts. Keep practicing to improve your accuracy and reach the next tier.';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: context.colors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text('YOUR PROGRESS', style: TallyTextStyles.heading3(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: context.colors.optimisticYellow, size: 18),
                                const SizedBox(width: 8),
                                Text('AI SUMMARY', style: TallyTextStyles.labelYellow(context)),
                              ],
                            ),
                            Text(hasData ? "Great job!" : "Get started!", 
                              style: TallyTextStyles.scriptAccent(context).copyWith(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          aiMessage,
                          style: TallyTextStyles.bodyMedium(context).copyWith(color: context.colors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        // Mini chart showing last 5 sessions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(hasData ? 'RECENT SESSIONS' : 'NO DATA YET', style: TallyTextStyles.label(context)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!hasData)
                                for (int i = 0; i < 5; i++)
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: context.colors.precisionBlue25.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  )
                              else
                                ...docs.take(5).toList().reversed.map((doc) {
                                  final score = (doc.data()['score'] ?? 0) as int;
                                  final maxScore = 1000.0; // Normalizing for display
                                  final height = (score / maxScore * 60).clamp(5.0, 60.0);
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: context.colors.precisionBlue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                // Fill remaining slots if less than 5
                                for (int i = 0; i < (5 - docs.length).clamp(0, 5); i++)
                                  Expanded(child: const SizedBox()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _modeCard(String label, IconData icon, Color color, VoidCallback onTap) {
    // Determine the tint to use for the card background
    Color cardBg = color.withOpacity(0.08);
    if (color == context.colors.precisionBlue) cardBg = context.colors.precisionBlue25.withOpacity(0.3);
    if (color == context.colors.persistentRed) cardBg = context.colors.persistentRed25.withOpacity(0.3);
    if (color == context.colors.optimisticYellow) cardBg = context.colors.optimisticYellow25.withOpacity(0.3);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(label, style: TallyTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.w800, 
                letterSpacing: 1.5, 
                fontSize: 10, 
                color: context.colors.textPrimary,
              ), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModesTab() {
    return _PracticeSetupTab(onStart: () {
      final game = context.read<GameService>();
      game.startPractice();
      Navigator.pushNamed(context, '/live-practice');
    });
  }

  Widget _buildHistoryTab() {
    final user = _authService.currentUser;
    if (user == null) return const Center(child: Text('Please log in'));

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _dbService.getGameSessionsStream(user.uid),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        int totalSessions = docs.length;
        int avgScore = 0;
        int allTimeHigh = 0;
        
        if (docs.isNotEmpty) {
          int sum = 0;
          for (var doc in docs) {
            final score = doc.data()['score'] ?? 0;
            sum += score as int;
            if (score > allTimeHigh) allTimeHigh = score;
          }
          avgScore = sum ~/ docs.length;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: Icon(Icons.menu, color: context.colors.textPrimary), onPressed: () {}),
                  Text('ELITE PERFORMANCE', style: TallyTextStyles.heading3(context).copyWith(color: context.colors.optimisticYellow)),
                  CircleAvatar(radius: 20, backgroundColor: context.colors.bgCard, child: Icon(Icons.person, size: 22, color: context.colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 24),
              Text('PERFORMANCE SUMMARY', style: TallyTextStyles.heading2(context)),
              const SizedBox(height: 16),
              _statCard('ALL-TIME HIGH', NumberFormat('#,###').format(allTimeHigh), 'Your best session'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statCard('TOTAL SESSIONS', '$totalSessions', 'Total games played', borderColor: context.colors.optimisticYellow)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('AVERAGE SCORE', NumberFormat('#,###').format(avgScore), 'Across all sessions', borderColor: context.colors.persistentRed)),
                ],
              ),
              const SizedBox(height: 24),
              // Dummy graph to fill space and look like a premium telemetry app
              GlassCard(
                borderColor: context.colors.precisionBlue.withOpacity(0.1),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PERFORMANCE TREND', style: TallyTextStyles.bodySmall(context)),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(12, (index) {
                              return Container(
                                width: 8,
                                height: 20.0 + (index * 7 % 60),
                                decoration: BoxDecoration(
                                  color: context.colors.precisionBlue.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SESSION HISTORY', style: TallyTextStyles.heading3(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (docs.isEmpty) 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('No sessions recorded', style: TallyTextStyles.bodySmall(context))),
                      )
                    else
                      for (var doc in docs.take(10)) 
                        _historyRow(
                          doc.data()['timestamp'] != null 
                              ? DateFormat('MMM dd, yyyy').format((doc.data()['timestamp'] as Timestamp).toDate())
                              : 'Unknown',
                          (doc.data()['mode'] ?? 'practice').toString().toUpperCase(),
                          'Score: ${doc.data()['score'] ?? 0}',
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _statCard(String label, String value, String subtitle, {Color? borderColor}) {
    return GlassCard(
      borderColor: borderColor ?? context.colors.precisionBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TallyTextStyles.label(context).copyWith(color: borderColor ?? context.colors.precisionBlue)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TallyTextStyles.scoreMedium(context)),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TallyTextStyles.bodySmall(context)),
        ],
      ),
    );
  }

  Widget _historyRow(String date, String mode, String focus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(date, style: TallyTextStyles.bodyMedium(context))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.bgSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_fixed, color: context.colors.textTertiary, size: 12),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      mode, 
                      style: TallyTextStyles.bodySmall(context).copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(focus, style: TallyTextStyles.bodySmall(context), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return UserProfileScreen(useScaffold: false);
  }

  Widget _profileField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TallyTextStyles.bodySmall(context)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.bgSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: context.colors.textTertiary, size: 18),
                const SizedBox(width: 12),
                Text(value, style: TallyTextStyles.bodyLarge(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Practice setup embedded in the Modes tab
class _PracticeSetupTab extends StatelessWidget {
  final VoidCallback onStart;
  const _PracticeSetupTab({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.menu, color: context.colors.textPrimary), onPressed: () {}),
              Text('TALLY BALL', style: TallyTextStyles.heading3(context).copyWith(color: context.colors.optimisticYellow)),
              CircleAvatar(radius: 20, backgroundColor: context.colors.bgCard, child: Icon(Icons.person, size: 22, color: context.colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Text('SELECT TOTAL\nTALLY TARGET', style: TallyTextStyles.heading1(context)),
          const SizedBox(height: 8),
          Text('Calibrate your training parameters\nbefore initiating sequence.', style: TallyTextStyles.bodyMedium(context)),
          const SizedBox(height: 8),
          Divider(color: context.colors.border),
          const SizedBox(height: 8),
          // Difficulty grid
          ...DifficultyLevel.values.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SelectionCard(
              title: d.name,
              subtitle: d.rangeDisplay,
              isSelected: game.difficulty == d,
              onTap: () => game.setDifficulty(d),
              selectedBorderColor: d == DifficultyLevel.elite ? context.colors.optimisticYellow : null,
            ),
          )),
          const SizedBox(height: 16),
          TallyButton(text: 'NEXT: SELECT TARGETS', icon: Icons.arrow_forward, onPressed: () {
            Navigator.pushNamed(context, '/target-setup');
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../profile/user_profile_screen.dart';

enum _HistoryFilter { all, practice, match, friends }

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
                      context.colors.precisionBlue.withValues(alpha: 0.15),
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
                onPressed: () => _showDrawer(context),
              ),
              const TallyLogo(height: 36),
              const SizedBox(width: 48), // balance the hamburger
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
                        Text('PREVIOUS TALLY SCORE', style: TallyTextStyles.labelYellow(context)),
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
                            Text('VIEW TALLY SCORE HISTORY', style: TallyTextStyles.label(context).copyWith(color: context.colors.optimisticYellow, fontSize: 12)),
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
                final scores = docs.map((d) => (d.data()['score'] ?? 0) as int).toList();
                final lastScore = scores.first;
                final avg = scores.isNotEmpty ? scores.reduce((a, b) => a + b) ~/ scores.length : 0;
                final best = scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0;
                final trend = scores.length > 1 && scores.first > scores[1] ? '📈 improving' : '📊 consistent';
                aiMessage = 'Last session: $lastScore pts · Avg: $avg pts · Best: $best pts\nPerformance trend: $trend. Keep targeting corners to maximize your tally score.';
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
                                        color: context.colors.precisionBlue25.withValues(alpha: 0.1),
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
                                }),
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
    Color cardBg = color.withValues(alpha: 0.08);
    if (color == context.colors.precisionBlue) cardBg = context.colors.precisionBlue25.withValues(alpha: 0.3);
    if (color == context.colors.persistentRed) cardBg = context.colors.persistentRed25.withValues(alpha: 0.3);
    if (color == context.colors.optimisticYellow) cardBg = context.colors.optimisticYellow25.withValues(alpha: 0.3);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
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
    // Modes tab: show mode selection cards (Select Total Target is handled in onboarding)
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.menu, color: context.colors.textPrimary), onPressed: () => _showDrawer(context)),
              const TallyLogo(height: 36),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Text('PRACTICE MODE', style: TallyTextStyles.heading2(context)),
          const SizedBox(height: 8),
          Text('Solo training session against the targets.', style: TallyTextStyles.bodyMedium(context)),
          const SizedBox(height: 16),
          _PracticeSetupTab(onStart: () {
            final game = context.read<GameService>();
            game.startPractice();
            Navigator.pushNamed(context, '/live-practice');
          }),
        ],
      ),
    );
  }

  _HistoryFilter _historyFilter = _HistoryFilter.all;

  Widget _buildHistoryTab() {
    final user = _authService.currentUser;
    if (user == null) return const Center(child: Text('Please log in'));

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _dbService.getGameSessionsStream(user.uid),
      builder: (context, snapshot) {
        final allDocs = snapshot.data?.docs ?? [];

        // Filter
        final docs = allDocs.where((doc) {
          final mode = (doc.data()['mode'] ?? 'practice') as String;
          switch (_historyFilter) {
            case _HistoryFilter.practice: return mode == 'practice';
            case _HistoryFilter.match: return mode == 'match';
            case _HistoryFilter.friends: return mode == 'versus';
            case _HistoryFilter.all: return true;
          }
        }).toList();

        int totalSessions = allDocs.length;
        int avgScore = 0;
        int allTimeHigh = 0;
        if (allDocs.isNotEmpty) {
          int sum = 0;
          for (var doc in allDocs) {
            final score = doc.data()['score'] ?? 0;
            sum += score as int;
            if (score > allTimeHigh) allTimeHigh = score;
          }
          avgScore = sum ~/ allDocs.length;
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
                  IconButton(icon: Icon(Icons.menu, color: context.colors.textPrimary), onPressed: () => _showDrawer(context)),
                  const TallyLogo(height: 36),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              Text('PERFORMANCE SUMMARY', style: TallyTextStyles.heading2(context)),
              const SizedBox(height: 12),
              _statCard('ALL-TIME HIGH', NumberFormat('#,###').format(allTimeHigh), 'Your best session'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _statCard('TOTAL SESSIONS', '$totalSessions', 'Games played', borderColor: context.colors.optimisticYellow)),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard('AVERAGE SCORE', NumberFormat('#,###').format(avgScore), 'Across all sessions', borderColor: context.colors.persistentRed)),
                ],
              ),
              const SizedBox(height: 20),
              // Sort filter chips
              Text('SORT BY SESSION TYPE', style: TallyTextStyles.label(context)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _HistoryFilter.values.map((f) {
                    final isActive = _historyFilter == f;
                    final labels = {_HistoryFilter.all: 'ALL', _HistoryFilter.practice: 'PRACTICE', _HistoryFilter.match: 'MATCH', _HistoryFilter.friends: 'FRIENDS VS'};
                    return GestureDetector(
                      onTap: () => setState(() => _historyFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? context.colors.precisionBlue : context.colors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? context.colors.precisionBlue : context.colors.border),
                        ),
                        child: Text(labels[f]!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? Colors.white : context.colors.textSecondary, letterSpacing: 1)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SESSION HISTORY', style: TallyTextStyles.heading3(context)),
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
      },
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

  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle indicator
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const TallyLogo(height: 32),
              const SizedBox(height: 16),
              _drawerItem(ctx, Icons.home_outlined, 'HOME', () => setState(() => _navIndex = 0)),
              _drawerItem(ctx, Icons.gps_fixed, 'MODES', () => setState(() => _navIndex = 1)),
              _drawerItem(ctx, Icons.bar_chart, 'HISTORY', () => setState(() => _navIndex = 2)),
              _drawerItem(ctx, Icons.wifi, 'HARDWARE', () => Navigator.pushNamed(ctx, '/hardware')),
              _drawerItem(ctx, Icons.settings, 'SETTINGS', () => Navigator.pushNamed(ctx, '/settings')),
              _drawerItem(ctx, Icons.help_outline, 'FAQ / HELP', () => Navigator.pushNamed(ctx, '/faq')),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: context.colors.precisionBlue, size: 22),
      title: Text(label, style: TallyTextStyles.label(context).copyWith(color: context.colors.textPrimary, fontSize: 13)),
      onTap: () { Navigator.pop(ctx); onTap(); },
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Practice setup embedded in the Modes tab
class _PracticeSetupTab extends StatelessWidget {
  final VoidCallback onStart;
  const _PracticeSetupTab({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('START PRACTICE', style: TallyTextStyles.heading2(context)),
          const SizedBox(height: 8),
          Text('Configure targets and time limit before beginning.', style: TallyTextStyles.bodyMedium(context)),
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

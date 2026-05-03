import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/target_diagram.dart';
import '../../services/game_service.dart';
import '../../models/game_models.dart';

class LiveMatchScreen extends StatefulWidget {
  const LiveMatchScreen({super.key});

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen>
    with TickerProviderStateMixin {
  GameService? _gameService;
  bool _showingPeriodBreak = false;
  int _lastPeriod = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameService = context.read<GameService>();
      _lastPeriod = _gameService!.currentPeriod;
      _gameService!.addListener(_onGameUpdate);
    });
  }

  void _onGameUpdate() {
    if (!mounted) return;
    final game = _gameService;
    if (game == null) return;

    // Detect period change → show break banner
    if (game.currentPeriod != _lastPeriod) {
      _lastPeriod = game.currentPeriod;
      setState(() => _showingPeriodBreak = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showingPeriodBreak = false);
      });
    }
  }

  @override
  void dispose() {
    _gameService?.removeListener(_onGameUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final periodName = game.matchFormat == MatchFormat.twoHalves ? 'HALF' : 'QUARTER';
    final totalPeriods = game.matchFormat.periods;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: Text('LIVE MATCH',
          style: TallyTextStyles.heading2(context).copyWith(
            color: context.colors.precisionBlue, fontStyle: FontStyle.italic)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            game.endSession();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Background pitch texture
          Positioned.fill(
            child: Image.asset('assets/images/pitch_grass.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: context.colors.bgPrimary.withOpacity(0.88)),
          ),

          // ─── Main Layout ───
          Column(
            children: [

              // ── Period progress strip ──
              _PeriodProgressBar(
                currentPeriod: game.currentPeriod,
                totalPeriods: totalPeriods,
                periodName: periodName,
                remainingSeconds: game.remainingSeconds,
                minutesPerPeriod: game.matchFormat.minutesPerPeriod,
              ),

              // ── Scoreboard Card ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Team A panel
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: game.isTeamATurn
                                ? context.colors.precisionBlue25.withOpacity(0.3)
                                : context.colors.precisionBlue25.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: game.isTeamATurn
                                ? Border.all(color: context.colors.precisionBlue.withOpacity(0.5), width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: context.colors.bgSurface,
                                child: Icon(Icons.shield, size: 18,
                                  color: game.isTeamATurn
                                      ? context.colors.precisionBlue
                                      : context.colors.textTertiary),
                              ),
                              const SizedBox(height: 5),
                              Text(game.teamAName.isNotEmpty ? game.teamAName : 'TEAM A',
                                style: TallyTextStyles.label(context).copyWith(
                                  color: game.isTeamATurn
                                      ? context.colors.precisionBlue
                                      : context.colors.textSecondary,
                                  fontSize: 11),
                                overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text('${game.teamAScore}',
                                style: TallyTextStyles.scoreDisplay(context).copyWith(
                                  fontSize: 48,
                                  color: game.isTeamATurn
                                      ? context.colors.precisionBlue
                                      : context.colors.textSecondary)),
                            ],
                          ),
                        ),
                      ),

                      // Center: period timer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${_ordinal(game.currentPeriod)} $periodName',
                              style: TallyTextStyles.label(context).copyWith(fontSize: 10)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: context.colors.optimisticYellow.withOpacity(0.1),
                                border: Border.all(
                                  color: context.colors.optimisticYellow.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(game.timerDisplay,
                                style: TallyTextStyles.heading2(context).copyWith(
                                  color: context.colors.optimisticYellow, fontSize: 18)),
                            ),
                          ],
                        ),
                      ),

                      // Team B panel
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !game.isTeamATurn
                                ? context.colors.persistentRed25.withOpacity(0.3)
                                : context.colors.persistentRed25.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: !game.isTeamATurn
                                ? Border.all(color: context.colors.persistentRed.withOpacity(0.5), width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: context.colors.bgSurface,
                                child: Icon(Icons.flight_takeoff, size: 18,
                                  color: !game.isTeamATurn
                                      ? context.colors.persistentRed
                                      : context.colors.textTertiary),
                              ),
                              const SizedBox(height: 5),
                              Text(game.teamBName.isNotEmpty ? game.teamBName : 'TEAM B',
                                style: TallyTextStyles.label(context).copyWith(
                                  color: !game.isTeamATurn
                                      ? context.colors.persistentRed
                                      : context.colors.textSecondary,
                                  fontSize: 11),
                                overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text('${game.teamBScore}',
                                style: TallyTextStyles.scoreDisplay(context).copyWith(
                                  fontSize: 48,
                                  color: !game.isTeamATurn
                                      ? context.colors.persistentRed
                                      : context.colors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Turn Banner with Shot Countdown ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: game.isTeamATurn
                      ? context.colors.precisionBlue.withOpacity(0.12)
                      : context.colors.persistentRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: game.isTeamATurn
                        ? context.colors.precisionBlue.withOpacity(0.4)
                        : context.colors.persistentRed.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      game.isTeamATurn ? Icons.shield : Icons.flight_takeoff,
                      color: game.isTeamATurn
                          ? context.colors.precisionBlue
                          : context.colors.persistentRed,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${game.activeTeamName} — SHOOT!',
                            style: TallyTextStyles.heading3(context).copyWith(
                              color: game.isTeamATurn
                                  ? context.colors.precisionBlue
                                  : context.colors.persistentRed,
                              fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('1 minute per shot · miss = turn switch',
                            style: TallyTextStyles.bodySmall(context).copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Shot countdown ring
                    _ShotCountdownRing(
                      seconds: game.shotSecondsRemaining,
                      total: 60,
                      color: game.shotSecondsRemaining > 15
                          ? context.colors.optimisticYellow
                          : context.colors.persistentRed,
                    ),
                  ],
                ),
              ),

              // ── Target Diagram (fills remaining space) ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: TargetDiagram(highlightedZone: game.lastHitZone),
                ),
              ),

              // ── Bottom Action Bar ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: context.colors.bgPrimary,
                  border: Border(top: BorderSide(color: context.colors.border)),
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => game.togglePause(),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              game.isPaused ? Icons.play_arrow : Icons.pause,
                              color: context.colors.textSecondary, size: 26),
                          ),
                        ),
                        Text(game.isPaused ? 'RESUME' : 'PAUSE',
                          style: TallyTextStyles.label(context).copyWith(
                            color: context.colors.textSecondary, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            game.endSession();
                            Navigator.pushReplacementNamed(context, '/match-results');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.stop,
                              color: context.colors.textSecondary, size: 26),
                          ),
                        ),
                        Text('END MATCH',
                          style: TallyTextStyles.label(context).copyWith(
                            color: context.colors.textSecondary, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TallyButton(
                        text: 'MATCH REPORT',
                        icon: Icons.show_chart,
                        onPressed: () {
                          game.endSession();
                          Navigator.pushNamed(context, '/match-results');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── MISS! Overlay ──
          if (game.showMiss)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: context.colors.persistentRed.withOpacity(0.15),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                      decoration: BoxDecoration(
                        color: context.colors.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.persistentRed, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.persistentRed.withOpacity(0.3),
                            blurRadius: 30, spreadRadius: 5),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                            color: context.colors.persistentRed, size: 48),
                          const SizedBox(height: 8),
                          Text('MISS!',
                            style: TallyTextStyles.scoreDisplay(context).copyWith(
                              color: context.colors.persistentRed, fontSize: 48)),
                          const SizedBox(height: 4),
                          Text('Turn switches to next team',
                            style: TallyTextStyles.bodySmall(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Period Break Overlay ──
          if (_showingPeriodBreak)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: context.colors.bgPrimary.withOpacity(0.85),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                      decoration: BoxDecoration(
                        color: context.colors.bgCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: context.colors.optimisticYellow.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.optimisticYellow.withOpacity(0.15),
                            blurRadius: 40, spreadRadius: 8),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sports_score,
                            color: context.colors.optimisticYellow, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            game.currentPeriod == 2 &&
                                game.matchFormat == MatchFormat.twoHalves
                                ? 'HALF TIME!'
                                : 'PERIOD BREAK',
                            style: TallyTextStyles.heading1(context).copyWith(
                              color: context.colors.optimisticYellow, fontSize: 28)),
                          const SizedBox(height: 8),
                          Text(
                            '${_ordinal(game.currentPeriod)} ${game.matchFormat == MatchFormat.twoHalves ? 'Half' : 'Quarter'} starts in 3s',
                            style: TallyTextStyles.bodyMedium(context)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ScorePill(
                                name: game.teamAName.isNotEmpty ? game.teamAName : 'TEAM A',
                                score: game.teamAScore,
                                color: context.colors.precisionBlue),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('VS',
                                  style: TallyTextStyles.heading2(context).copyWith(
                                    color: context.colors.textTertiary)),
                              ),
                              _ScorePill(
                                name: game.teamBName.isNotEmpty ? game.teamBName : 'TEAM B',
                                score: game.teamBScore,
                                color: context.colors.persistentRed),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}TH';
    switch (n % 10) {
      case 1: return '${n}ST';
      case 2: return '${n}ND';
      case 3: return '${n}RD';
      default: return '${n}TH';
    }
  }
}

// ── Period Progress Bar ──
class _PeriodProgressBar extends StatelessWidget {
  final int currentPeriod;
  final int totalPeriods;
  final String periodName;
  final int remainingSeconds;
  final int minutesPerPeriod;

  const _PeriodProgressBar({
    required this.currentPeriod,
    required this.totalPeriods,
    required this.periodName,
    required this.remainingSeconds,
    required this.minutesPerPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = minutesPerPeriod * 60;
    final elapsed = totalSeconds - remainingSeconds;
    final progress = (elapsed / totalSeconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  for (int i = 1; i <= totalPeriods; i++) ...[
                    Container(
                      width: 28,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: i < currentPeriod
                            ? context.colors.precisionBlue
                            : i == currentPeriod
                                ? context.colors.optimisticYellow
                                : context.colors.bgSurface,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '$periodName $currentPeriod / $totalPeriods',
                style: TallyTextStyles.label(context).copyWith(
                  fontSize: 10, color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: context.colors.bgSurface,
              valueColor: AlwaysStoppedAnimation(context.colors.optimisticYellow),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shot Countdown Ring ──
class _ShotCountdownRing extends StatelessWidget {
  final int seconds;
  final int total;
  final Color color;

  const _ShotCountdownRing({
    required this.seconds,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = seconds / total;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: context.colors.bgSurface,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$seconds',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              Text('s', style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Score Pill ──
class _ScorePill extends StatelessWidget {
  final String name;
  final int score;
  final Color color;

  const _ScorePill({required this.name, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name,
            style: TallyTextStyles.label(context).copyWith(color: color, fontSize: 11)),
          Text('$score',
            style: TallyTextStyles.scoreMedium(context).copyWith(color: color, fontSize: 28)),
        ],
      ),
    );
  }
}

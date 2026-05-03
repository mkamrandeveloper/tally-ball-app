import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/target_diagram.dart';
import '../../services/game_service.dart';
import '../../models/game_models.dart';
import '../../utils/toast_utils.dart';

class LivePracticeScreen extends StatefulWidget {
  const LivePracticeScreen({super.key});

  @override
  State<LivePracticeScreen> createState() => _LivePracticeScreenState();
}

class _LivePracticeScreenState extends State<LivePracticeScreen>
    with TickerProviderStateMixin {
  GameService? _gameService;
  late AnimationController _missAnimController;
  late AnimationController _turnBannerController;

  @override
  void initState() {
    super.initState();

    _missAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _turnBannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameService = context.read<GameService>();
      _gameService?.addListener(_onGameUpdate);
    });
  }

  void _onGameUpdate() {
    if (!mounted) return;
    final game = _gameService;
    if (game == null) return;

    // Show milestone toast
    final msg = game.currentNotification;
    if (msg != null) {
      TallyToast.showSuccess(context, msg);
      game.clearNotification();
    }

    // Animate miss overlay
    if (game.showMiss) {
      _missAnimController.forward(from: 0);
      _turnBannerController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _gameService?.removeListener(_onGameUpdate);
    _missAnimController.dispose();
    _turnBannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameService>();
    final isVersus = game.currentMode == GameMode.versus;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          game.endSession();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.bgPrimary,
        appBar: AppBar(
          title: Text(isVersus ? 'VERSUS MODE' : 'PRACTICE MODE',
            style: TallyTextStyles.heading3(context)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              game.endSession();
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Stack(
          children: [
            // ─── Main non-overlapping layout ───
            Column(
              children: [
                // ── Scoreboard Card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: GlassCard(
                    borderColor: context.colors.precisionBlue.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    child: isVersus
                        ? _buildVersusScoreboard(game)
                        : _buildPracticeScoreboard(game),
                  ),
                ),

                // ── Versus: Turn + Shot Timer Banner ──
                if (isVersus)
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
                        // Team label
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                game.isTeamATurn ? Icons.shield : Icons.flight_takeoff,
                                color: game.isTeamATurn
                                    ? context.colors.precisionBlue
                                    : context.colors.persistentRed,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${game.activeTeamName} — SHOOT!',
                                  style: TallyTextStyles.heading3(context).copyWith(
                                    color: game.isTeamATurn
                                        ? context.colors.precisionBlue
                                        : context.colors.persistentRed,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

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

                // ── Stats Row (practice only) ──
                if (!isVersus)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('SHOT POWER', style: TallyTextStyles.label(context)),
                                    Icon(Icons.bolt, color: context.colors.textTertiary, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${game.shotPower.toInt()}%',
                                  style: TallyTextStyles.scoreMedium(context).copyWith(fontSize: 20)),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: game.shotPower / 100,
                                  backgroundColor: context.colors.bgSurface,
                                  valueColor: AlwaysStoppedAnimation(context.colors.precisionBlue),
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('SHOT COUNT', style: TallyTextStyles.label(context)),
                                    Icon(Icons.gps_fixed, color: context.colors.textTertiary, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${game.shotCount}',
                                  style: TallyTextStyles.scoreMedium(context).copyWith(fontSize: 20)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    for (int i = 0; i < 5; i++)
                                      Expanded(
                                        child: Container(
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                          decoration: BoxDecoration(
                                            color: i < (game.shotCount ~/ 3).clamp(0, 5)
                                                ? context.colors.precisionBlue
                                                : context.colors.precisionBlue25.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                // ── Bottom Action Bar ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: context.colors.bgPrimary,
                    border: Border(top: BorderSide(color: context.colors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => game.togglePause(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: context.colors.border),
                          ),
                          child: Text(game.isPaused ? 'RESUME' : 'PAUSE',
                            style: TallyTextStyles.button(context)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            game.endSession();
                            if (game.currentMode == GameMode.versus) {
                              Navigator.pushReplacementNamed(context, '/match-results');
                            } else {
                              Navigator.pushReplacementNamed(context, '/practice-results');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.precisionBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('END MATCH', style: TallyTextStyles.button(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── MISS! Overlay (only for versus) ──
            if (isVersus && game.showMiss)
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
                          border: Border.all(
                            color: context.colors.persistentRed, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.persistentRed.withOpacity(0.3),
                              blurRadius: 30, spreadRadius: 5,
                            ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeScoreboard(GameService game) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('TALLY SCORE', style: TallyTextStyles.label(context)),
        const SizedBox(height: 4),
        Text('${game.score}',
          style: TallyTextStyles.scoreDisplay(context).copyWith(
            fontSize: 64, color: context.colors.precisionBlue)),
        if (!game.noTimeLimit) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.optimisticYellow),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: context.colors.optimisticYellow, size: 16),
                const SizedBox(width: 8),
                Text(game.timerDisplay,
                  style: TallyTextStyles.heading2(context).copyWith(
                    color: context.colors.optimisticYellow, fontSize: 20)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVersusScoreboard(GameService game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Team A
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                game.teamA.isNotEmpty ? game.teamA.first.name : 'ALPHA',
                style: TallyTextStyles.heading3(context).copyWith(
                  color: game.isTeamATurn
                      ? context.colors.precisionBlue
                      : context.colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('${game.teamAScore}',
                style: TallyTextStyles.scoreDisplay(context).copyWith(
                  fontSize: 48,
                  color: game.isTeamATurn
                      ? context.colors.precisionBlue
                      : context.colors.textSecondary,
                )),
            ],
          ),
        ),
        // VS divider with match timer
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('VS', style: TallyTextStyles.heading2(context).copyWith(
              color: context.colors.textTertiary, fontSize: 16)),
            if (!game.noTimeLimit) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.optimisticYellow.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(game.timerDisplay,
                  style: TallyTextStyles.label(context).copyWith(
                    color: context.colors.optimisticYellow, fontSize: 13)),
              ),
            ],
          ],
        ),
        // Team B
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                game.teamB.isNotEmpty ? game.teamB.first.name : 'BETA',
                style: TallyTextStyles.heading3(context).copyWith(
                  color: !game.isTeamATurn
                      ? context.colors.persistentRed
                      : context.colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('${game.teamBScore}',
                style: TallyTextStyles.scoreDisplay(context).copyWith(
                  fontSize: 48,
                  color: !game.isTeamATurn
                      ? context.colors.persistentRed
                      : context.colors.textSecondary,
                )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shot countdown ring widget ──
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
              Text(
                '$seconds',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text('s', style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }
}

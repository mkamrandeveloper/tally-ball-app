import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

/// Manages game state across all modes
class GameService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // Current session state
  GameMode? _currentMode;
  DifficultyLevel _difficulty = DifficultyLevel.amateur;
  int? _timeLimitMinutes;
  bool _noTimeLimit = false;
  SessionTallyTarget _sessionTarget = SessionTallyTarget.fiftyTo100;
  int _customSessionTarget = 50;
  int _score = 0;
  int _shotCount = 0;
  double _shotPower = 0;
  TargetZone? _lastHitZone;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _remainingSeconds = 0;
  Timer? _gameTimer;
  final Map<TargetZone, int> _zoneHits = {};

  // VS Mode
  TargetAim _targetAim = TargetAim.first300;
  final List<Player> _teamA = [];
  final List<Player> _teamB = [];
  int _teamAScore = 0;
  int _teamBScore = 0;
  final Map<TargetZone, int> _teamAZoneHits = {};
  final Map<TargetZone, int> _teamBZoneHits = {};
  bool _isTeamATurn = true;   // Turn tracking
  int _teamAPlayerIndex = 0;
  int _teamBPlayerIndex = 0;
  int _shotSecondsRemaining = 60; // Per-shot countdown
  bool _showMiss = false;         // Miss flash flag
  Timer? _shotTimer;              // Per-shot timer

  // Match Mode
  MatchFormat _matchFormat = MatchFormat.twoHalves;
  int _currentPeriod = 1;
  String _teamAName = '';
  String _teamBName = '';

  // History
  final List<PracticeResult> _practiceHistory = [];
  final List<SessionHistory> _sessionHistory = [];

  // Milestone Notifications
  String? _currentNotification;
  final Set<int> _reachedMilestones = {};
  StreamSubscription? _profileSubscription;
  StreamSubscription? _authSubscription;

  // User
  UserProfile _userProfile = UserProfile();

  GameService() {
    _initProfileListener();
  }

  void _initProfileListener() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _profileSubscription?.cancel();
        _profileSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            if (data != null) {
              _userProfile = UserProfile(
                name: data['name'] ?? 'Athlete',
                email: data['email'] ?? '',
                location: data['location'] ?? '',
                dob: data['dob'] != null ? DateTime.tryParse(data['dob']) : null,
              );
              notifyListeners();
            }
          }
        });
      } else {
        _profileSubscription?.cancel();
        _userProfile = UserProfile();
        notifyListeners();
      }
    });
  }

  // Getters
  GameMode? get currentMode => _currentMode;
  DifficultyLevel get difficulty => _difficulty;
  int? get timeLimitMinutes => _timeLimitMinutes;
  bool get noTimeLimit => _noTimeLimit;
  SessionTallyTarget get sessionTarget => _sessionTarget;
  int get customSessionTarget => _customSessionTarget;
  int get activeSessionTargetValue => _sessionTarget == SessionTallyTarget.custom ? _customSessionTarget : _sessionTarget.minTarget;
  int get score => _score;
  int get shotCount => _shotCount;
  double get shotPower => _shotPower;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get remainingSeconds => _remainingSeconds;
  String? get currentNotification => _currentNotification;
  TargetZone? get lastHitZone => _lastHitZone;
  Map<TargetZone, int> get zoneHits => Map.unmodifiable(_zoneHits);
  TargetAim get targetAim => _targetAim;
  List<Player> get teamA => _teamA;
  List<Player> get teamB => _teamB;
  int get teamAScore => _teamAScore;
  int get teamBScore => _teamBScore;
  Map<TargetZone, int> get teamAZoneHits => Map.unmodifiable(_teamAZoneHits);
  Map<TargetZone, int> get teamBZoneHits => Map.unmodifiable(_teamBZoneHits);
  bool get isTeamATurn => _isTeamATurn;
  int get shotSecondsRemaining => _shotSecondsRemaining;
  bool get showMiss => _showMiss;
  String get activeTeamName {
    if (_isTeamATurn) {
      if (_teamA.isNotEmpty) return _teamA[_teamAPlayerIndex % _teamA.length].name;
      return _teamAName.isNotEmpty ? _teamAName : 'TEAM A';
    } else {
      if (_teamB.isNotEmpty) return _teamB[_teamBPlayerIndex % _teamB.length].name;
      return _teamBName.isNotEmpty ? _teamBName : 'TEAM B';
    }
  }
  
  Player? get activePlayer {
    if (_isTeamATurn && _teamA.isNotEmpty) return _teamA[_teamAPlayerIndex % _teamA.length];
    if (!_isTeamATurn && _teamB.isNotEmpty) return _teamB[_teamBPlayerIndex % _teamB.length];
    return null;
  }
  MatchFormat get matchFormat => _matchFormat;
  int get currentPeriod => _currentPeriod;
  String get teamAName => _teamAName;
  String get teamBName => _teamBName;
  List<PracticeResult> get practiceHistory => _practiceHistory;
  List<SessionHistory> get sessionHistory => _sessionHistory;
  UserProfile get userProfile => _userProfile;

  int get allTimeHigh {
    if (_practiceHistory.isEmpty) return 0;
    return _practiceHistory.map((r) => r.totalTally).reduce(max);
  }

  int get totalSessions => _sessionHistory.length;

  int get averageScore {
    if (_practiceHistory.isEmpty) return 0;
    final total = _practiceHistory.map((r) => r.totalTally).reduce((a, b) => a + b);
    return total ~/ _practiceHistory.length;
  }

  // Setters
  void setDifficulty(DifficultyLevel d) { _difficulty = d; notifyListeners(); }
  void setTimeLimit(int? minutes) { _timeLimitMinutes = minutes; _noTimeLimit = minutes == null; notifyListeners(); }
  void setNoTimeLimit(bool v) { _noTimeLimit = v; if (v) _timeLimitMinutes = null; notifyListeners(); }
  void setSessionTarget(SessionTallyTarget t) { _sessionTarget = t; notifyListeners(); }
  void setCustomSessionTarget(int val) { _customSessionTarget = val < 50 ? 50 : val; notifyListeners(); }
  void clearNotification() { _currentNotification = null; notifyListeners(); }
  void setTargetAim(TargetAim aim) { _targetAim = aim; notifyListeners(); }
  void setMatchFormat(MatchFormat f) { _matchFormat = f; notifyListeners(); }
  void setTeamAName(String n) { _teamAName = n; notifyListeners(); }
  void setTeamBName(String n) { _teamBName = n; notifyListeners(); }
  void updateProfile(UserProfile p) { _userProfile = p; notifyListeners(); }

  void addPlayerToTeamA(String name) {
    _teamA.add(Player(id: 'A${_teamA.length}', name: name));
    notifyListeners();
  }
  void addPlayerToTeamB(String name) {
    _teamB.add(Player(id: 'B${_teamB.length}', name: name));
    notifyListeners();
  }
  void removePlayerFromTeamA(int index) {
    if (index < _teamA.length) _teamA.removeAt(index);
    notifyListeners();
  }
  void removePlayerFromTeamB(int index) {
    if (index < _teamB.length) _teamB.removeAt(index);
    notifyListeners();
  }

  /// Start a practice session
  void startPractice() {
    _currentMode = GameMode.practice;
    _score = 0;
    _shotCount = 0;
    _shotPower = 0;
    _lastHitZone = null;
    _zoneHits.clear();
    _reachedMilestones.clear();
    _currentNotification = null;
    _isPlaying = true;
    _isPaused = false;

    if (!_noTimeLimit && _timeLimitMinutes != null) {
      _remainingSeconds = _timeLimitMinutes! * 60;
      _startTimer();
    } else {
      _remainingSeconds = 0;
    }
    notifyListeners();
  }

  /// Start a VS session
  void startVersus() {
    _currentMode = GameMode.versus;
    _teamAScore = 0;
    _teamBScore = 0;
    _teamAPlayerIndex = 0;
    _teamBPlayerIndex = 0;
    for (var p in _teamA) {
      p.score = 0;
    }
    for (var p in _teamB) {
      p.score = 0;
    }
    _shotCount = 0;
    _teamAZoneHits.clear();
    _teamBZoneHits.clear();
    _isPlaying = true;
    _isPaused = false;
    _isTeamATurn = true;
    _showMiss = false;

    if (!_noTimeLimit && _timeLimitMinutes != null) {
      _remainingSeconds = _timeLimitMinutes! * 60;
      _startTimer();
    }
    _startShotTimer();
    notifyListeners();
  }

  /// Start the 60-second per-shot countdown
  void _startShotTimer() {
    _shotTimer?.cancel();
    _shotSecondsRemaining = 60;
    _shotTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || !_isPlaying) return;
      if (_shotSecondsRemaining > 0) {
        _shotSecondsRemaining--;
        notifyListeners();
      } else {
        // Time up — MISS! Switch turns
        _showMiss = true;
        notifyListeners();
        Timer(const Duration(seconds: 2), () {
          _showMiss = false;
          _switchTurn();
        });
      }
    });
  }

  /// Switch to the other team's turn
  void _switchTurn() {
    _shotTimer?.cancel();
    if (_isTeamATurn) {
      _teamAPlayerIndex++;
    } else {
      _teamBPlayerIndex++;
    }
    _isTeamATurn = !_isTeamATurn;
    _shotSecondsRemaining = 60;
    notifyListeners();
    // Restart the shot countdown for the new team
    _startShotTimer();
  }

  /// Start a match session
  void startMatch() {
    _currentMode = GameMode.match;
    _teamAScore = 0;
    _teamBScore = 0;
    _teamAPlayerIndex = 0;
    _teamBPlayerIndex = 0;
    _teamAZoneHits.clear();
    _teamBZoneHits.clear();
    _currentPeriod = 1;
    _isPlaying = true;
    _isPaused = false;
    _isTeamATurn = true;
    _showMiss = false;
    _remainingSeconds = _matchFormat.minutesPerPeriod * 60;
    _startTimer();
    _startShotTimer();
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
        if (_remainingSeconds <= 0) {
          _onTimerEnd();
        }
      }
    });
  }

  void _onTimerEnd() {
    if (_currentMode == GameMode.match && _currentPeriod < _matchFormat.periods) {
      // Period ended — reset for next period
      _shotTimer?.cancel();
      _currentPeriod++;
      _remainingSeconds = _matchFormat.minutesPerPeriod * 60;
      _isTeamATurn = true; // Team A always starts a new period
      _showMiss = false;
      notifyListeners();
      // Brief pause then restart the shot timer for the new period
      Timer(const Duration(seconds: 3), () {
        if (_isPlaying) _startShotTimer();
      });
    } else {
      endSession();
    }
  }



  /// Record a real hit from Bluetooth hardware
  void recordHardwareHit(TargetZone zone, double power) {
    if (!_isPlaying || _isPaused) return;

    _zoneHits[zone] = (_zoneHits[zone] ?? 0) + 1;
    _lastHitZone = zone;
    _score += zone.points;
    _shotCount++;
    _shotPower = power;

    // In competitive modes, attribute hit to the active team
    if (_currentMode == GameMode.versus || _currentMode == GameMode.match) {
      if (_isTeamATurn) {
        _teamAScore += zone.points;
        _teamAZoneHits[zone] = (_teamAZoneHits[zone] ?? 0) + 1;
        if (_teamA.isNotEmpty) {
          _teamA[_teamAPlayerIndex % _teamA.length].score += zone.points;
        }
      } else {
        _teamBScore += zone.points;
        _teamBZoneHits[zone] = (_teamBZoneHits[zone] ?? 0) + 1;
        if (_teamB.isNotEmpty) {
          _teamB[_teamBPlayerIndex % _teamB.length].score += zone.points;
        }
      }
      _switchTurn();
    }

    _checkMilestones();
    notifyListeners();
  }

  void _checkMilestones() {
    if (_currentMode != GameMode.practice) return;
    
    // Milestones definition based on client feedback
    final milestones = {
      300: "Well done! You're ready to go semi-pro",
      1000: "Let’s go! You’re ready to go pro!",
      2500: "You’re smashing it! Let’s turn up the levels!",
      5000: "Elite ball tech! Remember how far you’ve come!",
    };

    for (var m in milestones.keys.toList()..sort((a,b) => b.compareTo(a))) {
      if (_score >= m && !_reachedMilestones.contains(m)) {
        _reachedMilestones.add(m);
        _currentNotification = milestones[m];
        
        // Auto-clear notification after 5 seconds
        Timer(const Duration(seconds: 5), () {
          _currentNotification = null;
          notifyListeners();
        });
        break; 
      }
    }
  }

  void togglePause() {
    _isPaused = !_isPaused;
    if (_currentMode == GameMode.versus) {
      if (_isPaused) {
        _shotTimer?.cancel();
      } else {
        _startShotTimer();
      }
    }
    notifyListeners();
  }

  void endSession() {
    _gameTimer?.cancel();
    _shotTimer?.cancel();
    _isPlaying = false;

    if (_currentMode == GameMode.practice) {
      final result = PracticeResult(
        totalTally: _score,
        shotCount: _shotCount,
        avgShotPower: _shotPower,
        accuracy: _shotCount > 0 ? (70 + Random().nextInt(25)).toDouble() : 0,
        zoneHits: Map.from(_zoneHits),
        dateTime: DateTime.now(),
        difficulty: _difficulty,
        aiSummary: _generateAiSummary(),
      );
      _practiceHistory.add(result);
    }

    _sessionHistory.add(SessionHistory(
      date: DateTime.now(),
      mode: _currentMode ?? GameMode.practice,
      focusArea: 'Training',
      score: _score,
    ));

    // Persist to Firebase
    _persistSession();

    notifyListeners();
  }

  Future<void> _persistSession() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _dbService.saveGameSession(
          uid: user.uid,
          sessionData: {
            'mode': _currentMode?.name ?? 'practice',
            'score': _score,
            'shotCount': _shotCount,
            'avgShotPower': _shotPower,
            'difficulty': _difficulty.name,
            'teamAScore': _teamAScore,
            'teamBScore': _teamBScore,
          },
        );
      } catch (e) {
        debugPrint('Error persisting session: $e');
      }
    }
  }

  String _generateAiSummary() {
    final summaries = [
      'Your accuracy in top corners has improved by 15% since last session. Focus on lower-left velocity for optimal performance.',
      'Strong session! Shot consistency is up. Try increasing difficulty to challenge yourself.',
      'Great power stats today. Consider working on center accuracy for higher scores.',
      'You\'re smashing it! Let\'s turn up the levels! Your consistency is building well.',
    ];
    return summaries[Random().nextInt(summaries.length)];
  }

  String get timerDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shotTimer?.cancel();
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}

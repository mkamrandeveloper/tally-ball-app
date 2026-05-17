/// Game mode types
enum GameMode { practice, versus, match }

/// Difficulty levels for Practice Mode
enum DifficultyLevel {
  amateur(name: 'Amateur', minScore: 300, maxScore: 500),
  semiPro(name: 'Semi-Pro', minScore: 900, maxScore: 2000),
  pro(name: 'Pro', minScore: 4000, maxScore: 6000),
  worldClass(name: 'World Class', minScore: 8000, maxScore: 10000),
  elite(name: 'Elite', minScore: 12000, maxScore: 15000);

  const DifficultyLevel({required this.name, required this.minScore, required this.maxScore});
  final String name;
  final int minScore;
  final int maxScore;

  String get rangeDisplay {
    String fmt(int n) {
      // Format with comma separators
      final s = n.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return '${fmt(minScore)}-${fmt(maxScore)}';
  }
}

/// Target zones in a goal
enum TargetZone {
  topLeft(name: 'Top Left', points: 20),
  topRight(name: 'Top Right', points: 20),
  center(name: 'Dead Center', points: 30),
  bottomLeft(name: 'Bottom Left', points: 10),
  bottomRight(name: 'Bottom Right', points: 10);

  const TargetZone({required this.name, required this.points});
  final String name;
  final int points;
}

/// Match format
enum MatchFormat {
  twoHalves(name: '2 Halves', description: 'Standard professional format. 20 minutes per half.', periods: 2, minutesPerPeriod: 20),
  fourQuarters(name: '4 Quarters', description: 'Collegiate/High School format. 15 minutes per quarter.', periods: 4, minutesPerPeriod: 15);

  const MatchFormat({required this.name, required this.description, required this.periods, required this.minutesPerPeriod});
  final String name;
  final String description;
  final int periods;
  final int minutesPerPeriod;
}

/// Target aim for VS mode
enum TargetAim {
  first300(target: 300),
  first500(target: 500),
  first1000(target: 1000);

  const TargetAim({required this.target});
  final int target;

  String get display => target >= 1000 ? '${(target / 1000).toStringAsFixed(0)}K' : '$target';
}

/// Target for a Practice Session
enum SessionTallyTarget {
  fiftyTo100(name: '50-100', minTarget: 50),
  oneFiftyTo300(name: '150-300', minTarget: 150),
  threeHundredTo500(name: '300-500', minTarget: 300),
  fiveHundredPlus(name: '500+', minTarget: 500),
  custom(name: 'Custom', minTarget: 50);

  const SessionTallyTarget({required this.name, required this.minTarget});
  final String name;
  final int minTarget;
}

/// A player in a game session
class Player {
  final String id;
  String name;
  int score;

  Player({required this.id, required this.name, this.score = 0});
}

/// Practice session result
class PracticeResult {
  final int totalTally;
  final int shotCount;
  final double avgShotPower;
  final double accuracy;
  final Map<TargetZone, int> zoneHits;
  final DateTime dateTime;
  final DifficultyLevel difficulty;
  final String aiSummary;

  PracticeResult({
    required this.totalTally,
    required this.shotCount,
    required this.avgShotPower,
    required this.accuracy,
    required this.zoneHits,
    required this.dateTime,
    required this.difficulty,
    required this.aiSummary,
  });
}

/// Session history entry
class SessionHistory {
  final DateTime date;
  final GameMode mode;
  final String focusArea;
  final int score;

  SessionHistory({
    required this.date,
    required this.mode,
    required this.focusArea,
    required this.score,
  });
}

/// User profile
class UserProfile {
  String name;
  String email;
  String phone;
  DateTime? dob;
  String? location;
  double? heightCm;
  double? weightKg;
  String? role;
  int totalTallyTarget; // Overall long-term goal

  UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob,
    this.location,
    this.heightCm,
    this.weightKg,
    this.role,
    this.totalTallyTarget = 10000,
  });
}

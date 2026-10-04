import 'belt_rank.dart';
import 'taf_test_type.dart';

class TafRequirement {
  const TafRequirement({
    required this.beltRank,
    required this.testType,
    required this.targetValue,
    required this.targetDisplay,
    this.distanceKm,
    this.timeLimitSeconds,
    this.rounds = 1,
  });

  final BeltRank beltRank;
  final TafTestType testType;
  final double targetValue; // For reps: number of reps. For running: target time in seconds
  final String targetDisplay;
  final double? distanceKm;
  final int? timeLimitSeconds;
  final int rounds;

  /// Check if a given performance achieves or passes the target.
  bool isAchieved({required double value, int? seconds}) {
    if (testType == TafTestType.corrida) {
      final actualSeconds = seconds ?? value.toInt();
      if (actualSeconds <= 0) return false;
      final targetSeconds = timeLimitSeconds ?? targetValue.toInt();
      // For running: less time or equal is success
      return actualSeconds <= targetSeconds;
    } else {
      // For strength exercises: higher or equal is success
      return value >= targetValue;
    }
  }

  /// Calculates percentage of achievement (0.0 to 100.0+).
  double calculateProgress({required double value, int? seconds}) {
    if (testType == TafTestType.corrida) {
      final actualSeconds = seconds ?? value.toInt();
      if (actualSeconds <= 0) return 0.0;
      final targetSeconds = timeLimitSeconds ?? targetValue.toInt();
      if (targetSeconds <= 0) return 0.0;
      // If actual is smaller than or equal, progress >= 100%
      // Example: target 600s, actual 700s => (600 / 700) * 100 = 85.7%
      final progress = (targetSeconds / actualSeconds) * 100.0;
      return progress.clamp(0.0, 150.0);
    } else {
      if (targetValue <= 0) return 100.0;
      final progress = (value / targetValue) * 100.0;
      return progress.clamp(0.0, 200.0);
    }
  }

  static List<TafRequirement> getRequirementsForBelt(BeltRank belt) {
    switch (belt) {
      case BeltRank.branca:
      case BeltRank.amarela:
        return const [];

      case BeltRank.laranja:
        return const [
          TafRequirement(
            beltRank: BeltRank.laranja,
            testType: TafTestType.corrida,
            targetValue: 600, // 10 min = 600s
            distanceKm: 1.8,
            timeLimitSeconds: 600,
            targetDisplay: '1.8 km em até 10 min (ritmo ~5:33/km)',
          ),
        ];

      case BeltRank.verde:
        return const [
          TafRequirement(
            beltRank: BeltRank.verde,
            testType: TafTestType.corrida,
            targetValue: 1020, // 17 min = 1020s
            distanceKm: 3.0,
            timeLimitSeconds: 1020,
            targetDisplay: '3.0 km em até 17 min (ritmo ~5:40/km)',
          ),
          TafRequirement(
            beltRank: BeltRank.verde,
            testType: TafTestType.barraFixa,
            targetValue: 5,
            targetDisplay: '5 repetições (pegada pronada)',
          ),
          TafRequirement(
            beltRank: BeltRank.verde,
            testType: TafTestType.flexao,
            targetValue: 30,
            targetDisplay: '30 repetições',
          ),
          TafRequirement(
            beltRank: BeltRank.verde,
            testType: TafTestType.abdominal,
            targetValue: 60,
            targetDisplay: '60 repetições em 2 minutos',
          ),
          TafRequirement(
            beltRank: BeltRank.verde,
            testType: TafTestType.pesinhos,
            targetValue: 3,
            targetDisplay: '3 repetições (série oficial)',
          ),
          TafRequirement(
            beltRank: BeltRank.verde,
            testType: TafTestType.paralelas,
            targetValue: 8,
            targetDisplay: '8 repetições',
          ),
        ];

      case BeltRank.azul:
        return const [
          TafRequirement(
            beltRank: BeltRank.azul,
            testType: TafTestType.corrida,
            targetValue: 840, // 14 min = 840s
            distanceKm: 3.0,
            timeLimitSeconds: 840,
            targetDisplay: '3.0 km em até 14 min (ritmo ~4:40/km)',
          ),
          TafRequirement(
            beltRank: BeltRank.azul,
            testType: TafTestType.barraFixa,
            targetValue: 10,
            targetDisplay: '10 repetições (pegada pronada)',
          ),
          TafRequirement(
            beltRank: BeltRank.azul,
            testType: TafTestType.flexao,
            targetValue: 60,
            targetDisplay: '60 repetições',
          ),
          TafRequirement(
            beltRank: BeltRank.azul,
            testType: TafTestType.abdominal,
            targetValue: 80,
            targetDisplay: '80 repetições em 2 minutos',
          ),
          TafRequirement(
            beltRank: BeltRank.azul,
            testType: TafTestType.pesinhos,
            targetValue: 5,
            targetDisplay: '5 repetições (série oficial)',
          ),
          TafRequirement(
            beltRank: BeltRank.azul,
            testType: TafTestType.paralelas,
            targetValue: 15,
            targetDisplay: '15 repetições',
          ),
        ];

      case BeltRank.marrom:
        return const [
          TafRequirement(
            beltRank: BeltRank.marrom,
            testType: TafTestType.corrida,
            targetValue: 840, // 14 min = 840s
            distanceKm: 3.0,
            timeLimitSeconds: 840,
            targetDisplay: '3.0 km em até 14 min (ritmo ~4:40/km)',
          ),
          TafRequirement(
            beltRank: BeltRank.marrom,
            testType: TafTestType.barraFixa,
            targetValue: 10,
            targetDisplay: '10 repetições (pegada pronada)',
          ),
          TafRequirement(
            beltRank: BeltRank.marrom,
            testType: TafTestType.flexao,
            targetValue: 60,
            targetDisplay: '60 repetições',
          ),
          TafRequirement(
            beltRank: BeltRank.marrom,
            testType: TafTestType.abdominal,
            targetValue: 80,
            targetDisplay: '80 repetições em 2 minutos',
          ),
          TafRequirement(
            beltRank: BeltRank.marrom,
            testType: TafTestType.pesinhos,
            targetValue: 5,
            targetDisplay: '5 repetições (série oficial)',
          ),
          TafRequirement(
            beltRank: BeltRank.marrom,
            testType: TafTestType.paralelas,
            targetValue: 15,
            targetDisplay: '15 repetições',
          ),
        ];

      case BeltRank.preta:
        return const [
          TafRequirement(
            beltRank: BeltRank.preta,
            testType: TafTestType.corrida,
            targetValue: 840,
            distanceKm: 3.0,
            timeLimitSeconds: 840,
            rounds: 3,
            targetDisplay: '3.0 km em até 14 min (série de 3x)',
          ),
          TafRequirement(
            beltRank: BeltRank.preta,
            testType: TafTestType.barraFixa,
            targetValue: 10,
            rounds: 3,
            targetDisplay: '3 séries de 10 reps (total 30 reps)',
          ),
          TafRequirement(
            beltRank: BeltRank.preta,
            testType: TafTestType.flexao,
            targetValue: 60,
            rounds: 3,
            targetDisplay: '3 séries de 60 reps (total 180 reps)',
          ),
          TafRequirement(
            beltRank: BeltRank.preta,
            testType: TafTestType.abdominal,
            targetValue: 80,
            rounds: 3,
            targetDisplay: '3 séries de 80 reps em 2 min cada (total 240)',
          ),
          TafRequirement(
            beltRank: BeltRank.preta,
            testType: TafTestType.pesinhos,
            targetValue: 5,
            rounds: 3,
            targetDisplay: '3 séries de 5 reps (total 15 reps)',
          ),
          TafRequirement(
            beltRank: BeltRank.preta,
            testType: TafTestType.paralelas,
            targetValue: 15,
            rounds: 3,
            targetDisplay: '3 séries de 15 reps (total 45 reps)',
          ),
        ];
    }
  }
}

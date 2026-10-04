import '../data/models/belt_rank.dart';
import '../data/models/taf_requirement.dart';
import '../data/models/taf_test_type.dart';
import '../data/models/workout_log.dart';

class TafTestStatus {
  const TafTestStatus({
    required this.testType,
    required this.requirement,
    required this.bestLog,
    required this.latestLog,
    required this.isApproved,
    required this.progressPercentage,
    required this.statusMessage,
  });

  final TafTestType testType;
  final TafRequirement? requirement;
  final WorkoutLog? bestLog;
  final WorkoutLog? latestLog;
  final bool isApproved;
  final double progressPercentage;
  final String statusMessage;
}

class TafEvaluator {
  static List<TafTestStatus> evaluateAllTests({
    required BeltRank targetBelt,
    required List<WorkoutLog> logs,
  }) {
    final requirements = TafRequirement.getRequirementsForBelt(targetBelt);
    final reqMap = {for (var r in requirements) r.testType: r};

    return TafTestType.values.map((testType) {
      final req = reqMap[testType];
      final relevantLogs = logs.where((l) => l.testType == testType).toList();

      if (relevantLogs.isEmpty) {
        return TafTestStatus(
          testType: testType,
          requirement: req,
          bestLog: null,
          latestLog: null,
          isApproved: req == null, // If no requirement (e.g. white/yellow or Orange non-running)
          progressPercentage: 0.0,
          statusMessage: req != null ? 'Sem registro de treino' : 'Não exigido para esta faixa',
        );
      }

      // Sort relevant logs to find latest and best
      final sortedByDate = List<WorkoutLog>.from(relevantLogs)
        ..sort((a, b) => b.date.compareTo(a.date));
      final latest = sortedByDate.first;

      WorkoutLog best;
      if (testType == TafTestType.corrida) {
        // For running, lower time is best
        final runsWithTime = relevantLogs.where((l) => l.timeInSeconds != null && l.timeInSeconds! > 0).toList();
        if (runsWithTime.isNotEmpty) {
          runsWithTime.sort((a, b) => a.timeInSeconds!.compareTo(b.timeInSeconds!));
          best = runsWithTime.first;
        } else {
          best = latest;
        }
      } else {
        // For reps, higher value is best
        final repsLogs = List<WorkoutLog>.from(relevantLogs)
          ..sort((a, b) => b.value.compareTo(a.value));
        best = repsLogs.first;
      }

      if (req == null) {
        return TafTestStatus(
          testType: testType,
          requirement: null,
          bestLog: best,
          latestLog: latest,
          isApproved: true,
          progressPercentage: 100.0,
          statusMessage: 'Não exigido para ${targetBelt.name}',
        );
      }

      final isApproved = req.isAchieved(
        value: best.value,
        seconds: best.timeInSeconds,
      );

      final progress = req.calculateProgress(
        value: best.value,
        seconds: best.timeInSeconds,
      );

      String statusMessage;
      if (isApproved) {
        statusMessage = 'Aprovado! Meta superada';
      } else {
        if (testType == TafTestType.corrida) {
          final targetSec = req.timeLimitSeconds ?? req.targetValue.toInt();
          final bestSec = best.timeInSeconds ?? best.value.toInt();
          final diffSec = bestSec - targetSec;
          final diffMin = diffSec ~/ 60;
          final diffRemSec = diffSec % 60;
          final timeStr = diffMin > 0 ? '$diffMin min ${diffRemSec}s' : '${diffRemSec}s';
          statusMessage = 'Faltam baixar $timeStr no tempo';
        } else {
          final diff = (req.targetValue - best.value).toInt();
          statusMessage = 'Faltam $diff ${testType.unit} para a meta';
        }
      }

      return TafTestStatus(
        testType: testType,
        requirement: req,
        bestLog: best,
        latestLog: latest,
        isApproved: isApproved,
        progressPercentage: progress,
        statusMessage: statusMessage,
      );
    }).toList();
  }

  /// Calculates overall completion percentage for target belt (0 to 100)
  static double calculateOverallScore(List<TafTestStatus> statuses) {
    final requiredStatuses = statuses.where((s) => s.requirement != null).toList();
    if (requiredStatuses.isEmpty) return 100.0;

    final totalProgress = requiredStatuses.fold<double>(
      0.0,
      (sum, s) => sum + (s.progressPercentage > 100 ? 100 : s.progressPercentage),
    );
    return totalProgress / requiredStatuses.length;
  }

  static int countApproved(List<TafTestStatus> statuses) {
    final requiredStatuses = statuses.where((s) => s.requirement != null).toList();
    return requiredStatuses.where((s) => s.isApproved).length;
  }

  static int totalRequired(List<TafTestStatus> statuses) {
    return statuses.where((s) => s.requirement != null).length;
  }
}

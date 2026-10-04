import 'package:intl/intl.dart';
import 'taf_test_type.dart';

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.date,
    required this.testType,
    required this.isOfficialTaf,
    required this.value,
    this.timeInSeconds,
    this.distanceKm,
    this.auxiliaryExerciseId,
    this.auxiliaryExerciseName,
    this.notes = '',
    this.rpe = 7, // 1 to 10
    this.roundsCompleted = 1,
  });

  final String id;
  final DateTime date;
  final TafTestType testType;
  final bool isOfficialTaf;
  final double value; // For reps: count. For running: distance in km or seconds
  final int? timeInSeconds;
  final double? distanceKm;
  final String? auxiliaryExerciseId;
  final String? auxiliaryExerciseName;
  final String notes;
  final int rpe;
  final int roundsCompleted;

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(date);

  String get formattedTime {
    if (timeInSeconds == null) return '';
    final minutes = timeInSeconds! ~/ 60;
    final seconds = timeInSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPace {
    if (timeInSeconds == null || distanceKm == null || distanceKm! <= 0) return '';
    final totalSeconds = timeInSeconds!;
    final pacePerKm = totalSeconds / distanceKm!;
    final paceMin = pacePerKm ~/ 60;
    final paceSec = (pacePerKm % 60).round();
    return '$paceMin:${paceSec.toString().padLeft(2, '0')}/km';
  }

  String get formattedPerformance {
    if (testType == TafTestType.corrida) {
      final dist = distanceKm ?? (value > 10 ? 3.0 : value);
      final timeStr = formattedTime;
      return '$dist km em $timeStr';
    } else {
      final reps = value.toInt();
      if (roundsCompleted > 1) {
        return '$reps reps ($roundsCompleted rounds)';
      }
      return '$reps ${testType.unit}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'testType': testType.id,
      'isOfficialTaf': isOfficialTaf,
      'value': value,
      'timeInSeconds': timeInSeconds,
      'distanceKm': distanceKm,
      'auxiliaryExerciseId': auxiliaryExerciseId,
      'auxiliaryExerciseName': auxiliaryExerciseName,
      'notes': notes,
      'rpe': rpe,
      'roundsCompleted': roundsCompleted,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      testType: TafTestType.fromId(json['testType'] as String),
      isOfficialTaf: json['isOfficialTaf'] as bool? ?? true,
      value: (json['value'] as num).toDouble(),
      timeInSeconds: json['timeInSeconds'] as int?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      auxiliaryExerciseId: json['auxiliaryExerciseId'] as String?,
      auxiliaryExerciseName: json['auxiliaryExerciseName'] as String?,
      notes: json['notes'] as String? ?? '',
      rpe: json['rpe'] as int? ?? 7,
      roundsCompleted: json['roundsCompleted'] as int? ?? 1,
    );
  }

  WorkoutLog copyWith({
    String? id,
    DateTime? date,
    TafTestType? testType,
    bool? isOfficialTaf,
    double? value,
    int? timeInSeconds,
    double? distanceKm,
    String? auxiliaryExerciseId,
    String? auxiliaryExerciseName,
    String? notes,
    int? rpe,
    int roundsCompleted = 1,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      date: date ?? this.date,
      testType: testType ?? this.testType,
      isOfficialTaf: isOfficialTaf ?? this.isOfficialTaf,
      value: value ?? this.value,
      timeInSeconds: timeInSeconds ?? this.timeInSeconds,
      distanceKm: distanceKm ?? this.distanceKm,
      auxiliaryExerciseId: auxiliaryExerciseId ?? this.auxiliaryExerciseId,
      auxiliaryExerciseName: auxiliaryExerciseName ?? this.auxiliaryExerciseName,
      notes: notes ?? this.notes,
      rpe: rpe ?? this.rpe,
      roundsCompleted: roundsCompleted,
    );
  }
}

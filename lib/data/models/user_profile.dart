import 'belt_rank.dart';

class UserProfile {
  const UserProfile({
    this.name = 'Praticante de Krav Maga',
    this.dojo = 'Centro de Treinamento FSAKM',
    this.instructor = '',
    this.currentBelt = BeltRank.amarela,
    this.targetBelt = BeltRank.laranja,
    this.weightKg = 75.0,
    this.targetExamDate,
  });

  final String name;
  final String dojo;
  final String instructor;
  final BeltRank currentBelt;
  final BeltRank targetBelt;
  final double weightKg;
  final DateTime? targetExamDate;

  int? get daysUntilExam {
    if (targetExamDate == null) return null;
    final now = DateTime.now();
    final difference = targetExamDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
    return difference;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dojo': dojo,
      'instructor': instructor,
      'currentBelt': currentBelt.id,
      'targetBelt': targetBelt.id,
      'weightKg': weightKg,
      'targetExamDate': targetExamDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Praticante de Krav Maga',
      dojo: json['dojo'] as String? ?? 'Centro de Treinamento FSAKM',
      instructor: json['instructor'] as String? ?? '',
      currentBelt: BeltRank.fromId(json['currentBelt'] as String? ?? 'amarela'),
      targetBelt: BeltRank.fromId(json['targetBelt'] as String? ?? 'laranja'),
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 75.0,
      targetExamDate: json['targetExamDate'] != null
          ? DateTime.tryParse(json['targetExamDate'] as String)
          : null,
    );
  }

  UserProfile copyWith({
    String? name,
    String? dojo,
    String? instructor,
    BeltRank? currentBelt,
    BeltRank? targetBelt,
    double? weightKg,
    DateTime? targetExamDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dojo: dojo ?? this.dojo,
      instructor: instructor ?? this.instructor,
      currentBelt: currentBelt ?? this.currentBelt,
      targetBelt: targetBelt ?? this.targetBelt,
      weightKg: weightKg ?? this.weightKg,
      targetExamDate: targetExamDate ?? this.targetExamDate,
    );
  }
}

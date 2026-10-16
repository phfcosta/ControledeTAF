import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/auxiliary_exercise.dart';
import '../../../data/models/belt_rank.dart';
import '../../../data/models/taf_test_type.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/workout_log.dart';
import '../../../data/repositories/taf_repository.dart';
import '../../../domain/taf_evaluator.dart';

class TafViewModel extends ChangeNotifier {
  TafViewModel({TafRepository? repository})
      : _repository = repository ?? TafRepository();

  final TafRepository _repository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  List<WorkoutLog> _workoutLogs = [];
  List<WorkoutLog> get workoutLogs => List.unmodifiable(_workoutLogs);

  List<AuxiliaryExercise> _auxiliaryExercises = [];
  List<AuxiliaryExercise> get auxiliaryExercises => List.unmodifiable(_auxiliaryExercises);

  // Selected filter for workout logs
  TafTestType? _selectedTestFilter;
  TafTestType? get selectedTestFilter => _selectedTestFilter;

  // Search filter for auxiliary exercises
  String _exerciseSearchQuery = '';
  String get exerciseSearchQuery => _exerciseSearchQuery;

  TafTestType? _exerciseCategoryFilter;
  TafTestType? get exerciseCategoryFilter => _exerciseCategoryFilter;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
      _workoutLogs = await _repository.getWorkoutLogs();
      _auxiliaryExercises = await _repository.getAuxiliaryExercises();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Computed Evaluation Metrics ---

  List<TafTestStatus> get testStatuses {
    return TafEvaluator.evaluateAllTests(
      targetBelt: _profile.targetBelt,
      logs: _workoutLogs,
    );
  }

  double get overallProgress {
    return TafEvaluator.calculateOverallScore(testStatuses);
  }

  int get approvedCount {
    return TafEvaluator.countApproved(testStatuses);
  }

  int get totalRequiredCount {
    return TafEvaluator.totalRequired(testStatuses);
  }

  bool get isFullyApproved {
    return totalRequiredCount > 0 && approvedCount == totalRequiredCount;
  }

  // --- Filtered Logs ---

  List<WorkoutLog> get filteredWorkoutLogs {
    if (_selectedTestFilter == null) {
      return _workoutLogs;
    }
    return _workoutLogs.where((l) => l.testType == _selectedTestFilter).toList();
  }

  List<WorkoutLog> getLogsForTest(TafTestType type) {
    final list = _workoutLogs.where((l) => l.testType == type).toList();
    list.sort((a, b) => a.date.compareTo(b.date)); // ascending for chronological chart
    return list;
  }

  void setTestFilter(TafTestType? filter) {
    _selectedTestFilter = filter;
    notifyListeners();
  }

  // --- Filtered Auxiliary Exercises ---

  List<AuxiliaryExercise> get filteredExercises {
    return _auxiliaryExercises.where((exercise) {
      final matchesCategory = _exerciseCategoryFilter == null ||
          exercise.category == _exerciseCategoryFilter;
      final matchesQuery = _exerciseSearchQuery.isEmpty ||
          exercise.name.toLowerCase().contains(_exerciseSearchQuery.toLowerCase()) ||
          exercise.description.toLowerCase().contains(_exerciseSearchQuery.toLowerCase()) ||
          exercise.musclesTargeted.any(
            (m) => m.toLowerCase().contains(_exerciseSearchQuery.toLowerCase()),
          );
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void setExerciseSearch(String query) {
    _exerciseSearchQuery = query;
    notifyListeners();
  }

  void setExerciseCategory(TafTestType? category) {
    _exerciseCategoryFilter = category;
    notifyListeners();
  }

  // --- Profile Actions ---

  Future<void> updateProfile({
    String? name,
    String? dojo,
    String? instructor,
    BeltRank? currentBelt,
    BeltRank? targetBelt,
    double? weightKg,
    DateTime? targetExamDate,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      dojo: dojo,
      instructor: instructor,
      currentBelt: currentBelt,
      targetBelt: targetBelt,
      weightKg: weightKg,
      targetExamDate: targetExamDate,
    );
    notifyListeners();
    await _repository.updateProfile(_profile);
  }

  Future<void> setTargetBelt(BeltRank belt) async {
    if (_profile.targetBelt == belt) return;
    _profile = _profile.copyWith(targetBelt: belt);
    notifyListeners();
    await _repository.updateProfile(_profile);
  }

  Future<void> setCurrentBelt(BeltRank belt) async {
    if (_profile.currentBelt == belt) return;
    _profile = _profile.copyWith(currentBelt: belt);
    notifyListeners();
    await _repository.updateProfile(_profile);
  }

  // --- Workout Log Actions ---

  Future<void> addWorkoutLog(WorkoutLog log) async {
    _workoutLogs.insert(0, log);
    notifyListeners();
    await _repository.addWorkoutLog(log);
  }

  Future<void> updateWorkoutLog(WorkoutLog updatedLog) async {
    final index = _workoutLogs.indexWhere((l) => l.id == updatedLog.id);
    if (index != -1) {
      _workoutLogs[index] = updatedLog;
      notifyListeners();
      await _repository.updateWorkoutLog(updatedLog);
    }
  }

  Future<void> deleteWorkoutLog(String id) async {
    _workoutLogs.removeWhere((l) => l.id == id);
    notifyListeners();
    await _repository.deleteWorkoutLog(id);
  }

  // --- Auxiliary Exercise Actions ---

  Future<void> addCustomAuxiliaryExercise(AuxiliaryExercise exercise) async {
    _auxiliaryExercises.add(exercise);
    notifyListeners();
    await _repository.addAuxiliaryExercise(exercise);
  }

  Future<void> updateAuxiliaryExercise(AuxiliaryExercise exercise) async {
    final index = _auxiliaryExercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _auxiliaryExercises[index] = exercise;
      notifyListeners();
      await _repository.updateAuxiliaryExercise(exercise);
    }
  }

  Future<void> deleteAuxiliaryExercise(String id) async {
    _auxiliaryExercises.removeWhere((e) => e.id == id);
    notifyListeners();
    await _repository.deleteAuxiliaryExercise(id);
  }

  Future<void> deleteCustomAuxiliaryExercise(String id) =>
      deleteAuxiliaryExercise(id);

  String exportAuxiliaryExercisesJson() {
    final jsonList = _auxiliaryExercises.map((e) => e.toJson()).toList();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonList);
  }

  Future<int> importAuxiliaryExercisesFromJson(
    String jsonStr, {
    bool replaceAll = false,
  }) async {
    final dynamic decoded = jsonDecode(jsonStr);
    List<dynamic> list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['exercises'] is List) {
      list = decoded['exercises'] as List<dynamic>;
    } else {
      throw const FormatException(
        'O formato JSON deve ser uma lista de exercícios ou um objeto com a chave "exercises".',
      );
    }

    final importedExercises = <AuxiliaryExercise>[];
    for (var item in list) {
      if (item is Map<String, dynamic>) {
        var ex = AuxiliaryExercise.fromJson(item);
        if (ex.id.trim().isEmpty) {
          ex = ex.copyWith(id: const Uuid().v4());
        }
        importedExercises.add(ex);
      }
    }

    if (importedExercises.isEmpty) {
      throw const FormatException(
        'Nenhum exercício válido foi encontrado no JSON fornecido.',
      );
    }

    if (replaceAll) {
      _auxiliaryExercises = List.from(importedExercises);
    } else {
      final Map<String, AuxiliaryExercise> map = {
        for (var e in _auxiliaryExercises) e.id: e,
      };
      for (var e in importedExercises) {
        map[e.id] = e;
      }
      _auxiliaryExercises = map.values.toList();
    }

    notifyListeners();
    await _repository.saveAuxiliaryExercises(_auxiliaryExercises);
    return importedExercises.length;
  }

  Future<void> restoreDefaultAuxiliaryExercises() async {
    _auxiliaryExercises = await _repository.restoreDefaultExercises();
    notifyListeners();
  }

  Future<void> resetAllData() async {
    _isLoading = true;
    notifyListeners();

    await _repository.resetAllData();
    _profile = const UserProfile();
    _workoutLogs = [];
    _auxiliaryExercises = AuxiliaryExercise.getDefaultExercises();
    _selectedTestFilter = null;
    _exerciseSearchQuery = '';
    _exerciseCategoryFilter = null;

    _isLoading = false;
    notifyListeners();
  }
}

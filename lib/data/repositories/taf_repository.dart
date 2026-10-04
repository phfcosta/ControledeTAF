import '../models/auxiliary_exercise.dart';
import '../models/user_profile.dart';
import '../models/workout_log.dart';
import '../services/storage_service.dart';

class TafRepository {
  TafRepository({StorageService? storageService})
      : _storage = storageService ?? StorageService();

  final StorageService _storage;

  Future<UserProfile> getProfile() => _storage.loadProfile();

  Future<void> updateProfile(UserProfile profile) => _storage.saveProfile(profile);

  Future<List<WorkoutLog>> getWorkoutLogs() => _storage.loadWorkoutLogs();

  Future<void> addWorkoutLog(WorkoutLog log) async {
    final current = await _storage.loadWorkoutLogs();
    final updated = [log, ...current];
    await _storage.saveWorkoutLogs(updated);
  }

  Future<void> updateWorkoutLog(WorkoutLog updatedLog) async {
    final current = await _storage.loadWorkoutLogs();
    final index = current.indexWhere((l) => l.id == updatedLog.id);
    if (index != -1) {
      current[index] = updatedLog;
      await _storage.saveWorkoutLogs(current);
    }
  }

  Future<void> deleteWorkoutLog(String id) async {
    final current = await _storage.loadWorkoutLogs();
    current.removeWhere((l) => l.id == id);
    await _storage.saveWorkoutLogs(current);
  }

  Future<List<AuxiliaryExercise>> getAuxiliaryExercises() =>
      _storage.loadAuxiliaryExercises();

  Future<void> addCustomExercise(AuxiliaryExercise exercise) async {
    final current = await _storage.loadAuxiliaryExercises();
    final updated = [...current, exercise];
    await _storage.saveAuxiliaryExercises(updated);
  }

  Future<void> deleteCustomExercise(String id) async {
    final current = await _storage.loadAuxiliaryExercises();
    current.removeWhere((e) => e.id == id && e.isCustom);
    await _storage.saveAuxiliaryExercises(current);
  }

  Future<void> resetAllData() => _storage.clearAllData();
}

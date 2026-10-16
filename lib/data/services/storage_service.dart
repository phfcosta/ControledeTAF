import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auxiliary_exercise.dart';
import '../models/user_profile.dart';
import '../models/workout_log.dart';
import '../models/taf_test_type.dart';

class StorageService {
  static const String _profileKey = 'km_taf_user_profile';
  static const String _workoutsKey = 'km_taf_workout_logs';
  static const String _exercisesKey = 'km_taf_auxiliary_exercises';
  static const String _initializedKey = 'km_taf_data_initialized';

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr == null) {
      return const UserProfile();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, jsonStr);
  }

  Future<List<WorkoutLog>> loadWorkoutLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_workoutsKey);

    if (jsonStr == null) {
      // First time initialization: load demo records to showcase charts
      final isInitialized = prefs.getBool(_initializedKey) ?? false;
      if (!isInitialized) {
        final demoLogs = _createDemoLogs();
        await saveWorkoutLogs(demoLogs);
        await prefs.setBool(_initializedKey, true);
        return demoLogs;
      }
      return [];
    }

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => WorkoutLog.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // descending by date
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWorkoutLogs(List<WorkoutLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = logs.map((log) => log.toJson()).toList();
    final jsonStr = jsonEncode(jsonList);
    await prefs.setString(_workoutsKey, jsonStr);
  }

  Future<List<AuxiliaryExercise>> loadAuxiliaryExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_exercisesKey);

    final defaultList = AuxiliaryExercise.getDefaultExercises();

    if (jsonStr == null) {
      await saveAuxiliaryExercises(defaultList);
      return defaultList;
    }

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => AuxiliaryExercise.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return defaultList;
    }
  }

  Future<List<AuxiliaryExercise>> resetDefaultAuxiliaryExercises() async {
    final defaultList = AuxiliaryExercise.getDefaultExercises();
    await saveAuxiliaryExercises(defaultList);
    return defaultList;
  }

  Future<void> saveAuxiliaryExercises(List<AuxiliaryExercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = exercises.map((e) => e.toJson()).toList();
    final jsonStr = jsonEncode(jsonList);
    await prefs.setString(_exercisesKey, jsonStr);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_workoutsKey);
    await prefs.remove(_exercisesKey);
    await prefs.remove(_initializedKey);
  }

  /// Initial sample logs showing evolution over the past 4 weeks
  List<WorkoutLog> _createDemoLogs() {
    final now = DateTime.now();
    return [
      // Corrida evolution
      WorkoutLog(
        id: 'demo_run_1',
        date: now.subtract(const Duration(days: 28)),
        testType: TafTestType.corrida,
        isOfficialTaf: true,
        value: 3.0,
        distanceKm: 3.0,
        timeInSeconds: 1140, // 19:00
        notes: 'Primeiro simulado de corrida. Ritmo forte no início, quebrei no km 2.',
        rpe: 9,
      ),
      WorkoutLog(
        id: 'demo_run_2',
        date: now.subtract(const Duration(days: 21)),
        testType: TafTestType.corrida,
        isOfficialTaf: true,
        value: 3.0,
        distanceKm: 3.0,
        timeInSeconds: 1080, // 18:00
        notes: 'Melhor controle da respiração. Ritmo mais constante.',
        rpe: 8,
      ),
      WorkoutLog(
        id: 'demo_run_3',
        date: now.subtract(const Duration(days: 14)),
        testType: TafTestType.corrida,
        isOfficialTaf: true,
        value: 3.0,
        distanceKm: 3.0,
        timeInSeconds: 1020, // 17:00 (Aprovado Faixa Verde!)
        notes: 'Meta da faixa verde alcançada! 17:00 cravados.',
        rpe: 8,
      ),
      WorkoutLog(
        id: 'demo_run_4',
        date: now.subtract(const Duration(days: 4)),
        testType: TafTestType.corrida,
        isOfficialTaf: true,
        value: 3.0,
        distanceKm: 3.0,
        timeInSeconds: 960, // 16:00
        notes: 'Excelente evolução com treinos de tiro e fartlek.',
        rpe: 7,
      ),

      // Barra Fixa evolution
      WorkoutLog(
        id: 'demo_pullup_1',
        date: now.subtract(const Duration(days: 25)),
        testType: TafTestType.barraFixa,
        isOfficialTaf: true,
        value: 3,
        notes: '3 repetições pronadas com queixo acima da barra.',
        rpe: 9,
      ),
      WorkoutLog(
        id: 'demo_pullup_2',
        date: now.subtract(const Duration(days: 18)),
        testType: TafTestType.barraFixa,
        isOfficialTaf: true,
        value: 5,
        notes: 'Atingi as 5 repetições exigidas para Faixa Verde!',
        rpe: 8,
      ),
      WorkoutLog(
        id: 'demo_pullup_3',
        date: now.subtract(const Duration(days: 7)),
        testType: TafTestType.barraFixa,
        isOfficialTaf: true,
        value: 7,
        notes: 'Treinos de barra negativa e elástico deram muito resultado.',
        rpe: 8,
      ),

      // Flexão de Braço
      WorkoutLog(
        id: 'demo_pushup_1',
        date: now.subtract(const Duration(days: 24)),
        testType: TafTestType.flexao,
        isOfficialTaf: true,
        value: 22,
        notes: 'Fadiga no tríceps após repetição 20.',
        rpe: 9,
      ),
      WorkoutLog(
        id: 'demo_pushup_2',
        date: now.subtract(const Duration(days: 12)),
        testType: TafTestType.flexao,
        isOfficialTaf: true,
        value: 32,
        notes: 'Superada a meta de 30 repetições da Faixa Verde.',
        rpe: 8,
      ),
      WorkoutLog(
        id: 'demo_pushup_3',
        date: now.subtract(const Duration(days: 2)),
        testType: TafTestType.flexao,
        isOfficialTaf: true,
        value: 40,
        notes: 'Rumo aos 60 da Faixa Azul.',
        rpe: 8,
      ),

      // Abdominal (2 min)
      WorkoutLog(
        id: 'demo_abs_1',
        date: now.subtract(const Duration(days: 20)),
        testType: TafTestType.abdominal,
        isOfficialTaf: true,
        value: 48,
        notes: 'Simulado com cronômetro de 2 minutos.',
        rpe: 9,
      ),
      WorkoutLog(
        id: 'demo_abs_2',
        date: now.subtract(const Duration(days: 5)),
        testType: TafTestType.abdominal,
        isOfficialTaf: true,
        value: 62,
        notes: '62 repetições completas em 2 min! Aprovado Verde.',
        rpe: 8,
      ),

      // Pesinhos
      WorkoutLog(
        id: 'demo_weights_1',
        date: now.subtract(const Duration(days: 10)),
        testType: TafTestType.pesinhos,
        isOfficialTaf: true,
        value: 3,
        notes: '3 sequências completas com halteres de 5 kg.',
        rpe: 7,
      ),

      // Barras Paralelas
      WorkoutLog(
        id: 'demo_dips_1',
        date: now.subtract(const Duration(days: 8)),
        testType: TafTestType.paralelas,
        isOfficialTaf: true,
        value: 8,
        notes: '8 repetições perfeitas com descida a 90 graus.',
        rpe: 8,
      ),
    ];
  }
}

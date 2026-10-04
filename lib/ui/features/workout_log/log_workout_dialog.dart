import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/auxiliary_exercise.dart';
import '../../../data/models/taf_test_type.dart';
import '../../../data/models/workout_log.dart';
import '../../core/theme.dart';
import '../view_models/taf_view_model.dart';

class LogWorkoutDialog extends StatefulWidget {
  const LogWorkoutDialog({
    super.key,
    this.initialTestType,
    this.initialAuxiliaryExercise,
  });

  final TafTestType? initialTestType;
  final AuxiliaryExercise? initialAuxiliaryExercise;

  static Future<void> show(
    BuildContext context, {
    TafTestType? initialTestType,
    AuxiliaryExercise? initialAuxiliaryExercise,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => LogWorkoutDialog(
        initialTestType: initialTestType,
        initialAuxiliaryExercise: initialAuxiliaryExercise,
      ),
    );
  }

  @override
  State<LogWorkoutDialog> createState() => _LogWorkoutDialogState();
}

class _LogWorkoutDialogState extends State<LogWorkoutDialog> {
  late TafTestType _selectedTest;
  bool _isOfficial = true;
  AuxiliaryExercise? _selectedAuxiliary;

  final DateTime _workoutDate = DateTime.now();

  // Running inputs
  double _distanceKm = 3.0;
  final _minutesController = TextEditingController(text: '16');
  final _secondsController = TextEditingController(text: '30');

  // Reps input
  int _reps = 10;
  final _repsController = TextEditingController(text: '10');

  // Rounds & RPE
  int _rounds = 1;
  int _rpe = 7;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAuxiliaryExercise != null) {
      _selectedAuxiliary = widget.initialAuxiliaryExercise;
      _selectedTest = widget.initialAuxiliaryExercise!.category;
      _isOfficial = false;
    } else {
      _selectedTest = widget.initialTestType ?? TafTestType.corrida;
      _isOfficial = true;
    }

    _applyDefaultsForTest(_selectedTest);
  }

  void _applyDefaultsForTest(TafTestType test) {
    if (test == TafTestType.corrida) {
      _minutesController.text = '16';
      _secondsController.text = '00';
    } else if (test == TafTestType.barraFixa) {
      _reps = 6;
      _repsController.text = '6';
    } else if (test == TafTestType.flexao) {
      _reps = 35;
      _repsController.text = '35';
    } else if (test == TafTestType.abdominal) {
      _reps = 65;
      _repsController.text = '65';
    } else if (test == TafTestType.pesinhos) {
      _reps = 4;
      _repsController.text = '4';
    } else if (test == TafTestType.paralelas) {
      _reps = 10;
      _repsController.text = '10';
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TafViewModel>();
    final relevantAuxiliaries = vm.auxiliaryExercises
        .where((e) => e.category == _selectedTest)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dialog Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registrar Marca de Treino',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Test Type Selector Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TafTestType.values.map((type) {
                  final isSelected = _selectedTest == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(type.icon, size: 16, color: isSelected ? Colors.white : AppTheme.lightBlue),
                          const SizedBox(width: 6),
                          Text(type.shortName),
                        ],
                      ),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: AppTheme.cardSurfaceElevated,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedTest = type;
                            _selectedAuxiliary = null;
                            _applyDefaultsForTest(type);
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle Official TAF vs Auxiliary
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isOfficial = true),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isOfficial ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Prova Oficial TAF',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isOfficial ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isOfficial = false;
                          if (relevantAuxiliaries.isNotEmpty && _selectedAuxiliary == null) {
                            _selectedAuxiliary = relevantAuxiliaries.first;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isOfficial ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Exercício Educativo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isOfficial ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Auxiliary dropdown if selected
            if (!_isOfficial) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<AuxiliaryExercise>(
                initialValue: _selectedAuxiliary ?? (relevantAuxiliaries.isNotEmpty ? relevantAuxiliaries.first : null),
                decoration: const InputDecoration(
                  labelText: 'Exercício Auxiliar',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                dropdownColor: AppTheme.cardSurfaceElevated,
                items: relevantAuxiliaries.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedAuxiliary = val);
                },
              ),
            ],

            const SizedBox(height: 16),

            // Specialized inputs: Running vs Reps
            if (_selectedTest == TafTestType.corrida) ...[
              const Text(
                'Distância e Tempo',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Preset chips for distance
              Row(
                children: [
                  _DistanceChip(
                    label: '1.8 km (Laranja)',
                    value: 1.8,
                    selected: _distanceKm == 1.8,
                    onSelected: () => setState(() => _distanceKm = 1.8),
                  ),
                  const SizedBox(width: 8),
                  _DistanceChip(
                    label: '3.0 km (Verde+)',
                    value: 3.0,
                    selected: _distanceKm == 3.0,
                    onSelected: () => setState(() => _distanceKm = 3.0),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Minutes & Seconds
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutos',
                        suffixText: 'min',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Segundos',
                        suffixText: 'seg',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPacePreview(),
            ] else ...[
              // Repetitions input with quick steppers
              const Text(
                'Repetições Concluídas',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () {
                      if (_reps > 0) {
                        setState(() {
                          _reps = (_reps - 1).clamp(0, 500);
                          _repsController.text = _reps.toString();
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.cardSurfaceElevated),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        suffixText: _selectedTest.unit,
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null) {
                          setState(() => _reps = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      setState(() {
                        _reps += 1;
                        _repsController.text = _reps.toString();
                      });
                    },
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.cardSurfaceElevated),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Quick adder chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AdderChip(amount: 5, onAdd: (a) => _adjustReps(a)),
                  const SizedBox(width: 8),
                  _AdderChip(amount: 10, onAdd: (a) => _adjustReps(a)),
                  const SizedBox(width: 8),
                  _AdderChip(amount: 25, onAdd: (a) => _adjustReps(a)),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Rounds (Séries) selector
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Séries / Rounds:',
                    style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1x')),
                    ButtonSegment(value: 2, label: Text('2x')),
                    ButtonSegment(value: 3, label: Text('3x (Preta)')),
                  ],
                  selected: {_rounds},
                  onSelectionChanged: (set) {
                    setState(() => _rounds = set.first);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Perceived exertion (RPE 1-10)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Percepção de Esforço (PSE / RPE):',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getRpeColor(_rpe).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getRpeColor(_rpe)),
                  ),
                  child: Text(
                    '$_rpe / 10 • ${_getRpeLabel(_rpe)}',
                    style: TextStyle(
                      color: _getRpeColor(_rpe),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _rpe.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: _getRpeColor(_rpe),
              onChanged: (val) => setState(() => _rpe = val.round()),
            ),

            const SizedBox(height: 10),

            // Notes input
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações do treino (opcional)',
                hintText: 'Ex: Foco na postura, cansaço no final, tempo úmido...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _saveWorkout(context, vm),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Salvar Registro de Treino'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _adjustReps(int amount) {
    setState(() {
      _reps = (_reps + amount).clamp(0, 500);
      _repsController.text = _reps.toString();
    });
  }

  Widget _buildPacePreview() {
    final min = int.tryParse(_minutesController.text) ?? 0;
    final sec = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (min * 60) + sec;
    if (totalSeconds <= 0 || _distanceKm <= 0) return const SizedBox.shrink();

    final pacePerKm = totalSeconds / _distanceKm;
    final paceMin = pacePerKm ~/ 60;
    final paceSec = (pacePerKm % 60).round();
    final paceStr = '$paceMin:${paceSec.toString().padLeft(2, '0')}/km';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ritmo médio estimado (Pace):', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Text(paceStr, style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getRpeColor(int rpe) {
    if (rpe <= 4) return AppTheme.accentGreen;
    if (rpe <= 7) return AppTheme.accentGold;
    return AppTheme.accentRed;
  }

  String _getRpeLabel(int rpe) {
    if (rpe <= 3) return 'Leve';
    if (rpe <= 6) return 'Moderado';
    if (rpe <= 8) return 'Forte';
    return 'Exaustivo';
  }

  Future<void> _saveWorkout(BuildContext context, TafViewModel vm) async {
    double value;
    int? timeInSeconds;
    double? distance;

    if (_selectedTest == TafTestType.corrida) {
      final min = int.tryParse(_minutesController.text) ?? 0;
      final sec = int.tryParse(_secondsController.text) ?? 0;
      timeInSeconds = (min * 60) + sec;
      if (timeInSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insira um tempo válido para a corrida.')),
        );
        return;
      }
      value = _distanceKm;
      distance = _distanceKm;
    } else {
      final parsed = int.tryParse(_repsController.text);
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insira um número de repetições válido.')),
        );
        return;
      }
      value = parsed.toDouble();
    }

    final newLog = WorkoutLog(
      id: const Uuid().v4(),
      date: _workoutDate,
      testType: _selectedTest,
      isOfficialTaf: _isOfficial,
      value: value,
      timeInSeconds: timeInSeconds,
      distanceKm: distance,
      auxiliaryExerciseId: _isOfficial ? null : _selectedAuxiliary?.id,
      auxiliaryExerciseName: _isOfficial ? null : _selectedAuxiliary?.name,
      notes: _notesController.text.trim(),
      rpe: _rpe,
      roundsCompleted: _rounds,
    );

    await vm.addWorkoutLog(newLog);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.cardSurfaceElevated,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Treino de ${_selectedTest.name} salvo com sucesso!',
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final double value;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: AppTheme.cardSurfaceElevated,
      onSelected: (_) => onSelected(),
    );
  }
}

class _AdderChip extends StatelessWidget {
  const _AdderChip({required this.amount, required this.onAdd});
  final int amount;
  final void Function(int) onAdd;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('+$amount'),
      backgroundColor: AppTheme.cardSurfaceElevated,
      side: const BorderSide(color: AppTheme.cardBorder),
      onPressed: () => onAdd(amount),
    );
  }
}

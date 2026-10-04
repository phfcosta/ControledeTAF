import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/taf_test_type.dart';
import '../../core/theme.dart';
import '../workout_log/log_workout_dialog.dart';

enum TimerMode {
  countdownAbdominal,
  countdownRun10,
  countdownRun14,
  countdownRun17,
  stopwatch,
}

class TafTimerScreen extends StatefulWidget {
  const TafTimerScreen({super.key});

  @override
  State<TafTimerScreen> createState() => _TafTimerScreenState();
}

class _TafTimerScreenState extends State<TafTimerScreen> {
  TimerMode _mode = TimerMode.countdownAbdominal;
  Timer? _timer;

  int _initialSeconds = 120; // Default 2 min abdominal
  int _currentSeconds = 120;
  bool _isRunning = false;
  bool _isFinished = false;

  final List<String> _laps = [];

  @override
  void initState() {
    super.initState();
    _applyMode(TimerMode.countdownAbdominal);
  }

  void _applyMode(TimerMode mode) {
    _stopTimer();
    setState(() {
      _mode = mode;
      _isFinished = false;
      _laps.clear();
      switch (mode) {
        case TimerMode.countdownAbdominal:
          _initialSeconds = 120; // 2 min
          _currentSeconds = 120;
          break;
        case TimerMode.countdownRun10:
          _initialSeconds = 600; // 10 min
          _currentSeconds = 600;
          break;
        case TimerMode.countdownRun14:
          _initialSeconds = 840; // 14 min
          _currentSeconds = 840;
          break;
        case TimerMode.countdownRun17:
          _initialSeconds = 1020; // 17 min
          _currentSeconds = 1020;
          break;
        case TimerMode.stopwatch:
          _initialSeconds = 0;
          _currentSeconds = 0;
          break;
      }
    });
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _isFinished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == TimerMode.stopwatch) {
        setState(() {
          _currentSeconds++;
        });
      } else {
        if (_currentSeconds > 0) {
          setState(() {
            _currentSeconds--;
          });
        } else {
          _stopTimer();
          setState(() {
            _isFinished = true;
          });
          _showFinishedAlert();
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _currentSeconds = _initialSeconds;
      _isFinished = false;
      _laps.clear();
    });
  }

  void _recordLap() {
    if (!_isRunning) return;
    setState(() {
      final formatted = _formatTime(_currentSeconds);
      _laps.insert(0, 'Volta ${_laps.length + 1}: $formatted');
    });
  }

  void _showFinishedAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: Row(
          children: const [
            Icon(Icons.alarm_on_rounded, color: AppTheme.accentGreen, size: 28),
            SizedBox(width: 10),
            Text('TEMPO ESGOTADO!'),
          ],
        ),
        content: Text(
          _mode == TimerMode.countdownAbdominal
              ? 'Fim dos 2 minutos do teste oficial de Abdominal!\nQuantas repetições completas você fez?'
              : 'Fim do tempo da prova de corrida! Deseja registrar a sua marca no TAF agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              LogWorkoutDialog.show(
                context,
                initialTestType: _mode == TimerMode.countdownAbdominal
                    ? TafTestType.abdominal
                    : TafTestType.corrida,
              );
            },
            child: const Text('Registrar Marca'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _mode == TimerMode.stopwatch
        ? 1.0
        : (_initialSeconds > 0 ? (_currentSeconds / _initialSeconds) : 0.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronômetro Tático TAF'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Presets chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _PresetButton(
                      label: 'Abdominal (2 min)',
                      selected: _mode == TimerMode.countdownAbdominal,
                      onTap: () => _applyMode(TimerMode.countdownAbdominal),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: 'Corrida Laranja (10 min)',
                      selected: _mode == TimerMode.countdownRun10,
                      onTap: () => _applyMode(TimerMode.countdownRun10),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: 'Corrida Verde (17 min)',
                      selected: _mode == TimerMode.countdownRun17,
                      onTap: () => _applyMode(TimerMode.countdownRun17),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: 'Corrida Azul/Marrom (14 min)',
                      selected: _mode == TimerMode.countdownRun14,
                      onTap: () => _applyMode(TimerMode.countdownRun14),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: 'Cronômetro Livre',
                      selected: _mode == TimerMode.stopwatch,
                      onTap: () => _applyMode(TimerMode.stopwatch),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Large Circular Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 10,
                      backgroundColor: AppTheme.cardBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isFinished
                            ? AppTheme.accentRed
                            : _isRunning
                                ? AppTheme.accentGreen
                                : AppTheme.primaryBlue,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _mode == TimerMode.stopwatch
                            ? 'CRONÔMETRO'
                            : 'CONTAGEM REGRESSIVA',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(_currentSeconds),
                        style: TextStyle(
                          color: _isFinished
                              ? AppTheme.accentRed
                              : AppTheme.textPrimary,
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_isFinished)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TEMPO ESGOTADO!',
                            style: TextStyle(
                              color: AppTheme.accentRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Text(
                          _isRunning ? 'PROVA EM ANDAMENTO' : 'PAUSADO',
                          style: TextStyle(
                            color: _isRunning ? AppTheme.accentGreen : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filled(
                    onPressed: _resetTimer,
                    iconSize: 28,
                    icon: const Icon(Icons.refresh_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.cardSurfaceElevated,
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Play / Pause Button
                  GestureDetector(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRunning ? AppTheme.accentOrange : AppTheme.primaryBlue,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRunning ? AppTheme.accentOrange : AppTheme.primaryBlue).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Lap / Shortcut Button
                  IconButton.filled(
                    onPressed: _mode == TimerMode.stopwatch
                        ? _recordLap
                        : () => LogWorkoutDialog.show(
                              context,
                              initialTestType: _mode == TimerMode.countdownAbdominal
                                  ? TafTestType.abdominal
                                  : TafTestType.corrida,
                            ),
                    iconSize: 28,
                    icon: Icon(_mode == TimerMode.stopwatch ? Icons.flag_rounded : Icons.edit_note_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.cardSurfaceElevated,
                      foregroundColor: AppTheme.lightBlue,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Quick action: Register Workout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => LogWorkoutDialog.show(
                    context,
                    initialTestType: _mode == TimerMode.countdownAbdominal
                        ? TafTestType.abdominal
                        : TafTestType.corrida,
                  ),
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Registrar Marca Deste Teste'),
                ),
              ),

              // Laps list if stopwatch
              if (_laps.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Parciais / Voltas Gravadas',
                    style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ..._laps.map(
                  (lap) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lap, style: const TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: AppTheme.cardSurfaceElevated,
      onSelected: (_) => onTap(),
    );
  }
}

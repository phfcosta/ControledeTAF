import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/taf_requirement.dart';
import '../../../data/models/taf_test_type.dart';
import '../../../data/models/workout_log.dart';
import '../../core/theme.dart';
import '../view_models/taf_view_model.dart';
import '../workout_log/log_workout_dialog.dart';

class ProgressChartsScreen extends StatefulWidget {
  const ProgressChartsScreen({super.key, this.initialTestType});

  final TafTestType? initialTestType;

  @override
  State<ProgressChartsScreen> createState() => _ProgressChartsScreenState();
}

class _ProgressChartsScreenState extends State<ProgressChartsScreen> {
  late TafTestType _selectedTest;

  @override
  void initState() {
    super.initState();
    _selectedTest = widget.initialTestType ?? TafTestType.corrida;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TafViewModel>();
    final logs = vm.getLogsForTest(_selectedTest);
    final targetBelt = vm.profile.targetBelt;
    final requirements = TafRequirement.getRequirementsForBelt(targetBelt);
    final currentReq = requirements.where((r) => r.testType == _selectedTest).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolução e Gráficos'),
        actions: [
          IconButton(
            onPressed: () => LogWorkoutDialog.show(context, initialTestType: _selectedTest),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Registrar Treino',
          ),
        ],
      ),
      body: Column(
        children: [
          // Test Type Horizontal Pills Selector
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: TafTestType.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = TafTestType.values[index];
                final isSelected = type == _selectedTest;

                return ChoiceChip(
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
                    if (val) setState(() => _selectedTest = type);
                  },
                );
              },
            ),
          ),

          // Main Chart and History Scroll Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stat Header Cards
                _buildStatCards(logs, currentReq),

                const SizedBox(height: 20),

                // Chart Container
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Histórico de Desempenho (${_selectedTest.name})',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentReq != null)
                            Row(
                              children: [
                                Container(width: 12, height: 3, color: AppTheme.accentGold),
                                const SizedBox(width: 4),
                                const Text(
                                  'Meta',
                                  style: TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220,
                        child: logs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum dado registrado para este teste.\nAdicione um treino para visualizar o gráfico.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              )
                            : _buildChart(logs, currentReq),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _selectedTest == TafTestType.corrida
                              ? '* Gráfico em minutos (quanto menor o tempo, melhor)'
                              : '* Gráfico em repetições realizadas',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // History Table / List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Histórico de Sessões (${logs.length})',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => LogWorkoutDialog.show(context, initialTestType: _selectedTest),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Novo'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Sem histórico recente.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  ...logs.reversed.map((log) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          child: Icon(log.testType.icon, color: AppTheme.lightBlue, size: 18),
                        ),
                        title: Row(
                          children: [
                            Text(
                              log.formattedPerformance,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (!log.isOfficialTaf) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Educativo',
                                  style: TextStyle(color: AppTheme.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${log.formattedDate} • PSE ${log.rpe}/10',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                            if (log.notes.isNotEmpty)
                              Text(
                                log.notes,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.textMuted, size: 20),
                          onPressed: () => _confirmDeleteLog(context, vm, log),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(List<WorkoutLog> logs, TafRequirement? req) {
    String bestText = '--';
    String targetText = req != null ? req.targetDisplay : 'Sem exigência';
    bool isApproved = false;

    if (logs.isNotEmpty) {
      if (_selectedTest == TafTestType.corrida) {
        final withTime = logs.where((l) => l.timeInSeconds != null).toList();
        if (withTime.isNotEmpty) {
          withTime.sort((a, b) => a.timeInSeconds!.compareTo(b.timeInSeconds!));
          bestText = withTime.first.formattedPerformance;
          if (req != null && req.timeLimitSeconds != null) {
            isApproved = withTime.first.timeInSeconds! <= req.timeLimitSeconds!;
          }
        }
      } else {
        final sorted = List<WorkoutLog>.from(logs)..sort((a, b) => b.value.compareTo(a.value));
        bestText = sorted.first.formattedPerformance;
        if (req != null) {
          isApproved = sorted.first.value >= req.targetValue;
        }
      }
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'MELHOR MARCA',
            value: bestText,
            color: isApproved ? AppTheme.accentGreen : AppTheme.primaryBlue,
            icon: Icons.emoji_events_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'META DA FAIXA',
            value: targetText,
            color: AppTheme.accentGold,
            icon: Icons.flag_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<WorkoutLog> logs, TafRequirement? req) {
    final spots = <FlSpot>[];

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      double yValue;
      if (_selectedTest == TafTestType.corrida) {
        // Minutes (e.g. 16.5 for 16:30)
        final sec = log.timeInSeconds ?? (log.value * 60).toInt();
        yValue = sec / 60.0;
      } else {
        yValue = log.value;
      }

      spots.add(FlSpot(i.toDouble(), yValue));
      if (yValue < minY) minY = yValue;
      if (yValue > maxY) maxY = yValue;
    }

    // Add target line if available
    double? targetY;
    if (req != null) {
      if (_selectedTest == TafTestType.corrida && req.timeLimitSeconds != null) {
        targetY = req.timeLimitSeconds! / 60.0;
      } else {
        targetY = req.targetValue;
      }
      if (targetY < minY) minY = targetY;
      if (targetY > maxY) maxY = targetY;
    }

    // Pad Y axis nicely
    minY = (minY - 1).clamp(0, double.infinity);
    maxY = maxY + 2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (logs.length - 1).toDouble().clamp(1.0, 100.0),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.cardBorder.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < logs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('dd/MM').format(logs[index].date),
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Evolution Line
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppTheme.primaryBlue,
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppTheme.lightBlue,
                  strokeWidth: 2,
                  strokeColor: AppTheme.darkBackground,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.25),
                  AppTheme.primaryBlue.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: targetY != null
              ? [
                  HorizontalLine(
                    y: targetY,
                    color: AppTheme.accentGold,
                    strokeWidth: 2,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 6, bottom: 2),
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (_) => 'Meta',
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, TafViewModel vm, WorkoutLog log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Excluir Registro?'),
        content: Text('Deseja excluir o treino do dia ${log.formattedDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () {
              vm.deleteWorkoutLog(log.id);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title, value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

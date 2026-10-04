import 'package:flutter/material.dart';
import '../../domain/taf_evaluator.dart';
import '../core/theme.dart';

class TafStatusCard extends StatelessWidget {
  const TafStatusCard({
    super.key,
    required this.status,
    required this.onTapLog,
    required this.onTapChart,
  });

  final TafTestStatus status;
  final VoidCallback onTapLog;
  final VoidCallback onTapChart;

  @override
  Widget build(BuildContext context) {
    final test = status.testType;
    final req = status.requirement;
    final isApproved = status.isApproved && req != null;
    final progress = (status.progressPercentage / 100).clamp(0.0, 1.0);

    final statusColor = isApproved
        ? AppTheme.accentGreen
        : status.bestLog != null
            ? AppTheme.primaryBlue
            : AppTheme.textMuted;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTapChart,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Name and Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Icon(test.icon, color: AppTheme.lightBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          req != null ? 'Meta: ${req.targetDisplay}' : 'Sem exigência para a faixa',
                          style: TextStyle(
                            color: req != null ? AppTheme.accentGold : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge Aprovado / Em andamento
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isApproved
                              ? Icons.check_circle_rounded
                              : status.bestLog != null
                                  ? Icons.timelapse_rounded
                                  : Icons.hourglass_empty_rounded,
                          color: statusColor,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isApproved
                              ? 'APROVADO'
                              : status.bestLog != null
                                  ? '${status.progressPercentage.toStringAsFixed(0)}%'
                                  : 'PENDENTE',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress Bar
              if (req != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.cardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Best mark vs Status message
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MELHOR MARCA',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status.bestLog != null
                            ? status.bestLog!.formattedPerformance
                            : '--',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        status.statusMessage,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isApproved ? AppTheme.accentGreen : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppTheme.cardBorder, height: 1),
              const SizedBox(height: 8),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTapChart,
                    icon: const Icon(Icons.show_chart_rounded, size: 16),
                    label: const Text('Evolução'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.lightBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: onTapLog,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Registrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../core/theme.dart';
import 'belt_badge.dart';

class OverallReadinessCard extends StatelessWidget {
  const OverallReadinessCard({
    super.key,
    required this.profile,
    required this.overallProgress,
    required this.approvedCount,
    required this.totalRequired,
    required this.onTapChangeBelt,
  });

  final UserProfile profile;
  final double overallProgress;
  final int approvedCount;
  final int totalRequired;
  final VoidCallback onTapChangeBelt;

  @override
  Widget build(BuildContext context) {
    final progressClamped = (overallProgress / 100).clamp(0.0, 1.0);
    final isFullyApproved = totalRequired > 0 && approvedCount >= totalRequired;

    final statusColor = isFullyApproved
        ? AppTheme.accentGreen
        : overallProgress >= 70
            ? AppTheme.accentGold
            : AppTheme.primaryBlue;

    final statusText = isFullyApproved
        ? 'APTO PARA O TAF'
        : overallProgress >= 70
            ? 'RETA FINAL DE PREPARAÇÃO'
            : 'EM EVOLUÇÃO CONTÍNUA';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardSurfaceElevated,
            AppTheme.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Belt transition row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FAIXA ATUAL',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BeltBadge(belt: profile.currentBelt, size: BeltBadgeSize.medium),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              InkWell(
                onTap: onTapChangeBelt,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'FAIXA ALVO',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.edit_outlined, size: 12, color: AppTheme.accentGold),
                      ],
                    ),
                    const SizedBox(height: 4),
                    BeltBadge(belt: profile.targetBelt, size: BeltBadgeSize.medium),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppTheme.cardBorder, height: 1),
          const SizedBox(height: 20),

          // Gauge and readiness stats
          Row(
            children: [
              // Radial Progress Indicator
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressClamped,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.cardBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${overallProgress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'PREPARO',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Status and breakdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          isFullyApproved
                              ? Icons.check_circle_rounded
                              : Icons.checklist_rounded,
                          color: isFullyApproved ? AppTheme.accentGreen : AppTheme.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            totalRequired > 0
                                ? '$approvedCount de $totalRequired provas aprovadas'
                                : 'Sem requisitos físicos para a faixa',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (profile.daysUntilExam != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.accentGold,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              profile.daysUntilExam! >= 0
                                  ? 'Faltam ${profile.daysUntilExam} dias para o exame'
                                  : 'Data do exame expirada',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

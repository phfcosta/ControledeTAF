import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/belt_rank.dart';
import '../../../data/models/taf_requirement.dart';
import '../../../data/models/taf_test_type.dart';
import '../../core/theme.dart';
import '../../widgets/belt_badge.dart';
import '../view_models/taf_view_model.dart';
import '../workout_log/log_workout_dialog.dart';

class TargetBeltScreen extends StatefulWidget {
  const TargetBeltScreen({
    super.key,
    this.initialTestFilter,
    required this.onNavigateToCatalog,
  });

  final TafTestType? initialTestFilter;
  final void Function(TafTestType category) onNavigateToCatalog;

  @override
  State<TargetBeltScreen> createState() => _TargetBeltScreenState();
}

class _TargetBeltScreenState extends State<TargetBeltScreen> {
  late BeltRank _inspectedBelt;

  @override
  void initState() {
    super.initState();
    final vm = context.read<TafViewModel>();
    _inspectedBelt = vm.profile.targetBelt;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TafViewModel>();
    final isCurrentTarget = vm.profile.targetBelt == _inspectedBelt;
    final requirements = TafRequirement.getRequirementsForBelt(_inspectedBelt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas e Exigências do TAF'),
        actions: [
          if (!isCurrentTarget && _inspectedBelt.hasPhysicalRequirements)
            TextButton.icon(
              onPressed: () {
                vm.setTargetBelt(_inspectedBelt);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_inspectedBelt.name} definida como sua faixa alvo!')),
                );
              },
              icon: const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 18),
              label: const Text('Tornar Alvo', style: TextStyle(color: AppTheme.accentGold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Belt Rank Horizontal Carousel Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: BeltRank.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final belt = BeltRank.values[index];
                final isSelected = belt == _inspectedBelt;
                final isUserTarget = belt == vm.profile.targetBelt;

                return GestureDetector(
                  onTap: () => setState(() => _inspectedBelt = belt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.2) : AppTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : isUserTarget
                                ? AppTheme.accentGold
                                : AppTheme.cardBorder,
                        width: isSelected || isUserTarget ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 6, backgroundColor: belt.color),
                        const SizedBox(width: 6),
                        Text(
                          belt.shortName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        if (isUserTarget) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: AppTheme.accentGold, size: 12),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Requirements Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Belt Description Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      BeltBadge(belt: _inspectedBelt, size: BeltBadgeSize.large),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _inspectedBelt.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _inspectedBelt.description,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Special Rule Notice for Faixa Preta
                if (_inspectedBelt == BeltRank.preta) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.accentOrange, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'REGRA DAS 3 SÉRIES: No exame de Faixa Preta da FSAKM, todas as provas de força e resistência devem ser executadas em 3 rounds completos!',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // If no physical requirements (White & Yellow)
                if (requirements.isEmpty) ...[
                  const SizedBox(height: 40),
                  const Center(
                    child: Icon(Icons.verified_outlined, size: 60, color: AppTheme.accentGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_inspectedBelt.name} não exige Teste de Aptidão Física (TAF).',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O foco nesta graduação é no aprendizado técnico de defesas, golpes e postura de combate da FSAKM.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checklist Oficial (${requirements.length} Provas)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (isCurrentTarget)
                        Text(
                          '${vm.approvedCount} de ${vm.totalRequiredCount} atingidas',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Requirements list
                  ...requirements.map((req) {
                    final status = vm.testStatuses.firstWhere(
                      (s) => s.testType == req.testType,
                      orElse: () => vm.testStatuses.first,
                    );

                    final hasLogs = status.bestLog != null;
                    final isAchieved = req.isAchieved(
                      value: status.bestLog?.value ?? 0,
                      seconds: status.bestLog?.timeInSeconds,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Checkbox icon
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isAchieved
                                        ? AppTheme.accentGreen.withValues(alpha: 0.2)
                                        : AppTheme.cardSurfaceElevated,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isAchieved
                                          ? AppTheme.accentGreen
                                          : AppTheme.cardBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    isAchieved ? Icons.check : Icons.circle_outlined,
                                    color: isAchieved ? AppTheme.accentGreen : AppTheme.textMuted,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.testType.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        req.targetDisplay,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => LogWorkoutDialog.show(
                                    context,
                                    initialTestType: req.testType,
                                  ),
                                  tooltip: 'Registrar Treino',
                                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.lightBlue),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            const Divider(color: AppTheme.cardBorder, height: 1),
                            const SizedBox(height: 8),

                            // Student's best mark vs target
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hasLogs
                                      ? 'Sua melhor marca: ${status.bestLog!.formattedPerformance}'
                                      : 'Nenhum treino registrado ainda',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasLogs ? AppTheme.textPrimary : AppTheme.textMuted,
                                    fontWeight: hasLogs ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  isAchieved ? 'APROVADO' : 'EM PROGRESSO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isAchieved ? AppTheme.accentGreen : AppTheme.accentOrange,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Execution criteria and educational exercises link
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    req.testType.executionStandard,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () => widget.onNavigateToCatalog(req.testType),
                                  child: const Text('Educativos >', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

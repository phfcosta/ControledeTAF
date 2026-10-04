import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/belt_rank.dart';
import '../../../data/models/taf_test_type.dart';
import '../../core/theme.dart';
import '../../widgets/overall_readiness_card.dart';
import '../../widgets/taf_status_card.dart';
import '../view_models/taf_view_model.dart';
import '../workout_log/log_workout_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onNavigateToTab,
  });

  final void Function(int index, {TafTestType? initialTestFilter}) onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return Consumer<TafViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = vm.profile;
        final statuses = vm.testStatuses;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Tactical Header
              SliverAppBar(
                expandedHeight: 130,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.darkBackground,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), AppTheme.darkBackground],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.accentGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'FSAKM • KRAV MAGA',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (profile.dojo.isNotEmpty)
                                    Text(
                                      profile.dojo,
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => onNavigateToTab(5), // Profile screen
                              icon: const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.cardSurfaceElevated,
                                child: Icon(Icons.person_rounded, color: AppTheme.lightBlue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Overall Readiness Card
                      OverallReadinessCard(
                        profile: profile,
                        overallProgress: vm.overallProgress,
                        approvedCount: vm.approvedCount,
                        totalRequired: vm.totalRequiredCount,
                        onTapChangeBelt: () => _showBeltSelectionSheet(context, vm),
                      ),

                      const SizedBox(height: 20),

                      // Quick Action Grid
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.add_circle_outline_rounded,
                              label: 'Registrar Treino',
                              color: AppTheme.primaryBlue,
                              onTap: () => LogWorkoutDialog.show(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.timer_outlined,
                              label: 'Cronômetro TAF',
                              color: AppTheme.accentOrange,
                              onTap: () => onNavigateToTab(3), // Timer tab
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.menu_book_rounded,
                              label: 'Educativos',
                              color: AppTheme.accentGold,
                              onTap: () => onNavigateToTab(2), // Catalog tab
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section Title: Provas Oficiais
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Provas Oficiais do TAF',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Exigências para ${profile.targetBelt.name}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => onNavigateToTab(1), // Target belt tab
                            child: const Text('Ver Metas'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Cards for each test
                      ...statuses.map((status) {
                        return TafStatusCard(
                          status: status,
                          onTapLog: () => LogWorkoutDialog.show(
                            context,
                            initialTestType: status.testType,
                          ),
                          onTapChart: () {
                            vm.setTestFilter(status.testType);
                            onNavigateToTab(1, initialTestFilter: status.testType);
                          },
                        );
                      }),

                      const SizedBox(height: 16),

                      // Recent Workouts Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Últimos Treinos',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => onNavigateToTab(1),
                            child: const Text('Ver Histórico'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (vm.workoutLogs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'Nenhum treino registrado ainda.\nClique em "Registrar Treino" para começar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          ),
                        )
                      else
                        ...vm.workoutLogs.take(4).map((log) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                child: Icon(log.testType.icon, color: AppTheme.lightBlue, size: 20),
                              ),
                              title: Text(
                                log.isOfficialTaf
                                    ? log.testType.name
                                    : (log.auxiliaryExerciseName ?? log.testType.name),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${log.formattedDate} • PSE ${log.rpe}/10',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              trailing: Text(
                                log.formattedPerformance,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBeltSelectionSheet(BuildContext context, TafViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const Text(
                  'Selecione a Faixa Alvo do TAF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'As metas e avaliações do aplicativo se adaptarão às exigências da faixa escolhida.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: BeltRank.values.map((belt) {
                      final isSelected = vm.profile.targetBelt == belt;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                              : AppTheme.cardSurfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: belt.color,
                            radius: 12,
                          ),
                          title: Text(
                            belt.name,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            belt.description,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue)
                              : null,
                          onTap: () {
                            vm.setTargetBelt(belt);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

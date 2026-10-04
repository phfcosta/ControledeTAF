import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/auxiliary_exercise.dart';
import '../../../data/models/taf_test_type.dart';
import '../../core/theme.dart';
import '../../core/url_helper.dart';
import '../view_models/taf_view_model.dart';
import '../workout_log/log_workout_dialog.dart';

class AuxiliaryCatalogScreen extends StatefulWidget {
  const AuxiliaryCatalogScreen({super.key, this.initialCategory});

  final TafTestType? initialCategory;

  @override
  State<AuxiliaryCatalogScreen> createState() => _AuxiliaryCatalogScreenState();
}

class _AuxiliaryCatalogScreenState extends State<AuxiliaryCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TafViewModel>().setExerciseCategory(widget.initialCategory);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TafViewModel>();
    final exercises = vm.filteredExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Exercícios Auxiliares'),
        actions: [
          IconButton(
            onPressed: () => _showAddCustomExerciseDialog(context, vm),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Cadastrar Exercício',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar exercício educativo, músculo ou dica...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          vm.setExerciseSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => vm.setExerciseSearch(val),
            ),
          ),

          // Category Chips Bar
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('Todas as Provas'),
                  selected: vm.exerciseCategoryFilter == null,
                  selectedColor: AppTheme.primaryBlue,
                  backgroundColor: AppTheme.cardSurfaceElevated,
                  onSelected: (_) => vm.setExerciseCategory(null),
                ),
                const SizedBox(width: 8),
                ...TafTestType.values.map((cat) {
                  final isSelected = vm.exerciseCategoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 14, color: isSelected ? Colors.white : AppTheme.lightBlue),
                          const SizedBox(width: 6),
                          Text(cat.shortName),
                        ],
                      ),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: AppTheme.cardSurfaceElevated,
                      onSelected: (val) => vm.setExerciseCategory(val ? cat : null),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Exercise List
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 54, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum exercício encontrado com esses filtros.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddCustomExerciseDialog(context, vm),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Este Exercício'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        onTapDetails: () => _showExerciseDetailsSheet(context, exercise),
                        onTapVideo: () => UrlHelper.openUrl(context, exercise.videoUrl),
                        onTapLog: () => LogWorkoutDialog.show(
                          context,
                          initialTestType: exercise.category,
                          initialAuxiliaryExercise: exercise,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showAddCustomExerciseDialog(context, vm),
        icon: const Icon(Icons.add),
        label: const Text('Novo Exercício'),
      ),
    );
  }

  void _showExerciseDetailsSheet(BuildContext context, AuxiliaryExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
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

                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(exercise.category.icon, size: 14, color: AppTheme.lightBlue),
                        const SizedBox(width: 6),
                        Text(
                          'PREPARAÇÃO PARA: ${exercise.category.name.toUpperCase()}',
                          style: const TextStyle(
                            color: AppTheme.lightBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // YouTube Action Button
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0000), // YouTube Red
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => UrlHelper.openUrl(context, exercise.videoUrl),
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                      label: const Text('Assistir Vídeo Explicativo no YouTube'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Execution description
                  const Text(
                    'Instruções de Execução',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      exercise.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  if (exercise.tips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Dicas do Instrutor / Biomecânica',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentGold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.tips,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (exercise.musclesTargeted.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Músculos e Grupos Trabalhados',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: exercise.musclesTargeted.map((m) {
                        return Chip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          backgroundColor: AppTheme.cardSurfaceElevated,
                          side: const BorderSide(color: AppTheme.cardBorder),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Log workout button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        LogWorkoutDialog.show(
                          context,
                          initialTestType: exercise.category,
                          initialAuxiliaryExercise: exercise,
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Registrar Treino Deste Exercício'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomExerciseDialog(BuildContext context, TafViewModel vm) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final tipsCtrl = TextEditingController();
    final musclesCtrl = TextEditingController();
    TafTestType category = vm.exerciseCategoryFilter ?? TafTestType.corrida;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardSurface,
            title: const Text('Novo Exercício Educativo'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categoria do TAF auxiliada:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<TafTestType>(
                    initialValue: category,
                    dropdownColor: AppTheme.cardSurfaceElevated,
                    items: TafTestType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome do Exercício'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descrição detalhada da execução'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Link do YouTube (URL)',
                      hintText: 'https://youtube.com/...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tipsCtrl,
                    decoration: const InputDecoration(labelText: 'Dica de postura / Biomecânica (opcional)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: musclesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Músculos trabalhados (separados por vírgula)',
                      hintText: 'Dorsais, Bíceps, Core...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final desc = descCtrl.text.trim();
                  if (name.isEmpty || desc.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preencha pelo menos o nome e a descrição.')),
                    );
                    return;
                  }
                  final muscles = musclesCtrl.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final newExercise = AuxiliaryExercise(
                    id: const Uuid().v4(),
                    name: name,
                    category: category,
                    description: desc,
                    videoUrl: urlCtrl.text.trim().isNotEmpty
                        ? urlCtrl.text.trim()
                        : 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(name)}',
                    tips: tipsCtrl.text.trim(),
                    musclesTargeted: muscles,
                    isCustom: true,
                  );

                  vm.addCustomAuxiliaryExercise(newExercise);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exercício "$name" adicionado com sucesso!')),
                  );
                },
                child: const Text('Cadastrar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onTapDetails,
    required this.onTapVideo,
    required this.onTapLog,
  });

  final AuxiliaryExercise exercise;
  final VoidCallback onTapDetails;
  final VoidCallback onTapVideo;
  final VoidCallback onTapLog;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTapDetails,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category chip & Custom badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(exercise.category.icon, size: 12, color: AppTheme.lightBlue),
                        const SizedBox(width: 4),
                        Text(
                          exercise.category.name,
                          style: const TextStyle(
                            color: AppTheme.lightBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (exercise.isCustom)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PERSONALIZADO',
                        style: TextStyle(color: AppTheme.accentGold, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                exercise.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),

              if (exercise.musclesTargeted.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  children: exercise.musclesTargeted.take(3).map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(m, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(color: AppTheme.cardBorder, height: 1),
              const SizedBox(height: 8),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF5252),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onPressed: onTapVideo,
                    icon: const Icon(Icons.play_circle_filled, size: 18),
                    label: const Text('Vídeo YouTube', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    onPressed: onTapLog,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Treinar'),
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

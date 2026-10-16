import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        context.read<TafViewModel>().setExerciseCategory(
          widget.initialCategory,
        );
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
        title: const Text('Catalogo de ExercÃ­cios Auxiliares'),
        actions: [
          IconButton(
            onPressed: () => _showImportDialog(context, vm),
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Importar Exercícios (JSON)',
          ),
          IconButton(
            onPressed: () => _showExportSheet(context, vm),
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Exportar Exercícios (JSON)',
          ),
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
                        icon: const Icon(
                          Icons.clear,
                          color: AppTheme.textMuted,
                        ),
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
                          Icon(
                            cat.icon,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.lightBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(cat.shortName),
                        ],
                      ),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: AppTheme.cardSurfaceElevated,
                      onSelected: (val) =>
                          vm.setExerciseCategory(val ? cat : null),
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
                          const Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum exercício encontrado com esses filtros.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showAddCustomExerciseDialog(context, vm),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Este Exercício'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        onTapDetails: () =>
                            _showExerciseDetailsSheet(context, exercise, vm),
                        onTapVideo: () =>
                            UrlHelper.openUrl(context, exercise.videoUrl),
                        onTapLog: () => LogWorkoutDialog.show(
                          context,
                          initialTestType: exercise.category,
                          initialAuxiliaryExercise: exercise,
                        ),
                        onTapEdit: () =>
                            _showEditExerciseDialog(context, vm, exercise),
                        onTapDelete: () =>
                            _confirmDeleteExercise(context, vm, exercise),
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
        label: const Text('Novo ExercÃ­cio'),
      ),
    );
  }

  // â”€â”€â”€ DETAILS SHEET â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showExerciseDetailsSheet(
    BuildContext context,
    AuxiliaryExercise exercise,
    TafViewModel vm,
  ) {
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

                  // Category tag + action icons
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              exercise.category.icon,
                              size: 14,
                              color: AppTheme.lightBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PREPARAÃ‡ÃƒO PARA: ${exercise.category.name.toUpperCase()}',
                              style: const TextStyle(
                                color: AppTheme.lightBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.lightBlue,
                          size: 20,
                        ),
                        tooltip: 'Editar exercÃ­cio',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditExerciseDialog(context, vm, exercise);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.accentRed,
                          size: 20,
                        ),
                        tooltip: 'Apagar exercÃ­cio',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDeleteExercise(context, vm, exercise);
                        },
                      ),
                    ],
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
                        backgroundColor: const Color(0xFFCC0000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          UrlHelper.openUrl(context, exercise.videoUrl),
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 22,
                      ),
                      label: const Text(
                        'Assistir VÃ­deo Explicativo no YouTube',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Execution description
                  const Text(
                    'InstruÃ§Ãµes de ExecuÃ§Ã£o',
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
                      'Dicas do Instrutor / BiomecÃ¢nica',
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
                        border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppTheme.accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.tips,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (exercise.musclesTargeted.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'MÃºsculos e Grupos Trabalhados',
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
                      label: const Text('Registrar Treino Deste ExercÃ­cio'),
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

  // â”€â”€â”€ ADD DIALOG â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showAddCustomExerciseDialog(BuildContext context, TafViewModel vm) {
    _showExerciseFormDialog(context, vm, existing: null);
  }

  // â”€â”€â”€ EDIT DIALOG â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showEditExerciseDialog(
    BuildContext context,
    TafViewModel vm,
    AuxiliaryExercise exercise,
  ) {
    _showExerciseFormDialog(context, vm, existing: exercise);
  }

  // â”€â”€â”€ SHARED FORM DIALOG (add & edit) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showExerciseFormDialog(
    BuildContext context,
    TafViewModel vm, {
    required AuxiliaryExercise? existing,
  }) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final urlCtrl = TextEditingController(text: existing?.videoUrl ?? '');
    final tipsCtrl = TextEditingController(text: existing?.tips ?? '');
    final musclesCtrl = TextEditingController(
      text: existing?.musclesTargeted.join(', ') ?? '',
    );
    TafTestType category =
        existing?.category ?? vm.exerciseCategoryFilter ?? TafTestType.corrida;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardSurface,
            title: Text(
              isEditing ? 'Editar ExercÃ­cio' : 'Novo ExercÃ­cio Educativo',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categoria do TAF auxiliada:',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
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
                    decoration: const InputDecoration(
                      labelText: 'Nome do ExercÃ­cio',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'DescriÃ§Ã£o detalhada da execuÃ§Ã£o',
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Dica de postura / Biomecânica (opcional)',
                    ),
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
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final desc = descCtrl.text.trim();
                  if (name.isEmpty || desc.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Preencha pelo menos o nome e a descrição.',
                        ),
                      ),
                    );
                    return;
                  }
                  final muscles = musclesCtrl.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  if (isEditing) {
                    final updated = existing.copyWith(
                      name: name,
                      category: category,
                      description: desc,
                      videoUrl: urlCtrl.text.trim().isNotEmpty
                          ? urlCtrl.text.trim()
                          : existing.videoUrl,
                      tips: tipsCtrl.text.trim(),
                      musclesTargeted: muscles,
                    );
                    vm.updateAuxiliaryExercise(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ExercÃ­cio "$name" atualizado!')),
                    );
                  } else {
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
                      SnackBar(
                        content: Text(
                          'Exercício "$name" adicionado com sucesso!',
                        ),
                      ),
                    );
                  }
                },
                child: Text(isEditing ? 'Salvar' : 'Cadastrar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // â”€â”€â”€ DELETE CONFIRM â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _confirmDeleteExercise(
    BuildContext context,
    TafViewModel vm,
    AuxiliaryExercise exercise,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Apagar ExercÃ­cio'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Tem certeza que deseja apagar '),
              TextSpan(
                text: '"${exercise.name}"',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '?\n\nEsta ação não pode ser desfeita.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final name = exercise.name;
              vm.deleteAuxiliaryExercise(exercise.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exercício "$name" apagado.')),
              );
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ EXPORT SHEET â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showExportSheet(BuildContext context, TafViewModel vm) {
    final jsonStr = vm.exportAuxiliaryExercisesJson();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
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
                  Row(
                    children: [
                      const Icon(
                        Icons.download_rounded,
                        color: AppTheme.lightBlue,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Exportar Catálogo de Exercícios',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${vm.auxiliaryExercises.length} exercícios',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Copie o JSON abaixo para fazer backup ou compartilhar. Você pode importá-lo depois.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonStr));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'JSON copiado para a área de transferência!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text(
                        'Copiar JSON para Área de Transferência',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          jsonStr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // â”€â”€â”€ IMPORT DIALOG â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showImportDialog(BuildContext context, TafViewModel vm) {
    final jsonCtrl = TextEditingController();
    bool replaceAll = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardSurface,
            title: const Row(
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  color: AppTheme.lightBlue,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text('Importar Exercícios'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cole o JSON exportado anteriormente. O formato deve ser uma lista [ {...}, ... ] de exercícios.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: jsonCtrl,
                    maxLines: 8,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cole o JSON aqui',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setModalState(() => replaceAll = !replaceAll),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: replaceAll,
                          onChanged: (v) =>
                              setModalState(() => replaceAll = v ?? false),
                          activeColor: AppTheme.primaryBlue,
                        ),
                        const Expanded(
                          child: Text(
                            'Substituir todo o catálogo (apaga os atuais)',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Importar'),
                onPressed: () async {
                  final text = jsonCtrl.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cole o JSON antes de importar.'),
                      ),
                    );
                    return;
                  }
                  try {
                    final count = await vm.importAuxiliaryExercisesFromJson(
                      text,
                      replaceAll: replaceAll,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            replaceAll
                                ? '$count exercícios importados (catálogo substituído).'
                                : '$count exercícios importados/atualizados!',
                          ),
                        ),
                      );
                    }
                  } on FormatException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro no JSON: ${e.message}'),
                          backgroundColor: AppTheme.accentRed,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao importar: $e'),
                          backgroundColor: AppTheme.accentRed,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€â”€ EXERCISE CARD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onTapDetails,
    required this.onTapVideo,
    required this.onTapLog,
    required this.onTapEdit,
    required this.onTapDelete,
  });

  final AuxiliaryExercise exercise;
  final VoidCallback onTapDetails;
  final VoidCallback onTapVideo;
  final VoidCallback onTapLog;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

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
              // Header: Category chip & Custom badge & kebab menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          exercise.category.icon,
                          size: 12,
                          color: AppTheme.lightBlue,
                        ),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (exercise.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PERSONALIZADO',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppTheme.textMuted,
                          ),
                          color: AppTheme.cardSurfaceElevated,
                          onSelected: (val) {
                            if (val == 'edit') onTapEdit();
                            if (val == 'delete') onTapDelete();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: AppTheme.lightBlue,
                                    size: 16,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Editar',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppTheme.accentRed,
                                    size: 16,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Apagar',
                                    style: TextStyle(color: AppTheme.accentRed),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    onPressed: onTapVideo,
                    icon: const Icon(Icons.play_circle_filled, size: 18),
                    label: const Text(
                      'VÃ­deo YouTube',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onTapLog,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Treinar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/belt_rank.dart';
import '../../core/theme.dart';
import '../../widgets/belt_badge.dart';
import '../view_models/taf_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _dojoController = TextEditingController();
  final _instructorController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedExamDate;

  @override
  void initState() {
    super.initState();
    final profile = context.read<TafViewModel>().profile;
    _nameController.text = profile.name;
    _dojoController.text = profile.dojo;
    _instructorController.text = profile.instructor;
    _weightController.text = profile.weightKg.toString();
    _selectedExamDate = profile.targetExamDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dojoController.dispose();
    _instructorController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TafViewModel>();
    final profile = vm.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Aluno FSAKM'),
        actions: [
          IconButton(
            onPressed: () => _saveProfile(context, vm),
            icon: const Icon(Icons.save_rounded, color: AppTheme.accentGreen),
            tooltip: 'Salvar Alterações',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Avatar & Belt Summary
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  child: const Icon(Icons.person_rounded, size: 48, color: AppTheme.lightBlue),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.dojo.isNotEmpty ? profile.dojo : 'Federação Sul-Americana de Krav Maga',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BeltBadge(belt: profile.currentBelt, size: BeltBadgeSize.medium),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.textMuted),
                    ),
                    BeltBadge(belt: profile.targetBelt, size: BeltBadgeSize.medium),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Exam Countdown Card
          if (profile.daysUntilExam != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, color: AppTheme.accentGold, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONTAGEM REGRESSIVA PARA O TAF',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.daysUntilExam! >= 0
                              ? 'Faltam ${profile.daysUntilExam} dias para o exame!'
                              : 'Data do exame ultrapassada',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Data marcada: ${DateFormat('dd/MM/yyyy').format(profile.targetExamDate!)}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Form fields card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dados Cadastrais',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Aluno',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dojoController,
                    decoration: const InputDecoration(
                      labelText: 'Centro de Treinamento / Academia',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instructorController,
                    decoration: const InputDecoration(
                      labelText: 'Instrutor Responsável',
                      prefixIcon: Icon(Icons.sports_martial_arts_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso Corporal (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                      suffixText: 'kg',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Belt selection card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Graduação e Meta de Faixa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  // Current Belt Dropdown
                  const Text('Faixa Atual:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<BeltRank>(
                    initialValue: profile.currentBelt,
                    dropdownColor: AppTheme.cardSurfaceElevated,
                    decoration: const InputDecoration(),
                    items: BeltRank.values.map((belt) {
                      return DropdownMenuItem(
                        value: belt,
                        child: Row(
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: belt.color),
                            const SizedBox(width: 8),
                            Text(belt.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) vm.setCurrentBelt(val);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Target Belt Dropdown
                  const Text('Faixa Alvo (Preparação para TAF):', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<BeltRank>(
                    initialValue: profile.targetBelt,
                    dropdownColor: AppTheme.cardSurfaceElevated,
                    decoration: const InputDecoration(),
                    items: BeltRank.values.map((belt) {
                      return DropdownMenuItem(
                        value: belt,
                        child: Row(
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: belt.color),
                            const SizedBox(width: 8),
                            Text(belt.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) vm.setTargetBelt(val);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Date of exam
                  const Text('Data Prevista do Exame de Faixa:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedExamDate ?? DateTime.now().add(const Duration(days: 60)),
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setState(() => _selectedExamDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(
                      _selectedExamDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedExamDate!)
                          : 'Selecionar data do exame',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _saveProfile(context, vm),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Salvar Perfil e Metas'),
            ),
          ),

          const SizedBox(height: 24),

          // FSAKM Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sobre o TAF da FSAKM',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 6),
                Text(
                  'A Federação Sul-Americana de Krav Maga, fundada pelo Grão-Mestre Kobi Lichtenstein, exige alto padrão de condicionamento físico para garantir que as técnicas de autodefesa sejam executadas com máxima eficácia mesmo sob exaustão extrema.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Management section
          Card(
            color: AppTheme.cardSurface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gerenciamento de Dados Locais',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Todos os dados ficam armazenados 100% no seu dispositivo (Offline-First).',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmReset(context, vm),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentRed,
                            side: const BorderSide(color: AppTheme.accentRed),
                          ),
                          child: const Text('Limpar Dados'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _saveProfile(BuildContext context, TafViewModel vm) {
    final weight = double.tryParse(_weightController.text) ?? 75.0;

    vm.updateProfile(
      name: _nameController.text.trim(),
      dojo: _dojoController.text.trim(),
      instructor: _instructorController.text.trim(),
      weightKg: weight,
      targetExamDate: _selectedExamDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.cardSurfaceElevated,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen),
            SizedBox(width: 8),
            Text('Perfil atualizado com sucesso!'),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, TafViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Zerar todos os dados?'),
        content: const Text(
          'Esta ação removerá todos os treinos registrados e configurações locais. Deseja continuar?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () {
              vm.resetAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados zerados com sucesso.')),
              );
            },
            child: const Text('Zerar Tudo'),
          ),
        ],
      ),
    );
  }
}

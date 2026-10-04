import 'package:flutter/material.dart';

enum TafTestType {
  corrida(
    id: 'corrida',
    name: 'Corrida',
    shortName: 'Corrida',
    unit: 'min:s',
    metricLabel: 'Tempo (minutos/segundos)',
    icon: Icons.directions_run_rounded,
    isTimeBased: true,
    executionStandard: 'Corrida contínua ao ar livre ou em pista de atletismo. Distância fixa aferida (1.8 km na Laranja, 3.0 km nas demais faixas). Não é permitido parar.',
  ),
  barraFixa(
    id: 'barra_fixa',
    name: 'Barra Fixa',
    shortName: 'Barra',
    unit: 'reps',
    metricLabel: 'Repetições válidas',
    icon: Icons.fitness_center_rounded,
    isTimeBased: false,
    executionStandard: 'Pegada pronada (palmas para frente). Iniciar com braços estendidos e ultrapassar totalmente o queixo acima da barra. Sem impulso de pernas (kipping não permitido).',
  ),
  flexao(
    id: 'flexao',
    name: 'Flexão de Braço',
    shortName: 'Flexão',
    unit: 'reps',
    metricLabel: 'Repetições válidas',
    icon: Icons.accessibility_new_rounded,
    isTimeBased: false,
    executionStandard: 'Corpo alinhado (prancha perfeita). Descer até o peito quase tocar o solo (ângulo de 90° nos cotovelos) e estender os braços totalmente no topo.',
  ),
  abdominal(
    id: 'abdominal',
    name: 'Abdominal (2 min)',
    shortName: 'Abdominal',
    unit: 'reps',
    metricLabel: 'Repetições em 2 min',
    icon: Icons.sports_gymnastics_rounded,
    isTimeBased: false,
    executionStandard: 'Abdominal militar/remador completo no tempo limite de 2 minutos cravados. Braços e pernas estendidos, subindo até abraçar os joelhos.',
  ),
  pesinhos(
    id: 'pesinhos',
    name: 'Pesinhos (Halteres)',
    shortName: 'Pesinhos',
    unit: 'reps',
    metricLabel: 'Repetições completas',
    icon: Icons.sports_kabaddi_rounded,
    isTimeBased: false,
    executionStandard: 'Sequência canônica de exercícios com halteres do Krav Maga, mantendo postura ereta e cadência contínua sem descanso.',
  ),
  paralelas(
    id: 'paralelas',
    name: 'Barras Paralelas',
    shortName: 'Paralelas',
    unit: 'reps',
    metricLabel: 'Repetições válidas',
    icon: Icons.view_column_rounded,
    isTimeBased: false,
    executionStandard: 'Suspenso nas barras paralelas, flexionar cotovelos até pelo menos 90 graus e retornar à extensão total dos braços.',
  );

  const TafTestType({
    required this.id,
    required this.name,
    required this.shortName,
    required this.unit,
    required this.metricLabel,
    required this.icon,
    required this.isTimeBased,
    required this.executionStandard,
  });

  final String id;
  final String name;
  final String shortName;
  final String unit;
  final String metricLabel;
  final IconData icon;
  final bool isTimeBased;
  final String executionStandard;

  static TafTestType fromId(String id) {
    return TafTestType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => TafTestType.corrida,
    );
  }
}

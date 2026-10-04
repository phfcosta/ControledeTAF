import 'package:flutter/material.dart';

enum BeltRank {
  branca(
    id: 'branca',
    name: 'Faixa Branca',
    shortName: 'Branca',
    color: Color(0xFFECEFF1),
    textColor: Color(0xFF263238),
    order: 0,
    rounds: 0,
    description: 'Iniciação no Krav Maga. Foco nos fundamentos e postura.',
  ),
  amarela(
    id: 'amarela',
    name: 'Faixa Amarela',
    shortName: 'Amarela',
    color: Color(0xFFFFD600),
    textColor: Color(0xFF263238),
    order: 1,
    rounds: 0,
    description: 'Primeira graduação. Defesas básicas e ataques essenciais.',
  ),
  laranja(
    id: 'laranja',
    name: 'Faixa Laranja',
    shortName: 'Laranja',
    color: Color(0xFFFF6D00),
    textColor: Colors.white,
    order: 2,
    rounds: 1,
    description: 'Início da exigência no TAF (Corrida 1.8 km em até 10 min).',
  ),
  verde(
    id: 'verde',
    name: 'Faixa Verde',
    shortName: 'Verde',
    color: Color(0xFF2E7D32),
    textColor: Colors.white,
    order: 3,
    rounds: 1,
    description: 'Exigência física completa em todas as 6 provas do TAF.',
  ),
  azul(
    id: 'azul',
    name: 'Faixa Azul',
    shortName: 'Azul',
    color: Color(0xFF1565C0),
    textColor: Colors.white,
    order: 4,
    rounds: 1,
    description: 'Nível avançado com redução drástica nos tempos e aumento de carga.',
  ),
  marrom(
    id: 'marrom',
    name: 'Faixa Marrom',
    shortName: 'Marrom',
    color: Color(0xFF5D4037),
    textColor: Colors.white,
    order: 5,
    rounds: 1,
    description: 'Pré-requisito para instrutoria e preparação máxima para faixa preta.',
  ),
  preta(
    id: 'preta',
    name: 'Faixa Preta',
    shortName: 'Preta',
    color: Color(0xFF212121),
    textColor: Colors.white,
    order: 6,
    rounds: 3,
    description: 'Exigência máxima da FSAKM: toda a série da faixa marrom repetida 3 vezes!',
  );

  const BeltRank({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
    required this.textColor,
    required this.order,
    required this.rounds,
    required this.description,
  });

  final String id;
  final String name;
  final String shortName;
  final Color color;
  final Color textColor;
  final int order;
  final int rounds;
  final String description;

  bool get hasPhysicalRequirements => rounds > 0;

  static BeltRank fromId(String id) {
    return BeltRank.values.firstWhere(
      (b) => b.id == id,
      orElse: () => BeltRank.laranja,
    );
  }
}

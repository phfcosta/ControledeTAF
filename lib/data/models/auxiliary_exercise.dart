import 'taf_test_type.dart';

class AuxiliaryExercise {
  const AuxiliaryExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.videoUrl,
    this.musclesTargeted = const [],
    this.tips = '',
    this.isCustom = false,
  });

  final String id;
  final String name;
  final TafTestType category;
  final String description;
  final String videoUrl;
  final List<String> musclesTargeted;
  final String tips;
  final bool isCustom;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.id,
      'description': description,
      'videoUrl': videoUrl,
      'musclesTargeted': musclesTargeted,
      'tips': tips,
      'isCustom': isCustom,
    };
  }

  factory AuxiliaryExercise.fromJson(Map<String, dynamic> json) {
    return AuxiliaryExercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: TafTestType.fromId(json['category']?.toString() ?? 'corrida'),
      description: json['description']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      musclesTargeted:
          (json['musclesTargeted'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tips: json['tips']?.toString() ?? '',
      isCustom: json['isCustom'] == true,
    );
  }

  AuxiliaryExercise copyWith({
    String? id,
    String? name,
    TafTestType? category,
    String? description,
    String? videoUrl,
    List<String>? musclesTargeted,
    String? tips,
    bool? isCustom,
  }) {
    return AuxiliaryExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      musclesTargeted: musclesTargeted ?? this.musclesTargeted,
      tips: tips ?? this.tips,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  /// Initial pre-registered catalog of auxiliary exercises for Krav Maga TAF
  static List<AuxiliaryExercise> getDefaultExercises() {
    return const [
      // CORRIDA
      AuxiliaryExercise(
        id: 'corrida_tiros_400m',
        name: 'Treino de Tiros de 400m (HIIT)',
        category: TafTestType.corrida,
        description:
            'Realize 6 a 8 repetições de tiros em velocidade máxima/submáxima de 400 metros em pista ou terreno plano, com intervalo ativo ou passivo de 90 segundos entre cada tiro.',
        videoUrl: 'https://www.youtube.com/watch?v=6WhO6KYutOU',
        musclesTargeted: [
          'Quadríceps',
          'Isquiotibiais',
          'Panturrilhas',
          'Sistema Cardiovascular',
        ],
        tips:
            'Mantenha a cadência alta e postura ereta. O foco é elevar o VO2max e acostumar as pernas a tolerar lactato.',
      ),
      AuxiliaryExercise(
        id: 'corrida_fartlek',
        name: 'Fartlek Tático de Krav Maga',
        category: TafTestType.corrida,
        description:
            'Corrida contínua de 20 minutos alternando: 2 minutos em ritmo moderado de recuperação e 1 minuto em ritmo forte (pace de prova do TAF: abaixo de 4:40/km).',
        videoUrl: 'https://www.youtube.com/watch?v=-KXQSW9mGG4',
        musclesTargeted: ['Cardiorrespiratório', 'Glúteos', 'Panturrilhas'],
        tips:
            'Nunca pare totalmente nos trechos de recuperação; trote suavemente para habituar o organismo à remoção de resíduos metabólicos.',
      ),
      AuxiliaryExercise(
        id: 'corrida_longao_base',
        name: 'Corrida Contínua de Base (5 km a 7 km)',
        category: TafTestType.corrida,
        description:
            'Corrida contínua em ritmo conversacional (Zona 2). O objetivo não é velocidade, mas sim construir capacidade mitocondrial e resistência capilar nos membros inferiores.',
        videoUrl: 'https://www.youtube.com/watch?v=P493J7fCSfU',
        musclesTargeted: ['Coração', 'Resistência Muscular Geral'],
        tips:
            'Corra em um ritmo no qual você consiga falar frases curtas sem ficar sem ar. Realize 1 vez por semana.',
      ),
      AuxiliaryExercise(
        id: 'corrida_educativos',
        name: 'Educativos de Corrida (Skipping & Anfersen)',
        category: TafTestType.corrida,
        description:
            'Série de exercícios técnicos: Skipping alto (elevação alternada de joelhos), Skipping baixo, Anfersen (calcanhares nos glúteos) e Hop-ups.',
        videoUrl: 'https://www.youtube.com/watch?v=D7jzak-FDoc',
        musclesTargeted: [
          'Tibial anterior',
          'Gastrocnêmio',
          'Flexores do quadril',
        ],
        tips:
            'Aterrissagem com o antepé (metatarso), evitando bater o calcanhar com força no solo.',
      ),

      // BARRA FIXA
      AuxiliaryExercise(
        id: 'barra_elastico',
        name: 'Barra Fixa com Superband (Elástico)',
        category: TafTestType.barraFixa,
        description:
            'Prenda um elástico de tensão média/pesada na barra e posicione o joelho ou pé na alça. Realize o movimento completo da barra fixa pronada com auxílio da força do elástico.',
        videoUrl: 'https://www.youtube.com/shorts/6lw5Cp7dI6g',
        musclesTargeted: [
          'Dorsal maior',
          'Bíceps braquial',
          'Braquial',
          'Trapézio inferior',
        ],
        tips:
            'Permite acumular volume sem fadiga prematura. Vá diminuindo a espessura do elástico conforme evolui.',
      ),
      AuxiliaryExercise(
        id: 'barra_negativa',
        name: 'Barra Fixa Negativa (Excêntrica Controlada)',
        category: TafTestType.barraFixa,
        description:
            'Suba em um banco até o queixo passar da barra. Retire os pés do apoio e segure a descida de forma estritamente controlada durante 4 a 6 segundos até os braços estenderem por completo.',
        videoUrl: 'https://www.youtube.com/shorts/dyPdKvlZF2A',
        musclesTargeted: ['Grande dorsal', 'Bíceps', 'Antebraço'],
        tips:
            'O treinamento excêntrico constrói força máxima até 30% mais rápido que o concêntrico isolado.',
      ),
      AuxiliaryExercise(
        id: 'barra_isometria_topo',
        name: 'Isometria no Topo da Barra',
        category: TafTestType.barraFixa,
        description:
            'Segure-se no topo da barra com o queixo totalmente acima dela, escápulas retraídas e abdômen contraído por 15 a 30 segundos.',
        videoUrl: 'https://www.youtube.com/shorts/6DMpXHGsIlM',
        musclesTargeted: [
          'Manguito rotador',
          'Romboides',
          'Dorsais',
          'Trapézio',
        ],
        tips:
            'Não apoie o queixo na barra de metal! A sustentação deve vir da contração muscular pura.',
      ),
      AuxiliaryExercise(
        id: 'barra_remada_australiana',
        name: 'Remada Australiana (Inverted Row)',
        category: TafTestType.barraFixa,
        description:
            'Em uma barra baixa na altura da cintura, posicione o corpo inclinado com calcanhares no solo e puxe o peito até a barra com pegada pronada.',
        videoUrl: 'https://www.youtube.com/shorts/ejauYBdj74YU',
        musclesTargeted: ['Dorsais', 'Deltoide posterior', 'Core'],
        tips:
            'Excelente construtor de pegada e controle escapular antes de passar para a barra suspensa.',
      ),

      // FLEXÃO DE BRAÇO
      AuxiliaryExercise(
        id: 'flexao_joelhos',
        name: 'Flexão com Apoio nos Joelhos (Volume)',
        category: TafTestType.flexao,
        description:
            'Execução da flexão padrão apoiando os joelhos em um colchonete. Mantém tronco rígido e cotovelos a 45 graus em relação ao tronco.',
        videoUrl: 'https://www.youtube.com/shorts/h5ClL5IYzog',
        musclesTargeted: [
          'Peitoral maior',
          'Tríceps braquial',
          'Deltoide anterior',
        ],
        tips:
            'Ideal para atingir séries de 50 a 60 repetições acumulando resistência muscular localizada sem quebrar a lombar.',
      ),
      AuxiliaryExercise(
        id: 'flexao_declinada',
        name: 'Flexão Declinada (Pés Elevados no Banco)',
        category: TafTestType.flexao,
        description:
            'Apoie os pés em uma caixa ou banco de 30-40cm e posicione as mãos no chão na largura dos ombros. Desça até o peito quase encostar no chão.',
        videoUrl: 'https://www.youtube.com/shorts/hWjGbyXms-I',
        musclesTargeted: [
          'Porção clavicular do peitoral',
          'Tríceps',
          'Deltoide anterior',
        ],
        tips:
            'Aumenta a sobrecarga nos membros superiores (aproximadamente 75% do peso corporal vs 64% na tradicional).',
      ),
      AuxiliaryExercise(
        id: 'flexao_pausa_isometria',
        name: 'Flexão com Pausa de 2 Segundos no Fundo',
        category: TafTestType.flexao,
        description:
            'Desça até 2 dedos do solo, congele a posição estática por 2 segundos sem descansar o corpo no chão, e empurre explosivamente até estender.',
        videoUrl: 'https://www.youtube.com/watch?v=iO1ajaM-sY4',
        musclesTargeted: ['Peitoral', 'Tríceps', 'Estabilizadores escapulares'],
        tips:
            'Elimina o reflexo de estiramento elástico, gerando força de arranque real para o TAF.',
      ),
      AuxiliaryExercise(
        id: 'flexao_prancha_toque_ombro',
        name: 'Prancha com Toque no Ombro (Shoulder Tap)',
        category: TafTestType.flexao,
        description:
            'Na posição alta da flexão, tire uma das mãos do chão e toque o ombro oposto de forma controlada sem rotacionar a bacia.',
        videoUrl: 'https://www.youtube.com/shorts/rkHEQ0L1HnU',
        musclesTargeted: [
          'Core',
          'Serrátil anterior',
          'Deltoide',
          'Reto abdominal',
        ],
        tips:
            'Impede a fadiga prematura do core que faz muitos candidatos serem desclassificados por quadril caído no TAF.',
      ),

      // ABDOMINAL
      AuxiliaryExercise(
        id: 'abdominal_remador_ritmo',
        name: 'Abdominal Remador / Militar (Padrão TAF)',
        category: TafTestType.abdominal,
        description:
            'Deitado de costas, braços estendidos atrás da cabeça. Em movimento contínuo e sincronizado, flexione o tronco e traga os joelhos ao peito abraçando as pernas.',
        videoUrl: 'https://www.youtube.com/shorts/L5LBreRCReg',
        musclesTargeted: [
          'Reto do abdômen',
          'Oblíquos',
          'Flexores do quadril (Iliopsoas)',
        ],
        tips:
            'Treine em blocos fracionados de 30 segundos (ex: 20 reps por 30s) para atingir os 80 em 2 minutos da Faixa Azul.',
      ),
      AuxiliaryExercise(
        id: 'abdominal_prancha_frontal',
        name: 'Prancha Isométrica Frontal (Plank)',
        category: TafTestType.abdominal,
        description:
            'Apoio sobre antebraços e pontas dos pés, mantendo coluna neutra, glúteos e abdômen contraídos rigidamente por 60 a 90 segundos.',
        videoUrl: 'https://www.youtube.com/shorts/ypA5NH4hqTU',
        musclesTargeted: [
          'Transverso abdominal',
          'Multífidos',
          'Reto abdominal',
        ],
        tips:
            'Não deixe o quadril descer nem empine os glúteos. Foque na respiração diafragmática profunda.',
      ),
      AuxiliaryExercise(
        id: 'abdominal_hollow_body',
        name: 'Hollow Body Hold (Canoa)',
        category: TafTestType.abdominal,
        description:
            'Deitado de costas, pressione a lombar contra o chão, retire ombros e pernas do solo formando uma concavidade rígida. Segure por 30 a 45s.',
        videoUrl: 'https://www.youtube.com/shorts/YHBp6fvXYcI',
        musclesTargeted: ['Core profundo', 'Reto femoral', 'Psoas maior'],
        tips:
            'Exercício chave da ginástica militar; garante que sua coluna lombar não sofra dor durante os 2 minutos intensos.',
      ),
      AuxiliaryExercise(
        id: 'abdominal_elevacao_pernas',
        name: 'Elevação de Pernas no Solo ou Paralelas (Leg Raise)',
        category: TafTestType.abdominal,
        description:
            'Deite-se no colchonete ou apoie-se na estação de paralelas. Eleve as pernas esticadas até 90 graus e desça sem encostar os calcanhares no chão.',
        videoUrl: 'https://www.youtube.com/shorts/NJoFF3O87Rs',
        musclesTargeted: ['Porção infra-umbilical do abdômen', 'Psoas'],
        tips:
            'Controle rigoroso na descida das pernas para maximizar a tensão mecânica excêntrica.',
      ),

      // PESINHOS (HALTERES)
      AuxiliaryExercise(
        id: 'pesinhos_elevacao_combinada',
        name: 'Elevação Frontal e Lateral com Halteres',
        category: TafTestType.pesinhos,
        description:
            'Em pé com postura de combate Krav Maga, execute elevação frontal até a linha dos olhos, seguida de elevação lateral sem impulso do tronco.',
        videoUrl: 'https://www.youtube.com/shorts/_zhuqvG5s30',
        musclesTargeted: ['Deltoide anterior', 'Deltoide lateral', 'Trapézio'],
        tips:
            'Utilize halteres de 3 a 5 kg. Mantenha os joelhos semiflexionados e o abdômen travado.',
      ),
      AuxiliaryExercise(
        id: 'pesinhos_desenvolvimento_militar',
        name: 'Desenvolvimento Overhead com Halteres',
        category: TafTestType.pesinhos,
        description:
            'Com halteres na altura das orelhas, empurre verticalmente até a extensão total acima da cabeça e retorne sob controle.',
        videoUrl: 'https://www.youtube.com/shorts/5I7ogOjvdnc',
        musclesTargeted: ['Deltoides', 'Tríceps', 'Trapézio superior'],
        tips:
            'Construi a resistência de ombro necessária para os rounds sucessivos do exame de faixa preta.',
      ),
      AuxiliaryExercise(
        id: 'pesinhos_rosca_martelo',
        name: 'Rosca Martelo e Isometria de Pegada',
        category: TafTestType.pesinhos,
        description:
            'Com halteres e pegada neutra (palmas voltadas uma para a outra), flexione os cotovelos mantendo os braços colados ao tronco.',
        videoUrl: 'https://www.youtube.com/shorts/0rRpv6o140o',
        musclesTargeted: ['Braquial', 'Braquiorradial', 'Flexores dos dedos'],
        tips:
            'Aumenta a força da empunhadura e antebraço para sustentar a sequência canônica sem soltar os halteres.',
      ),

      // BARRAS PARALELAS
      AuxiliaryExercise(
        id: 'paralelas_banco',
        name: 'Mergulho no Banco (Bench Dips)',
        category: TafTestType.paralelas,
        description:
            'Apoie as mãos na borda de um banco atrás de você, pés estendidos à frente. Flexione os cotovelos até 90 graus e empurre de volta.',
        videoUrl: 'https://www.youtube.com/shorts/Q07t33qOow0',
        musclesTargeted: ['Tríceps', 'Peitoral anterior', 'Deltoides'],
        tips:
            'Excelente para quem ainda não consegue fazer 8 ou 15 repetições livres no aparelho de paralelas.',
      ),
      AuxiliaryExercise(
        id: 'paralelas_negativas',
        name: 'Paralelas Negativas (Descida Lenta)',
        category: TafTestType.paralelas,
        description:
            'Pule para a posição alta das barras paralelas com braços estendidos. Desça controlando o peso do corpo durante 4 a 5 segundos.',
        videoUrl: 'https://www.youtube.com/watch?v=OwZ7b7wLxzg',
        musclesTargeted: [
          'Tríceps braquial',
          'Peitoral inferior',
          'Cintura escapular',
        ],
        tips:
            'Mantenha os cotovelos apontando para trás e não abertos lateralmente, para proteger os ombros.',
      ),
      AuxiliaryExercise(
        id: 'paralelas_isometria_topo',
        name: 'Sustentação Isométrica nas Paralelas',
        category: TafTestType.paralelas,
        description:
            'Segure-se no topo das barras com braços esticados, deprimindo os ombros (afastando ombros das orelhas) por 20 a 40 segundos.',
        videoUrl: 'https://www.youtube.com/shorts/LJXx7tfoVXE',
        musclesTargeted: ['Tríceps', 'Peitoral', 'Serrátil anterior'],
        tips:
            'Construi estabilidade escapular essencial para não oscilar durante as repetições rápidas no teste.',
      ),
      AuxiliaryExercise(
        id: 'paralelas_elastico',
        name: 'Paralelas com Apoio de Superband',
        category: TafTestType.paralelas,
        description:
            'Passe um elástico através das duas barras paralelas e apoie os joelhos sobre ele para diminuir o peso corporal exigido.',
        videoUrl: 'https://www.youtube.com/shorts/oazT9LIx5Hc',
        musclesTargeted: ['Tríceps', 'Peitoral', 'Ombros'],
        tips:
            'Permite atingir a meta de 15 repetições da Faixa Azul antes de realizar sem elástico.',
      ),
    ];
  }
}

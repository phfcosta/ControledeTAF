# Controle de TAF • Federação Sul-Americana de Krav Maga (FSAKM)

Aplicativo completo em **Flutter** (Android & iOS) para planejamento, registro, evolução e controle de preparação física para o Teste de Aptidão Física (TAF) da **Federação Sul-Americana de Krav Maga**, fundada pelo Grão-Mestre Kobi Lichtenstein.

---

## 🥋 Sistema Oficial de Faixas e Metas do TAF

| Faixa | Corrida | Barra Fixa | Flexão de Braço | Abdominal (2 min) | Pesinhos (Halteres) | Barras Paralelas | Observações |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Faixa Branca** | — | — | — | — | — | — | Sem requisitos físicos |
| **Faixa Amarela** | — | — | — | — | — | — | Sem requisitos físicos |
| **Faixa Laranja** | **1.8 km** em até **10 min** | — | — | — | — | — | Ritmo ~5:33/km |
| **Faixa Verde** | **3.0 km** em até **17 min** | **5 reps** | **30 reps** | **60 reps** | **3 reps** | **8 reps** | Exigência completa das 6 provas |
| **Faixa Azul** | **3.0 km** em até **14 min** | **10 reps** | **60 reps** | **80 reps** | **5 reps** | **15 reps** | Ritmo ~4:40/km |
| **Faixa Marrom**| **3.0 km** em até **14 min** | **10 reps** | **60 reps** | **80 reps** | **5 reps** | **15 reps** | Mesmas metas da Faixa Azul |
| **Faixa Preta** | **3.0 km** em até **14 min** | **10 reps** (x3) | **60 reps** (x3) | **80 reps** (x3) | **5 reps** (x3) | **15 reps** (x3) | **Regra das 3 séries completas!** |

---

## 📱 Principais Funcionalidades

1. **Dashboard Tático & Indicador de Prontidão (%)**:
   - Card hero com taxa percentual de prontidão física em relação à faixa alvo.
   - Contagem regressiva de dias restantes até a data do exame de faixa.
   - Status individual e badges ("Aprovado", "Em evolução", "Pendente") para cada uma das 6 provas.

2. **Checklist Interativo de Metas da Faixa**:
   - Seleção rápida de qualquer faixa para consultar critérios oficiais de execução (postura de prancha, pegada pronada na barra, queixo acima, cadência de halteres).
   - Atalho direto para exercícios educativos que auxiliam cada prova.

3. **Registro de Treinos (Provas Oficiais & Educativos)**:
   - Formulário inteligente adaptado ao tipo de exercício:
     - **Corrida**: Seleção de distância (1.8 km, 3.0 km ou personalizada) e tempo com cálculo automático de Pace (min/km).
     - **Exercícios de Repetições**: Controles numéricos rápidos (+1, -1, +5, +10, +25).
     - **Séries / Rounds**: Seleção de 1x, 2x ou 3x (simulação de Faixa Preta).
     - **Escala de Percepção Subjetiva de Esforço (PSE / RPE 1-10)**.
     - Campo de anotações e observações.

4. **Visualização Gráfica Temporal com `fl_chart`**:
   - Gráficos de linha demonstrando a evolução temporal para cada prova.
   - **Linha de Meta (Target Line)** da faixa alvo destacada no gráfico.
   - Resumo com Melhor Marca, Última Marca e Histórico com opção de exclusão.

5. **Catálogo Pré-Cadastrado de Exercícios Educativos/Auxiliares**:
   - Catálogo pré-carregado com mais de 20 exercícios específicos (ex: Barra com Superband, Barra Negativa, Fartlek, Tiros de 400m, Abdominal Remador com cadência, Hollow Body, Flexão Declinada, Dips no Banco, etc.).
   - Grupos musculares trabalhados e dicas biomecânicas.
   - **Botão para abrir o vídeo explicativo correspondente no YouTube via `url_launcher`**.
   - Possibilidade de adicionar novos exercícios personalizados pelo usuário.

6. **Cronômetro Tático Oficial do TAF**:
   - Modo **Abdominal 2 Minutos (120 segundos)** com contagem regressiva e alerta ao esgotar o tempo.
   - Modos de contagem para corridas oficiais (10 min, 14 min e 17 min).
   - Cronômetro progressivo livre com registro de voltas (Laps).
   - Botão direto para registrar a marca no histórico logo após o encerramento do tempo.

7. **Armazenamento Offline First**:
   - 100% dos dados persistidos localmente no dispositivo via `shared_preferences`.
   - Total privacidade sem dependência de internet.

---

## 🏛 Arquitetura do Projeto

Seguindo os padrões recomendados da arquitetura Flutter em camadas (MVVM):

```text
lib/
├── data/
│   ├── models/
│   │   ├── auxiliary_exercise.dart   # Modelo do exercício educativo e catálogo default
│   │   ├── belt_rank.dart            # Enum das faixas, cores oficiais e rounds
│   │   ├── taf_requirement.dart      # Regras de negócio e metas por graduação
│   │   ├── taf_test_type.dart        # As 6 provas oficiais do TAF e padrões de execução
│   │   ├── user_profile.dart         # Dados do aluno, graduação atual/alvo e data do exame
│   │   └── workout_log.dart          # Sessões de treino com serialização JSON
│   ├── repositories/
│   │   └── taf_repository.dart       # Repositório de dados limpo
│   └── services/
│       └── storage_service.dart      # Persistência local offline com SharedPreferences
├── domain/
│   └── taf_evaluator.dart            # Avaliador de prontidão, percentuais e aprovação no TAF
├── ui/
│   ├── core/
│   │   ├── theme.dart                # Design tático escuro, cores e tipografia
│   │   └── url_helper.dart           # Utilitário para abertura segura de URLs do YouTube
│   ├── features/
│   │   ├── catalog/                  # Tela do catálogo de exercícios auxiliares
│   │   ├── dashboard/                # Tela inicial com prontidão global e cards de provas
│   │   ├── home/                     # Scaffold principal com BottomNavigationBar
│   │   ├── profile/                  # Perfil do aluno, faixas e countdown para o exame
│   │   ├── progress/                 # Gráficos com fl_chart e histórico detalhado
│   │   ├── target_belt/              # Checklist de requisitos e critérios de aprovação
│   │   ├── timer/                    # Cronômetro tático com contagem regressiva oficial
│   │   ├── view_models/              # TafViewModel (gerenciamento de estado com Provider)
│   │   └── workout_log/              # Modal e formulário de registro de treino
│   └── widgets/                      # Cards reutilizáveis, badges de faixa e indicadores
└── main.dart                         # Ponto de entrada da aplicação
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK (versão >= 3.12.0)
- Emulador Android / Dispositivo físico ou Simulador iOS / Mac

### 1. Clonar ou abrir o diretório do projeto:
```bash
cd c:\Users\paulo\antigravity\ControledeTAF
```

### 2. Instalar as dependências:
```bash
flutter pub get
```

### 3. Executar em modo desenvolvimento:
```bash
flutter run
```

### 4. Executar os testes automatizados:
```bash
flutter test
```

### 5. Análise de código e qualidade:
```bash
flutter analyze
```

---

## 📦 Build para Produção

### Android (APK ou App Bundle):
```bash
# Gerar APK release:
flutter build apk --release

# Gerar App Bundle (.aab) para a Google Play Store:
flutter build appbundle --release
```
*O arquivo gerado estará em `build/app/outputs/flutter-apk/app-release.apk`.*

### iOS (IPA):
```bash
flutter build ipa --release
```
*Abra a pasta `ios/` no Xcode para assinar o aplicativo com seu Apple Developer Certificate.*

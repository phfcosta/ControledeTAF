import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:controle_taf_kravmaga/data/models/belt_rank.dart';
import 'package:controle_taf_kravmaga/data/models/taf_requirement.dart';
import 'package:controle_taf_kravmaga/data/models/taf_test_type.dart';
import 'package:controle_taf_kravmaga/main.dart';
import 'package:controle_taf_kravmaga/ui/features/view_models/taf_view_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders main scaffold and TAF dashboard properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final viewModel = TafViewModel();
    await viewModel.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TafViewModel>.value(value: viewModel),
        ],
        child: const TafKravMagaApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header title and navigation items
    expect(find.textContaining('FSAKM • KRAV MAGA'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Metas TAF'), findsOneWidget);
    expect(find.text('Evolução'), findsWidgets);
    expect(find.text('Educativos'), findsWidgets);
    expect(find.text('Cronômetro'), findsOneWidget);
  });

  test('TafRequirement for Faixa Verde requires 6 tests', () {
    final reqs = TafRequirement.getRequirementsForBelt(BeltRank.verde);
    expect(reqs.length, 6);

    final runReq = reqs.firstWhere((r) => r.testType == TafTestType.corrida);
    expect(runReq.distanceKm, 3.0);
    expect(runReq.timeLimitSeconds, 1020); // 17 min
  });

  test('TafRequirement for Faixa Preta has 3 rounds requirement', () {
    final reqs = TafRequirement.getRequirementsForBelt(BeltRank.preta);
    expect(reqs.every((r) => r.rounds == 3), isTrue);
  });
}

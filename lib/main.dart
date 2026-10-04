import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/core/theme.dart';
import 'ui/features/home/main_scaffold.dart';
import 'ui/features/view_models/taf_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tafViewModel = TafViewModel();
  await tafViewModel.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TafViewModel>.value(value: tafViewModel),
      ],
      child: const TafKravMagaApp(),
    ),
  );
}

class TafKravMagaApp extends StatelessWidget {
  const TafKravMagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de TAF - Krav Maga FSAKM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
    );
  }
}

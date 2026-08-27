import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/theme/liquid_glass_theme.dart';
import 'features/finance/presentation/bloc/finance_bloc.dart';
import 'features/finance/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: LiquidGlassTheme.backgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await initializeDateFormatting('id_ID', null);
  await setupLocator();
  runApp(const UltimateFinanceApp());
}

class UltimateFinanceApp extends StatelessWidget {
  const UltimateFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FinanceBloc>()..add(LoadDataEvent()),
      child: MaterialApp(
        title: 'Keuangan Keluarga',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: LiquidGlassTheme.darkTheme,
        home: const DashboardPage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ImatDataHandler(),
      child: const IMatApp(),
    ),
  );
}

class IMatApp extends StatelessWidget {
  const IMatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'iMat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: const Locale('sv', 'SE'),
      supportedLocales: const [
        Locale('sv', 'SE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

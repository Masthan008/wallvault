import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase once configuration files are added
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: WallVaultApp(),
    ),
  );
}

class WallVaultApp extends StatelessWidget {
  const WallVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WallVault',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme, // Force dark mode only per PRD
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

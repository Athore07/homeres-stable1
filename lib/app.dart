// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/settings/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';


class HomeresApp extends ConsumerWidget {
  const HomeresApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HOMERES',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
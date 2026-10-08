import 'package:flutter/material.dart';

import 'views/app_start_screen.dart';

class NidoApp extends StatelessWidget {
  const NidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF153A3A);

    return MaterialApp(
      title: 'Nido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE07A5F),
          brightness: Brightness.light,
        ).copyWith(
          primary: navy,
          onPrimary: Colors.white,
          surface: const Color(0xFFFFFCF7),
          onSurface: navy,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4EFE6),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4DDD2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFF6E756D)),
        ),
      ),
      home: const AppStartScreen(),
    );
  }
}

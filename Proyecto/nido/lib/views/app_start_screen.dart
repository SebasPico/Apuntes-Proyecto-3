import 'package:flutter/material.dart';

import '../controllers/sesion_state.dart';
import 'auth/login_screen.dart';
import 'grupo_familiar/grupo_familiar_screen.dart';
import 'home/home_screen.dart';

/// Decide la primera pantalla según haya (o no) una sesión guardada.
class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirigir());
  }

  Future<void> _redirigir() async {
    try {
      await SesionState.instancia.cargar();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
      return;
    }

    if (!mounted) return;

    final usuario = SesionState.instancia.usuario;
    final grupo = SesionState.instancia.grupo;

    final Widget destino;
    if (usuario == null) {
      destino = const LoginScreen();
    } else if (grupo == null) {
      destino = const GrupoFamiliarScreen();
    } else {
      destino = const HomeScreen();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destino),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar tu sesión de Firebase.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(error, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => setState(() {
                    _error = null;
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _redirigir(),
                    );
                  }),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

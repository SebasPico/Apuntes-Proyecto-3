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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirigir());
  }

  Future<void> _redirigir() async {
    try {
      await SesionState.instancia.cargar();
    } catch (_) {
      // Si falla la carga, se continúa sin sesión activa.
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

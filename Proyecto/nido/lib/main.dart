import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const NidoApp());
  } catch (error) {
    runApp(_FirebaseInitializationError(error: error));
  }
}

class _FirebaseInitializationError extends StatelessWidget {
  const _FirebaseInitializationError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SelectableText(
            'No se pudo inicializar Firebase. Verifica la configuración de '
            'Firebase para esta plataforma y vuelve a iniciar la app.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

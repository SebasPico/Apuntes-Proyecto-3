import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/firebase_connection_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  if (!kIsWeb && isMobile) {
    try {
      await Firebase.initializeApp();
      final documentId = await FirebaseConnectionTest.writeTestDocument();
      debugPrint('Firebase conectado. Documento de prueba: test/$documentId');
    } on FirebaseException catch (error) {
      debugPrint('Error de Firebase [${error.code}]: ${error.message}');
    } catch (error) {
      debugPrint('Error al probar la conexión con Firebase: $error');
    }
  } else {
    debugPrint('Prueba de Firebase omitida: ejecuta la app en Android o iOS.');
  }

  runApp(const NidoApp());
}

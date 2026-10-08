import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nido/views/auth/login_screen.dart';

void main() {
  testWidgets('muestra la pantalla de inicio de sesión',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿No tienes cuenta?'), findsOneWidget);
  });

  testWidgets('permite navegar visualmente al registro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}

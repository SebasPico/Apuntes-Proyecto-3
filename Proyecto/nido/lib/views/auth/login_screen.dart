import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../services/notification_service.dart';
import '../../utils/validators.dart';
import '../grupo_familiar/grupo_familiar_screen.dart';
import '../home/home_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _cargando = false;
  String? _errorGeneral;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    setState(() => _errorGeneral = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final usuario = await _authController.iniciarSesion(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await SesionState.instancia.iniciarSesion(usuario);
      if (!mounted) return;

      // Si ya pertenece a un grupo, entra directo a Home (RF02/RF03).
      final tieneGrupo = SesionState.instancia.grupo != null;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              tieneGrupo ? const HomeScreen() : const GrupoFamiliarScreen(),
        ),
        (_) => false,
      );
      await Future<void>.delayed(Duration.zero);
      await NotificationService.openPending();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorGeneral = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 32 + bottomInset),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _NidoMark(),
                  const SizedBox(height: 52),
                  Text(
                    'Bienvenido de nuevo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF153A3A),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tu hogar, organizado en un solo lugar.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6E756D),
                    ),
                  ),
                  const SizedBox(height: 34),
                  if (_errorGeneral != null) ...[
                    _ErrorBanner(mensaje: _errorGeneral!),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF153A3A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6E756D),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegistroScreen(),
                          ),
                        ),
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _VisualNote(),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB65A43)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Color(0xFF8C3F2E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NidoMark extends StatelessWidget {
  const _NidoMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE07A5F),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'nido',
          style: TextStyle(
            color: Color(0xFF153A3A),
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _VisualNote extends StatelessWidget {
  const _VisualNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F7666)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cuida tu hogar, una zona a la vez.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF315448),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

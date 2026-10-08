import 'package:flutter/material.dart';

import '../../controllers/sesion_state.dart';
import '../auth/login_screen.dart';
import 'historial_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Future<void> _cerrarSesion() async {
    await SesionState.instancia.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _salirDelGrupo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del grupo familiar'),
        content: const Text(
          'Perderás acceso al inventario de este grupo. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB65A43),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    // SesionState notifica y esta pantalla se reconstruye sola.
    await SesionState.instancia.salirDeGrupo();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SesionState.instancia,
      builder: (context, _) {
        final usuario = SesionState.instancia.usuario;
        final grupo = SesionState.instancia.grupo;
        final iniciales = (usuario?.nombreCompleto ?? '?')
            .trim()
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFE8),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 29,
                      backgroundColor: const Color(0xFFE07A5F),
                      child: Text(
                        iniciales.isEmpty ? '?' : iniciales,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario?.nombreCompleto ?? 'Usuario',
                            style: const TextStyle(
                              color: Color(0xFF153A3A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            usuario?.email ?? '',
                            style: const TextStyle(
                              color: Color(0xFF6E756D),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Mi grupo familiar',
                style: TextStyle(
                  color: Color(0xFF153A3A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (grupo == null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4DDD2)),
                  ),
                  child: const Text(
                    'Aún no perteneces a un grupo familiar.',
                    style: TextStyle(color: Color(0xFF6E756D)),
                  ),
                )
              else ...[
                _ProfileTile(
                  icon: Icons.home_work_outlined,
                  title: grupo.nombre,
                  subtitle: '${grupo.integrantesIds.length} integrantes',
                ),
                _ProfileTile(
                  icon: Icons.key_outlined,
                  title: grupo.codigoAcceso,
                  subtitle: 'Código de acceso',
                  trailing: Icons.copy_rounded,
                ),
              ],
              _ProfileTile(
                icon: Icons.history_rounded,
                title: 'Historial de cambios',
                subtitle: 'Consulta la actividad del hogar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistorialScreen()),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF153A3A),
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Color(0xFF153A3A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              if (grupo != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _salirDelGrupo,
                  icon: const Icon(Icons.exit_to_app_rounded),
                  label: const Text('Salir del grupo familiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB65A43),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E8),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: const Color(0xFFE07A5F)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF153A3A),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        trailing ?? Icons.chevron_right_rounded,
        color: const Color(0xFF6E756D),
      ),
    );
  }
}

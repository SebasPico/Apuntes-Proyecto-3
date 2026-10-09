import 'package:flutter/material.dart';

import '../../controllers/aviso_controller.dart';
import '../../controllers/espacio_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/aviso_inventario.dart';
import '../inventario/inventario_screen.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final _avisoController = AvisoController();
  final _espacioController = EspacioController();
  String? _openingId;

  Future<void> _abrirAviso(AvisoInventario aviso, String usuarioId) async {
    if (_openingId != null) return;
    setState(() => _openingId = aviso.id);
    try {
      if (!aviso.leidaPorUsuario(usuarioId)) {
        await _avisoController.marcarLeida(
          grupoId: aviso.grupoId,
          avisoId: aviso.id,
          usuarioId: usuarioId,
        );
      }
      final espacio = await _espacioController.obtenerPorId(
        grupoId: aviso.grupoId,
        espacioId: aviso.espacioId,
      );
      if (!mounted) return;
      if (espacio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El espacio asociado ya no existe.')),
        );
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => InventarioScreen(
            espacio: espacio,
            productoIdInicial: aviso.productoId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el aviso: $error')),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grupo = SesionState.instancia.grupo;
    final usuario = SesionState.instancia.usuario;
    if (grupo == null || usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tus avisos.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<AvisoInventario>>(
        stream: _avisoController.observarPorGrupo(grupo.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los avisos. '
                  'Revisa la conexión e inténtalo de nuevo.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final avisos = snapshot.data!;
          if (avisos.isEmpty) return const _EmptyAlerts();
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              const Text(
                'Alertas de tu hogar',
                style: TextStyle(
                  color: Color(0xFF153A3A),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toca un aviso para abrir el producto en su inventario.',
                style: TextStyle(color: Color(0xFF6E756D)),
              ),
              const SizedBox(height: 24),
              for (final aviso in avisos)
                _NotificationTile(
                  aviso: aviso,
                  leida: aviso.leidaPorUsuario(usuario.id),
                  cargando: _openingId == aviso.id,
                  onTap: () => _abrirAviso(aviso, usuario.id),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: Color(0xFF6B9DA1),
          ),
          SizedBox(height: 16),
          Text(
            'No hay avisos nuevos',
            style: TextStyle(
              color: Color(0xFF153A3A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Te avisaremos cuando un producto llegue al mínimo o se agote.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6E756D)),
          ),
        ],
      ),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.aviso,
    required this.leida,
    required this.cargando,
    required this.onTap,
  });

  final AvisoInventario aviso;
  final bool leida;
  final bool cargando;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final agotado = aviso.tipo == 'agotado';
    final color = agotado
        ? const Color(0xFFC85C4D)
        : const Color(0xFFD0A340);
    final fecha = aviso.fecha;
    final fechaTexto = fecha == null
        ? 'Fecha no disponible'
        : '${MaterialLocalizations.of(context).formatShortDate(fecha)} · '
              '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(fecha))}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: leida
          ? Colors.white.withValues(alpha: 0.72)
          : const Color(0xFFFFF4E8),
      child: InkWell(
        onTap: cargando ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (cargando)
                const SizedBox.square(
                  dimension: 42,
                  child: Padding(
                    padding: EdgeInsets.all(9),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(
                    agotado
                        ? Icons.error_outline_rounded
                        : Icons.warning_amber_rounded,
                    color: color,
                  ),
                ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agotado
                          ? '${aviso.nombreProducto} se agotó'
                          : '${aviso.nombreProducto} llegó al mínimo',
                      style: TextStyle(
                        color: const Color(0xFF153A3A),
                        fontWeight: leida ? FontWeight.w600 : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${aviso.nombreEspacio} · ${aviso.cantidad} '
                      '${aviso.cantidad == 1 ? 'unidad' : 'unidades'} '
                      '(mínimo ${aviso.cantidadMinima})',
                      style: const TextStyle(
                        color: Color(0xFF6E756D),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      fechaTexto,
                      style: const TextStyle(
                        color: Color(0xFF6E756D),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!leida)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.circle,
                    size: 9,
                    color: Color(0xFFE07A5F),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

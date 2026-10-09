import 'package:flutter/material.dart';

import '../../controllers/espacio_controller.dart';
import '../../controllers/producto_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/producto.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final _espacioController = EspacioController();
  final _productoController = ProductoController();
  List<Producto> _alerts = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    final grupo = SesionState.instancia.grupo;
    if (grupo == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    final espacios = await _espacioController.listarPorGrupo(grupo.id);
    final alerts = <Producto>[];
    for (final espacio in espacios) {
      final products = await _productoController.listarPorEspacio(
        grupoId: grupo.id,
        espacioId: espacio.id,
      );
      alerts.addAll(
        products.where((product) => product.cantidad <= product.cantidadMinima),
      );
    }
    if (!mounted) return;
    setState(() {
      _alerts = alerts;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
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
            'Mantente al día con lo que necesita atención.',
            style: TextStyle(color: Color(0xFF6E756D)),
          ),
          const SizedBox(height: 24),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else if (_alerts.isEmpty)
            const _EmptyAlerts()
          else
            for (final product in _alerts)
              _NotificationTile(
                icon: product.cantidad <= 0
                    ? Icons.error_outline_rounded
                    : Icons.warning_amber_rounded,
                color: product.cantidad <= 0
                    ? const Color(0xFFC85C4D)
                    : const Color(0xFFD0A340),
                title: product.cantidad <= 0
                    ? '${product.nombre} se agotó'
                    : '${product.nombre} está bajo el mínimo',
                detail: '${product.cantidad} ${product.unidad}',
              ),
        ],
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: Color(0xFF6B9DA1),
          ),
          SizedBox(height: 16),
          Text(
            'No hay alertas',
            style: TextStyle(
              color: Color(0xFF153A3A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las alertas aparecerán cuando un producto necesite atención.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6E756D)),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .78),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFE4DDD2)),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF153A3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                style: const TextStyle(color: Color(0xFF6E756D), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

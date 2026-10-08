import 'package:flutter/material.dart';

import '../inventario/inventario_screen.dart';
import 'crear_espacio_screen.dart';

class DetalleEspacioScreen extends StatelessWidget {
  const DetalleEspacioScreen({
    super.key,
    required this.nombre,
    required this.color,
    required this.icono,
  });

  final String nombre;
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del espacio'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(icono, color: color, size: 34),
                      const SizedBox(height: 10),
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Color(0xFF153A3A),
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Código QR del espacio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF153A3A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE4DDD2)),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: _QrPainter(color: color),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          color: Colors.white,
                          child: Icon(Icons.home_rounded, color: color, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'NIDO-COCINA-4821',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6E756D),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Descargar / imprimir QR'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF153A3A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InventarioScreen(
                        espacioNombre: nombre,
                        espacioColor: color,
                        espacioIcono: icono,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Ver inventario'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    foregroundColor: const Color(0xFF153A3A),
                    side: const BorderSide(color: Color(0xFF153A3A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CrearEspacioScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar espacio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final unit = size.width / 13;
    final cells = <Offset>[
      const Offset(0, 0), const Offset(1, 0), const Offset(2, 0),
      const Offset(0, 1), const Offset(2, 1), const Offset(0, 2),
      const Offset(1, 2), const Offset(2, 2), const Offset(10, 0),
      const Offset(11, 0), const Offset(12, 0), const Offset(10, 1),
      const Offset(12, 1), const Offset(10, 2), const Offset(11, 2),
      const Offset(12, 2), const Offset(0, 10), const Offset(1, 10),
      const Offset(2, 10), const Offset(0, 11), const Offset(2, 11),
      const Offset(0, 12), const Offset(1, 12), const Offset(2, 12),
      const Offset(5, 4), const Offset(7, 4), const Offset(4, 6),
      const Offset(6, 6), const Offset(8, 6), const Offset(5, 8),
      const Offset(7, 8), const Offset(9, 10), const Offset(11, 8),
      const Offset(6, 11), const Offset(9, 12),
    ];
    for (final cell in cells) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cell.dx * unit, cell.dy * unit, unit * .82, unit * .82),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.color != color;
}

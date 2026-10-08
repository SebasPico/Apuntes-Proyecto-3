import 'package:flutter/material.dart';

import '../inventario/inventario_screen.dart';

class EscanearQrScreen extends StatelessWidget {
  const EscanearQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
        child: Column(
          children: [
            const Text(
              'Abre un espacio al instante',
              style: TextStyle(color: Color(0xFF153A3A), fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enfoca el código QR que tienes pegado en tu hogar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6E756D)),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                decoration: BoxDecoration(
                  color: const Color(0xFF153A3A),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 72, color: Color(0xFF789A76)),
                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFFD7A8), width: 4),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    const Positioned(
                      bottom: 24,
                      child: Text('Cámara lista', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InventarioScreen(
                    espacioNombre: 'Cocina',
                    espacioColor: Color(0xFFE07A5F),
                    espacioIcono: Icons.restaurant_rounded,
                  ),
                ),
              ),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Elegir espacio manualmente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF153A3A),
                minimumSize: const Size.fromHeight(54),
                side: const BorderSide(color: Color(0xFF153A3A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

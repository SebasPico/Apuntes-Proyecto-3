import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/espacio.dart';
import '../../utils/espacio_icons.dart';
import '../inventario/inventario_screen.dart';

class DetalleEspacioScreen extends StatelessWidget {
  const DetalleEspacioScreen({super.key, required this.espacio});

  final Espacio espacio;

  String get _qrPayload =>
      'nido://space/${Uri.encodeComponent(espacio.grupoId)}/'
      '${Uri.encodeComponent(espacio.id)}';

  @override
  Widget build(BuildContext context) {
    final color = Color(espacio.colorValue);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR del espacio'),
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
                      Icon(
                        EspacioIcons.forKey(espacio.iconKey),
                        color: color,
                        size: 34,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        espacio.nombre,
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
                  'Escanea este código para abrir el inventario',
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
                  child: QrImageView(
                    data: _qrPayload,
                    version: QrVersions.auto,
                    size: 260,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: color,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: color,
                    ),
                    semanticsLabel: 'Código QR de ${espacio.nombre}',
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _qrPayload,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6E756D),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _qrPayload));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Identificador copiado.')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copiar identificador'),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InventarioScreen(espacio: espacio),
                    ),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Ver inventario'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF153A3A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

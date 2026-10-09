import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../controllers/espacio_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/espacio.dart';
import '../../utils/espacio_icons.dart';
import '../inventario/inventario_screen.dart';

class EscanearQrScreen extends StatefulWidget {
  const EscanearQrScreen({super.key});

  @override
  State<EscanearQrScreen> createState() => _EscanearQrScreenState();
}

class _EscanearQrScreenState extends State<EscanearQrScreen> {
  final _espacioController = EspacioController();
  bool _handlingCode = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handlingCode) return;
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (value == null) return;

    setState(() => _handlingCode = true);
    try {
      final uri = Uri.tryParse(value);
      if (uri == null ||
          uri.scheme != 'nido' ||
          uri.host != 'space' ||
          uri.pathSegments.length != 2) {
        _showMessage('El código QR no pertenece a un espacio de Nido.');
        return;
      }

      final group = SesionState.instancia.grupo;
      if (group == null || uri.pathSegments.first != group.id) {
        _showMessage('Este espacio no pertenece al grupo activo.');
        return;
      }

      final espacio = await _espacioController.obtenerPorId(
        grupoId: group.id,
        espacioId: uri.pathSegments.last,
      );
      if (!mounted) return;
      if (espacio == null) {
        _showMessage('No se encontró el espacio asociado al código.');
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InventarioScreen(espacio: espacio),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('No se pudo abrir el espacio: $error');
    } finally {
      if (mounted) setState(() => _handlingCode = false);
    }
  }

  Future<void> _elegirEspacio() async {
    final group = SesionState.instancia.grupo;
    if (group == null) {
      _showMessage('Primero debes crear o unirte a un grupo familiar.');
      return;
    }
    final espacio = await showModalBottomSheet<Espacio>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: StreamBuilder<List<Espacio>>(
            stream: _espacioController.observarPorGrupo(group.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('No se pudieron cargar los espacios: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('Todavía no hay espacios.'));
              }
              return ListView(
                children: [
                  for (final space in snapshot.data!)
                    ListTile(
                      leading: Icon(EspacioIcons.forKey(space.iconKey)),
                      title: Text(space.nombre),
                      onTap: () => Navigator.of(context).pop(space),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    if (!mounted || espacio == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InventarioScreen(espacio: espacio),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
        child: Column(
          children: [
            const Text(
              'Abre un espacio al instante',
              style: TextStyle(
                color: Color(0xFF153A3A),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enfoca el código QR del espacio de tu hogar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6E756D)),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: MobileScanner(
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No se pudo iniciar la cámara: ${error.errorCode.name}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _elegirEspacio,
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Elegir espacio manualmente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF153A3A),
                minimumSize: const Size.fromHeight(54),
                side: const BorderSide(color: Color(0xFF153A3A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

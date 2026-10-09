import 'package:flutter/material.dart';

import '../../controllers/espacio_controller.dart';
import '../../controllers/producto_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/espacio.dart';
import '../../models/producto.dart';

class VistaConsolidadaScreen extends StatefulWidget {
  const VistaConsolidadaScreen({super.key});

  @override
  State<VistaConsolidadaScreen> createState() => _VistaConsolidadaScreenState();
}

class _VistaConsolidadaScreenState extends State<VistaConsolidadaScreen> {
  final _espacioController = EspacioController();
  final _productoController = ProductoController();
  final _searchController = TextEditingController();
  Map<Espacio, List<Producto>> _groups = {};
  bool _cargando = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarInventario() async {
    final grupo = SesionState.instancia.grupo;
    if (grupo == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    final spaces = await _espacioController.listarPorGrupo(grupo.id);
    final groups = <Espacio, List<Producto>>{};
    for (final space in spaces) {
      groups[space] = await _productoController.listarPorEspacio(
        grupoId: grupo.id,
        espacioId: space.id,
      );
    }
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleGroups = _groups.entries
        .map((entry) => MapEntry(
              entry.key,
              entry.value.where((product) => product.nombre.toLowerCase().contains(_search.toLowerCase())).toList(),
            ))
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vista consolidada'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          const Text('Todo tu inventario', style: TextStyle(color: Color(0xFF153A3A), fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Consulta y filtra los productos de todos tus espacios.', style: TextStyle(color: Color(0xFF6E756D))),
          const SizedBox(height: 22),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _search = value),
            decoration: const InputDecoration(hintText: 'Buscar producto', prefixIcon: Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 22),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else if (visibleGroups.isEmpty)
            const _EmptyInventory()
          else
            for (final entry in visibleGroups) ...[
              Padding(padding: const EdgeInsets.only(bottom: 9), child: Text(entry.key.nombre, style: const TextStyle(color: Color(0xFF315448), fontWeight: FontWeight.w800))),
              for (final product in entry.value)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .78), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE4DDD2))),
                  child: Row(children: [
                    const Icon(Icons.inventory_2_outlined, color: Color(0xFFE07A5F)),
                    const SizedBox(width: 12),
                    Text('${product.nombre} · ${product.cantidad} ${product.unidad}', style: const TextStyle(color: Color(0xFF153A3A), fontWeight: FontWeight.w600)),
                  ]),
                ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
    child: Column(
      children: [
        Icon(Icons.inventory_2_outlined, size: 56, color: Color(0xFF6B9DA1)),
        SizedBox(height: 16),
        Text('No hay productos todavía', style: TextStyle(color: Color(0xFF153A3A), fontSize: 18, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text('Crea un espacio y agrega productos para verlos aquí.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6E756D))),
      ],
    ),
  );
}

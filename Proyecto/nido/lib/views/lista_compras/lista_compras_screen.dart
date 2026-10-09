import 'package:flutter/material.dart';

import '../../controllers/espacio_controller.dart';
import '../../controllers/producto_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/producto.dart';

class ListaComprasScreen extends StatefulWidget {
  const ListaComprasScreen({super.key});

  @override
  State<ListaComprasScreen> createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  final _espacioController = EspacioController();
  final _productoController = ProductoController();
  List<Producto> _items = [];
  final _checked = <String>{};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarItems();
  }

  Future<void> _cargarItems() async {
    final grupo = SesionState.instancia.grupo;
    if (grupo == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    final espacios = await _espacioController.listarPorGrupo(grupo.id);
    final productos = <Producto>[];
    for (final espacio in espacios) {
      final items = await _productoController.listarPorEspacio(
        grupoId: grupo.id,
        espacioId: espacio.id,
      );
      productos.addAll(
        items.where((item) => item.cantidad <= item.cantidadMinima),
      );
    }
    if (!mounted) return;
    setState(() {
      _items = productos;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de compras'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
        children: [
          const Text('Lo que tu hogar necesita', style: TextStyle(color: Color(0xFF153A3A), fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Los productos aparecen aquí cuando necesitan reposición.', style: TextStyle(color: Color(0xFF6E756D))),
          const SizedBox(height: 24),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else if (_items.isEmpty)
            const _EmptyShoppingList()
          else ...[
            const _SectionLabel(title: 'Necesita reposición', color: Color(0xFFE07A5F)),
            const SizedBox(height: 10),
            for (final item in _items)
              _ShoppingItem(
                product: item,
                checked: _checked.contains(item.id),
                onChanged: (value) => setState(() {
                  if (value) {
                    _checked.add(item.id);
                  } else {
                    _checked.remove(item.id);
                  }
                }),
              ),
          ],
        ],
      ),
    );
  }
}

class _EmptyShoppingList extends StatelessWidget {
  const _EmptyShoppingList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.shopping_basket_outlined, size: 56, color: Color(0xFF6B9DA1)),
          SizedBox(height: 16),
          Text('Tu lista está vacía', style: TextStyle(color: Color(0xFF153A3A), fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('Cuando un producto llegue a cero, aparecerá aquí.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6E756D))),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 9, color: color),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(color: Color(0xFF315448), fontWeight: FontWeight.w700)),
    ],
  );
}

class _ShoppingItem extends StatelessWidget {
  const _ShoppingItem({required this.product, required this.checked, required this.onChanged});
  final Producto product;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .78), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DDD2))),
    child: Row(
      children: [
        Checkbox(value: checked, onChanged: (value) => onChanged(value ?? false), activeColor: const Color(0xFF153A3A)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.nombre, style: const TextStyle(color: Color(0xFF153A3A), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${product.cantidad} ${product.unidad}', style: const TextStyle(color: Color(0xFF6E756D), fontSize: 12)),
        ])),
      ],
    ),
  );
}

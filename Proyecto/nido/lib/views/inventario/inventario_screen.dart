import 'package:flutter/material.dart';

import '../../controllers/producto_controller.dart';
import '../../models/producto.dart';
import '../espacios/crear_espacio_screen.dart';
import '../espacios/detalle_espacio_screen.dart';
import 'producto_form_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({
    super.key,
    this.espacioId = 'demo-group',
    required this.espacioNombre,
    required this.espacioColor,
    required this.espacioIcono,
  });

  final String espacioId;
  final String espacioNombre;
  final Color espacioColor;
  final IconData espacioIcono;

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _controller = ProductoController();
  String _search = '';
  List<Producto> _products = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final productos = await _controller.listarPorGrupo(widget.espacioId);
    if (!mounted) return;
    setState(() {
      _products = productos;
      _cargando = false;
    });
  }

  Future<void> _agregarProducto(Producto producto) async {
    final existentes = await _controller.listarPorGrupo(widget.espacioId);
    final existente = existentes.where(
      (item) => item.nombre.trim().toLowerCase() == producto.nombre.trim().toLowerCase(),
    ).firstOrNull;

    if (existente == null) {
      await _controller.crear(producto);
    } else {
      await _controller.actualizar(
        existente.copyWith(
          cantidad: existente.cantidad + producto.cantidad,
          cantidadMinima: producto.cantidadMinima,
          unidad: producto.unidad,
          prioridad: producto.prioridad,
          estado: existente.cantidad + producto.cantidad <= producto.cantidadMinima
              ? 'Por revisar'
              : 'Disponible',
        ),
      );
    }
    await _cargarProductos();
  }

  Future<void> _actualizarProducto(Producto producto) async {
    await _controller.actualizar(producto);
    await _cargarProductos();
  }

  Future<void> _eliminarProducto(String id) async {
    await _controller.eliminar(id);
    await _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products
        .where(
          (product) => product.nombre.toLowerCase().contains(
            _search.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 194,
            pinned: true,
            backgroundColor: widget.espacioColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Text(widget.espacioNombre),
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 76, 24, 46),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.espacioIcono, size: 32),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Ver código QR',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetalleEspacioScreen(
                      nombre: widget.espacioNombre,
                      color: widget.espacioColor,
                      icono: widget.espacioIcono,
                    ),
                  ),
                ),
                icon: const Icon(Icons.qr_code_2_rounded),
              ),
              IconButton(
                tooltip: 'Editar espacio',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CrearEspacioScreen(),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_products.length} productos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF153A3A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const _StatusLegend(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
            sliver: SliverToBoxAdapter(
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar producto',
                  prefixIcon: Icon(Icons.search_rounded),
                  suffixIcon: Icon(Icons.tune_rounded),
                ),
              ),
            ),
          ),
          if (_cargando)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF153A3A),
                ),
              ),
            )
          else if (filteredProducts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyInventory(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
              sliver: SliverList.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProductTile(
                      product: product,
                      onIncrease: () async {
                        final updated = product.copyWith(
                          cantidad: product.cantidad + 1,
                          estado: product.cantidad + 1 <= product.cantidadMinima
                              ? 'Por revisar'
                              : 'Disponible',
                        );
                        await _actualizarProducto(updated);
                      },
                      onDecrease: () async {
                        if (product.cantidad <= 0) return;
                        final updated = product.copyWith(
                          cantidad: product.cantidad - 1,
                          estado: product.cantidad - 1 <= product.cantidadMinima
                              ? 'Por revisar'
                              : 'Disponible',
                        );
                        await _actualizarProducto(updated);
                      },
                      onEdit: () async {
                        final result = await Navigator.of(context).push<Producto>(
                          MaterialPageRoute(
                            builder: (_) => ProductoFormScreen(product: product),
                          ),
                        );
                        if (result != null) {
                          await _actualizarProducto(result);
                        }
                      },
                      onDelete: () async {
                        await _eliminarProducto(product.id);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<Producto>(
            MaterialPageRoute(
              builder: (_) => ProductoFormScreen(espacioId: widget.espacioId),
            ),
          );
          if (result != null) {
            await _agregarProducto(result);
          }
        },
        backgroundColor: const Color(0xFF153A3A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Producto'),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.onEdit,
    required this.onDelete,
  });

  final Producto product;
  final Future<void> Function() onIncrease;
  final Future<void> Function() onDecrease;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final needsAttention = product.estado != 'Disponible';
    final priorityColor = switch (product.prioridad) {
      'Alta' => const Color(0xFFC85C4D),
      'Baja' => const Color(0xFF6C936C),
      _ => const Color(0xFFD0A340),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: needsAttention
              ? const Color(0xFFE8C6B9)
              : const Color(0xFFE4DDD2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 58,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  style: const TextStyle(
                    color: Color(0xFF153A3A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.cantidad} ${product.unidad}',
                  style: const TextStyle(color: Color(0xFF6E756D)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _SmallTag(
                      label: product.prioridad,
                      color: priorityColor,
                    ),
                    if (needsAttention)
                      _SmallTag(
                        label: product.estado,
                        color: const Color(0xFFB65A43),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Aumentar cantidad',
                onPressed: () async => onIncrease(),
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: const Color(0xFF315448),
              ),
              IconButton(
                tooltip: 'Reducir cantidad',
                onPressed: () async => onDecrease(),
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: const Color(0xFF6E756D),
              ),
              IconButton(
                tooltip: 'Editar producto',
                onPressed: () async => onEdit(),
                icon: const Icon(Icons.edit_note_outlined),
                color: const Color(0xFF315448),
              ),
              IconButton(
                tooltip: 'Eliminar producto',
                onPressed: () async => onDelete(),
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFB65A43),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.circle, size: 8, color: Color(0xFFC85C4D)),
        SizedBox(width: 5),
        Text('Por revisar', style: TextStyle(color: Color(0xFF6E756D))),
      ],
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: Color(0xFFE07A5F),
            ),
            const SizedBox(height: 16),
            Text(
              'Este espacio está vacío',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF153A3A),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega el primer producto para comenzar a organizarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6E756D)),
            ),
          ],
        ),
      ),
    );
  }
}

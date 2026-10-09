import 'package:flutter/material.dart';

import '../../controllers/producto_controller.dart';
import '../../models/producto.dart';
import '../../models/espacio.dart';
import '../../utils/espacio_icons.dart';
import '../espacios/detalle_espacio_screen.dart';
import 'producto_form_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key, required this.espacio});

  final Espacio espacio;

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _controller = ProductoController();
  String _search = '';

  Future<void> _agregarProducto(Producto producto) async {
    await _ejecutar(() async {
      await _controller.crear(producto);
    });
  }

  Future<void> _actualizarProducto(Producto producto) async {
    await _ejecutar(() => _controller.actualizar(producto));
  }

  Future<void> _eliminarProducto(Producto producto) async {
    await _ejecutar(() => _controller.eliminar(producto));
  }

  Future<void> _ajustarCantidad(Producto producto, int cambio) async {
    await _ejecutar(
      () => _controller.ajustarCantidad(producto: producto, cambio: cambio),
    );
  }

  Future<void> _ejecutar(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el inventario: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Producto>>(
      stream: _controller.observarPorEspacio(
        grupoId: widget.espacio.grupoId,
        espacioId: widget.espacio.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.espacio.nombre)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo sincronizar el inventario: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildInventory(context, snapshot.data!);
      },
    );
  }

  Widget _buildInventory(BuildContext context, List<Producto> products) {
    final filteredProducts = products
        .where(
          (product) =>
              product.nombre.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 194,
            pinned: true,
            backgroundColor: Color(widget.espacio.colorValue),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Text(widget.espacio.nombre),
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
                    child: Icon(
                      EspacioIcons.forKey(widget.espacio.iconKey),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Ver código QR',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DetalleEspacioScreen(espacio: widget.espacio),
                  ),
                ),
                icon: const Icon(Icons.qr_code_2_rounded),
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
                      '${products.length} productos',
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
          if (filteredProducts.isEmpty)
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
                      onIncrease: () => _ajustarCantidad(product, 1),
                      onDecrease: () => _ajustarCantidad(product, -1),
                      onEdit: () async {
                        final result = await Navigator.of(context)
                            .push<Producto>(
                              MaterialPageRoute(
                                builder: (_) => ProductoFormScreen(
                                  product: product,
                                  grupoId: widget.espacio.grupoId,
                                  espacioId: widget.espacio.id,
                                ),
                              ),
                            );
                        if (result != null) {
                          await _actualizarProducto(result);
                        }
                      },
                      onDelete: () async {
                        await _eliminarProducto(product);
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
              builder: (_) => ProductoFormScreen(
                grupoId: widget.espacio.grupoId,
                espacioId: widget.espacio.id,
              ),
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
                    _SmallTag(label: product.prioridad, color: priorityColor),
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
                onPressed: product.cantidad <= 0
                    ? null
                    : () async => onDecrease(),
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

import 'package:flutter/material.dart';

import '../../models/producto.dart';

class ProductoFormScreen extends StatefulWidget {
  const ProductoFormScreen({
    super.key,
    this.product,
    this.espacioId = 'demo-group',
  });

  final Producto? product;
  final String espacioId;

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  late final TextEditingController _nombreController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _minimoController;
  String _priority = 'Media';
  String _unit = 'Unidades';

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nombreController = TextEditingController(text: product?.nombre ?? '');
    _cantidadController = TextEditingController(
      text: product != null ? product.cantidad.toString() : '1',
    );
    _minimoController = TextEditingController(
      text: product != null ? product.cantidadMinima.toString() : '1',
    );
    _priority = product?.prioridad ?? 'Media';
    _unit = product?.unidad ?? 'Unidades';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _minimoController.dispose();
    super.dispose();
  }

  void _guardarProducto() {
    final nombre = _nombreController.text.trim();
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;
    final cantidadMinima = int.tryParse(_minimoController.text.trim()) ?? 0;
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre para el producto.')),
      );
      return;
    }

    final producto = (widget.product ?? Producto(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre,
      categoria: 'General',
      cantidad: cantidad,
      cantidadMinima: cantidadMinima,
      unidad: _unit,
      prioridad: _priority,
      estado: cantidad <= cantidadMinima ? 'Por revisar' : 'Disponible',
      grupoId: widget.espacioId,
      creadoPor: 'demo-user',
    )).copyWith(
      nombre: nombre,
      cantidad: cantidad,
      cantidadMinima: cantidadMinima,
      unidad: _unit,
      prioridad: _priority,
      estado: cantidad <= cantidadMinima ? 'Por revisar' : 'Disponible',
    );

    Navigator.of(context).pop(producto);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar producto' : 'Nuevo producto'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  editing ? 'Actualiza los datos' : 'Agrega algo nuevo',
                  style: const TextStyle(
                    color: Color(0xFF153A3A),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Define cuándo debe aparecer en tu lista de compras.',
                  style: TextStyle(color: Color(0xFF6E756D)),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    hintText: 'Ej. Papel higiénico',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cantidadController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad actual',
                          prefixIcon: Icon(Icons.numbers_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(labelText: 'Unidad'),
                        items: const ['Unidades', 'Rollos', 'Litros', 'Kg', 'Gramos']
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                        onChanged: (value) => setState(() => _unit = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _minimoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad mínima',
                    helperText: 'Al llegar a este número se genera una alerta.',
                    prefixIcon: Icon(Icons.warning_amber_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Prioridad de compra',
                  style: TextStyle(color: Color(0xFF153A3A), fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Alta', label: Text('Alta')),
                    ButtonSegment(value: 'Media', label: Text('Media')),
                    ButtonSegment(value: 'Baja', label: Text('Baja')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (value) => setState(() => _priority = value.first),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _guardarProducto,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(editing ? 'Guardar cambios' : 'Agregar producto'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF153A3A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (editing)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop<Producto>(widget.product);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Eliminar producto'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFB65A43)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

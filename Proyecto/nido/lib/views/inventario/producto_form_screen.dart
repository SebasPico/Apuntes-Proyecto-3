import 'package:flutter/material.dart';

import '../../controllers/sesion_state.dart';
import '../../models/producto.dart';

class ProductoFormScreen extends StatefulWidget {
  const ProductoFormScreen({
    super.key,
    this.product,
    required this.grupoId,
    required this.espacioId,
  });

  final Producto? product;
  final String grupoId;
  final String espacioId;

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) return;
    final cantidad = int.parse(_cantidadController.text.trim());
    final cantidadMinima = int.parse(_minimoController.text.trim());
    final userId = SesionState.instancia.usuario?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para editar el inventario.')),
      );
      return;
    }

    final product = widget.product;
    final producto = Producto(
      id: product?.id ?? '',
      nombre: _nombreController.text.trim(),
      categoria: product?.categoria ?? 'General',
      cantidad: cantidad,
      cantidadMinima: cantidadMinima,
      unidad: _unit,
      prioridad: _priority,
      grupoId: widget.grupoId,
      espacioId: widget.espacioId,
      creadoPor: product?.creadoPor ?? userId,
    );
    Navigator.of(context).pop(producto);
  }

  String? _validarCantidad(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Ingresa una cantidad entera';
    if (parsed < 0) return 'La cantidad no puede ser negativa';
    return null;
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
            child: Form(
              key: _formKey,
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
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      hintText: 'Ej. Papel higiénico',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre del producto es obligatorio';
                      }
                      if (value.trim().length > 80) {
                        return 'El nombre no puede superar 80 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad actual',
                            prefixIcon: Icon(Icons.numbers_rounded),
                          ),
                          validator: _validarCantidad,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _unit,
                          decoration: const InputDecoration(labelText: 'Unidad'),
                          items: const [
                            'Unidades',
                            'Rollos',
                            'Litros',
                            'Kg',
                            'Gramos',
                          ]
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _unit = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minimoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad mínima',
                      helperText: 'Al llegar a este número se genera una alerta.',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                    validator: _validarCantidad,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Prioridad de compra',
                    style: TextStyle(
                      color: Color(0xFF153A3A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Alta', label: Text('Alta')),
                      ButtonSegment(value: 'Media', label: Text('Media')),
                      ButtonSegment(value: 'Baja', label: Text('Baja')),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (value) =>
                        setState(() => _priority = value.first),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _guardarProducto,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      editing ? 'Guardar cambios' : 'Agregar producto',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF153A3A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
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
      ),
    );
  }
}

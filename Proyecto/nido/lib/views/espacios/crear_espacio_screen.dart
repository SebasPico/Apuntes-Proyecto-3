import 'package:flutter/material.dart';

import '../../controllers/espacio_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/espacio.dart';
import '../inventario/inventario_screen.dart';

class CrearEspacioScreen extends StatefulWidget {
  const CrearEspacioScreen({super.key});

  @override
  State<CrearEspacioScreen> createState() => _CrearEspacioScreenState();
}

class _CrearEspacioScreenState extends State<CrearEspacioScreen> {
  final _espacioController = EspacioController();
  final _nameController = TextEditingController();
  int _selectedColor = 0;
  int _selectedIcon = 0;

  final _colors = const [
    Color(0xFFE07A5F),
    Color(0xFF6B9DA1),
    Color(0xFFD0A85C),
    Color(0xFF789A76),
    Color(0xFF9A7B9B),
  ];

  final _icons = const [
    Icons.restaurant_rounded,
    Icons.water_drop_rounded,
    Icons.local_laundry_service_rounded,
    Icons.bed_rounded,
    Icons.inventory_2_rounded,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Nuevo espacio'
        : _nameController.text.trim();

    final grupo = SesionState.instancia.grupo;
    if (grupo == null) return;

    final espacio = Espacio(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: name,
      colorValue: _colors[_selectedColor].toARGB32(),
      iconCodePoint: _icons[_selectedIcon].codePoint,
      grupoId: grupo.id,
    );
    await _espacioController.crear(espacio);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InventarioScreen(
          espacioId: espacio.id,
          espacioNombre: name,
          espacioColor: _colors[_selectedColor],
          espacioIcono: _icons[_selectedIcon],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = _colors[_selectedColor];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo espacio'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 154,
                    decoration: BoxDecoration(
                      color: selectedColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _icons[_selectedIcon],
                      size: 64,
                      color: selectedColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Define una zona de tu hogar',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF153A3A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cada espacio tendrá su propio inventario y código QR.',
                    style: TextStyle(color: Color(0xFF6E756D)),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del espacio',
                      hintText: 'Ej. Cocina',
                      prefixIcon: Icon(Icons.label_outline_rounded),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Color distintivo',
                    style: TextStyle(
                      color: Color(0xFF153A3A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      for (var index = 0; index < _colors.length; index++)
                        _ColorChoice(
                          color: _colors[index],
                          selected: _selectedColor == index,
                          onTap: () => setState(() => _selectedColor = index),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Ícono del espacio',
                    style: TextStyle(
                      color: Color(0xFF153A3A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var index = 0; index < _icons.length; index++)
                        _IconChoice(
                          icon: _icons[index],
                          selected: _selectedIcon == index,
                          onTap: () => setState(() => _selectedIcon = index),
                        ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Guardar espacio'),
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

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF153A3A) : Colors.transparent,
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Seleccionar ícono',
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: selected ? Colors.white : const Color(0xFF315448),
        backgroundColor: selected
            ? const Color(0xFF153A3A)
            : Colors.white.withValues(alpha: 0.75),
        side: const BorderSide(color: Color(0xFFE4DDD2)),
        fixedSize: const Size(52, 52),
      ),
    );
  }
}

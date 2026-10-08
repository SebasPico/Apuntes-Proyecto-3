import 'package:flutter/material.dart';

import '../../controllers/espacio_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/espacio.dart';
import '../espacios/crear_espacio_screen.dart';
import '../espacios/escanear_qr_screen.dart';
import '../inventario/inventario_screen.dart';
import '../grupo_familiar/grupo_familiar_screen.dart';
import '../lista_compras/lista_compras_screen.dart';
import '../notificaciones/notificaciones_screen.dart';
import '../perfil/perfil_screen.dart';
import '../consolidado/vista_consolidada_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _homeVersion = 0;
  int _dataVersion = 0;

  Future<void> _crearEspacio() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CrearEspacioScreen()),
    );
    if (mounted) setState(() => _homeVersion++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeContent(
              key: ValueKey(_homeVersion),
              onCreateSpace: _crearEspacio,
            ),
            const EscanearQrScreen(),
            ListaComprasScreen(key: ValueKey('compras-$_dataVersion')),
            NotificacionesScreen(key: ValueKey('alertas-$_dataVersion')),
            const PerfilScreen(),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              tooltip: 'Crear espacio',
              onPressed: _crearEspacio,
              backgroundColor: const Color(0xFFE07A5F),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _dataVersion++;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Escanear',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket_rounded),
            label: 'Compras',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({super.key, required this.onCreateSpace});

  final VoidCallback onCreateSpace;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _espacioController = EspacioController();
  List<Espacio> _espacios = [];

  @override
  void initState() {
    super.initState();
    _cargarEspacios();
  }

  Future<void> _cargarEspacios() async {
    final grupo = SesionState.instancia.grupo;
    if (grupo == null) return;
    final espacios = await _espacioController.listarPorGrupo(grupo.id);
    if (!mounted) return;
    setState(() => _espacios = espacios);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombre = SesionState.instancia.usuario?.nombreCompleto
        .split(' ')
        .first;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre == null ? 'Buenos días' : 'Buenos días, $nombre',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6E756D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tu hogar',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF153A3A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VistaConsolidadaScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.dashboard_outlined, size: 16),
                        label: const Text('Ver inventario completo'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Grupo familiar',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GrupoFamiliarScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.groups_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EFE8),
                    foregroundColor: const Color(0xFF315448),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Espacios del hogar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF153A3A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_espacios.length} ${_espacios.length == 1 ? 'espacio' : 'espacios'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6E756D),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Crear espacio',
                      onPressed: widget.onCreateSpace,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: const Color(0xFFE07A5F),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          sliver: SliverToBoxAdapter(
            child: _espacios.isEmpty
                ? _EmptySpaces(onCreateSpace: widget.onCreateSpace)
                : Column(
                    children: [
                      for (final espacio in _espacios)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SpaceTile(
                            espacio: espacio,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => InventarioScreen(
                                  espacioId: espacio.id,
                                  espacioNombre: espacio.nombre,
                                  espacioColor: Color(espacio.colorValue),
                                  espacioIcono: IconData(
                                    espacio.iconCodePoint,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({required this.espacio, required this.onTap});

  final Espacio espacio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(espacio.colorValue);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: Colors.white.withValues(alpha: 0.78),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4DDD2)),
      ),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.18),
        foregroundColor: color,
        child: Icon(
          IconData(espacio.iconCodePoint, fontFamily: 'MaterialIcons'),
        ),
      ),
      title: Text(
        espacio.nombre,
        style: const TextStyle(
          color: Color(0xFF153A3A),
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: const Text('Ver inventario'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _EmptySpaces extends StatelessWidget {
  const _EmptySpaces({required this.onCreateSpace});

  final VoidCallback onCreateSpace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4DDD2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.home_work_outlined,
            size: 44,
            color: Color(0xFFE07A5F),
          ),
          const SizedBox(height: 14),
          const Text(
            'Aún no tienes espacios',
            style: TextStyle(
              color: Color(0xFF153A3A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crea el primero para empezar a organizar tu hogar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6E756D)),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreateSpace,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear espacio'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF153A3A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


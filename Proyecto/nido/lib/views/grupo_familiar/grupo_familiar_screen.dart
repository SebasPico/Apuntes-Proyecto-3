import 'package:flutter/material.dart';

import '../../controllers/grupo_controller.dart';
import '../../controllers/sesion_state.dart';
import '../../models/grupo_familiar.dart';
import '../home/home_screen.dart';

class GrupoFamiliarScreen extends StatefulWidget {
  const GrupoFamiliarScreen({super.key});

  @override
  State<GrupoFamiliarScreen> createState() => _GrupoFamiliarScreenState();
}

class _GrupoFamiliarScreenState extends State<GrupoFamiliarScreen> {
  final _grupoController = GrupoController();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();

  bool _crearGrupo = true;
  bool _cargando = false;
  String? _errorGeneral;

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      setState(() => _errorGeneral = 'El nombre del grupo es obligatorio');
      return;
    }

    final usuario = SesionState.instancia.usuario;
    if (usuario == null) return;

    setState(() {
      _cargando = true;
      _errorGeneral = null;
    });
    try {
      final grupo = await _grupoController.crear(
        nombre: nombre,
        creadorId: usuario.id,
      );
      SesionState.instancia.establecerGrupo(grupo);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (error) {
      setState(() {
        _errorGeneral = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _unirse() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() => _errorGeneral = 'El código de acceso es obligatorio');
      return;
    }

    final usuario = SesionState.instancia.usuario;
    if (usuario == null) return;

    setState(() {
      _cargando = true;
      _errorGeneral = null;
    });
    try {
      final grupo = await _grupoController.unirse(
        codigo: codigo,
        usuarioId: usuario.id,
      );
      SesionState.instancia.establecerGrupo(grupo);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (error) {
      setState(() {
        _errorGeneral = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SesionState.instancia,
      builder: (context, _) {
        final grupo = SesionState.instancia.grupo;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: grupo != null
                      ? _GrupoDetalle(grupo: grupo)
                      : _GrupoFormulario(
                          crearGrupo: _crearGrupo,
                          onModoChanged: (value) =>
                              setState(() => _crearGrupo = value),
                          nombreController: _nombreController,
                          codigoController: _codigoController,
                          cargando: _cargando,
                          error: _errorGeneral,
                          onSubmit: _crearGrupo ? _crear : _unirse,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GrupoFormulario extends StatelessWidget {
  const _GrupoFormulario({
    required this.crearGrupo,
    required this.onModoChanged,
    required this.nombreController,
    required this.codigoController,
    required this.cargando,
    required this.error,
    required this.onSubmit,
  });

  final bool crearGrupo;
  final ValueChanged<bool> onModoChanged;
  final TextEditingController nombreController;
  final TextEditingController codigoController;
  final bool cargando;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 116,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFE8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.groups_rounded,
            size: 52,
            color: Color(0xFF4F7666),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Conecta tu hogar',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF153A3A),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea un grupo familiar o únete con el código que te compartieron.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6E756D),
          ),
        ),
        const SizedBox(height: 28),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('Crear grupo'),
              icon: Icon(Icons.add_home_rounded),
            ),
            ButtonSegment(
              value: false,
              label: Text('Unirme'),
              icon: Icon(Icons.login_rounded),
            ),
          ],
          selected: {crearGrupo},
          onSelectionChanged: (selection) => onModoChanged(selection.first),
        ),
        const SizedBox(height: 28),
        if (error != null) ...[
          _ErrorBanner(mensaje: error!),
          const SizedBox(height: 18),
        ],
        if (crearGrupo) ...[
          TextField(
            controller: nombreController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
              hintText: 'Ej. Familia Pico',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
          ),
          const SizedBox(height: 18),
          const _InfoBox(
            icon: Icons.auto_awesome_rounded,
            text:
                'Al crear el grupo recibirás un código único para compartirlo con tu hogar.',
          ),
        ] else ...[
          TextField(
            controller: codigoController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Código de acceso',
              hintText: 'Ej. NIDO-4821',
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: 18),
          const _InfoBox(
            icon: Icons.info_outline_rounded,
            text:
                'Pide el código a un integrante del grupo para vincularte al inventario.',
          ),
        ],
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: cargando ? null : onSubmit,
          icon: cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Icon(crearGrupo ? Icons.arrow_forward_rounded : Icons.login),
          label: Text(crearGrupo ? 'Crear grupo' : 'Unirme al grupo'),
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
    );
  }
}

class _GrupoDetalle extends StatefulWidget {
  const _GrupoDetalle({required this.grupo});

  final GrupoFamiliar grupo;

  @override
  State<_GrupoDetalle> createState() => _GrupoDetalleState();
}

class _GrupoDetalleState extends State<_GrupoDetalle> {
  bool _saliendo = false;

  Future<void> _confirmarSalida() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del grupo familiar'),
        content: const Text(
          'Perderás acceso al inventario de este grupo. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB65A43),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _saliendo = true);
    await SesionState.instancia.salirDeGrupo();
    // No hace falta navegar: SesionState notifica y esta misma pantalla
    // se reconstruye mostrando el formulario de crear/unirse (Pantalla 3).
    if (mounted) setState(() => _saliendo = false);
  }

  @override
  Widget build(BuildContext context) {
    final grupo = widget.grupo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFE8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.home_work_rounded,
                size: 44,
                color: Color(0xFF4F7666),
              ),
              const SizedBox(height: 12),
              Text(
                grupo.nombre,
                style: const TextStyle(
                  color: Color(0xFF153A3A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Código de acceso',
          style: TextStyle(
            color: Color(0xFF153A3A),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4DDD2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  grupo.codigoAcceso,
                  style: const TextStyle(
                    color: Color(0xFF153A3A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.copy_rounded, color: Color(0xFF6E756D)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: _saliendo ? null : _confirmarSalida,
          icon: const Icon(Icons.exit_to_app_rounded),
          label: const Text('Salir del grupo familiar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB65A43),
            minimumSize: const Size.fromHeight(54),
            side: const BorderSide(color: Color(0xFFB65A43)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB65A43)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Color(0xFF8C3F2E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE07A5F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF744D3E),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

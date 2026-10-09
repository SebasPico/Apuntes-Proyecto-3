import 'package:flutter/foundation.dart';

import '../models/grupo_familiar.dart';
import '../models/usuario.dart';
import '../services/notification_service.dart';
import 'auth_controller.dart';
import 'grupo_controller.dart';

/// Estado de la sesión activa (usuario y grupo), observable por las vistas.
class SesionState extends ChangeNotifier {
  SesionState({
    AuthController? authController,
    GrupoController? grupoController,
  }) : _authController = authController ?? AuthController(),
       _grupoController = grupoController ?? GrupoController();

  static final SesionState instancia = SesionState();

  final AuthController _authController;
  final GrupoController _grupoController;

  Usuario? usuario;
  GrupoFamiliar? grupo;

  /// Carga la sesión guardada (si existe) al abrir la app.
  Future<void> cargar() async {
    final usuarioId = _authController.currentUserId;
    if (usuarioId == null) return;

    usuario = await _authController.obtenerPorId(usuarioId);
    if (usuario == null) return;

    grupo = await _grupoController.obtenerGrupoDeUsuario(usuarioId);
    notifyListeners();
    await NotificationService.registerDevice(usuarioId);
  }

  Future<void> iniciarSesion(Usuario nuevoUsuario) async {
    usuario = nuevoUsuario;
    grupo = await _grupoController.obtenerGrupoDeUsuario(nuevoUsuario.id);
    notifyListeners();
    await NotificationService.registerDevice(nuevoUsuario.id);
  }

  void establecerGrupo(GrupoFamiliar nuevoGrupo) {
    grupo = nuevoGrupo;
    notifyListeners();
  }

  Future<void> salirDeGrupo() async {
    final usuarioActual = usuario;
    final grupoActual = grupo;
    if (usuarioActual == null || grupoActual == null) return;

    await _grupoController.salir(
      grupoId: grupoActual.id,
      usuarioId: usuarioActual.id,
    );
    grupo = null;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    final userId = usuario?.id;
    if (userId != null) {
      await NotificationService.unregisterDevice(userId);
    }
    await _authController.cerrarSesion();
    usuario = null;
    grupo = null;
    notifyListeners();
  }
}

import '../../models/grupo_familiar.dart';

abstract interface class GrupoRepository {
  Future<GrupoFamiliar> crear({
    required String nombre,
    required String creadorId,
  });

  Future<GrupoFamiliar> unirse({
    required String codigo,
    required String usuarioId,
  });

  Future<GrupoFamiliar?> obtenerGrupoDeUsuario(String usuarioId);

  Future<void> salir({required String grupoId, required String usuarioId});
}

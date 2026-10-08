import '../data/repositories/grupo_repository.dart';
import '../models/grupo_familiar.dart';

/// Controlador de grupos familiares: valida datos y coordina con el repositorio.
class GrupoController {
  GrupoController({GrupoRepository? repository})
    : _repository = repository ?? GrupoRepository();

  final GrupoRepository _repository;

  Future<GrupoFamiliar> crear({
    required String nombre,
    required String creadorId,
  }) {
    return _repository.crear(nombre: nombre, creadorId: creadorId);
  }

  Future<GrupoFamiliar> unirse({
    required String codigo,
    required String usuarioId,
  }) async {
    try {
      return await _repository.unirse(codigo: codigo, usuarioId: usuarioId);
    } on CodigoGrupoInvalidoException {
      throw Exception(
        'Código no válido, verifícalo con un integrante de tu hogar.',
      );
    }
  }

  Future<GrupoFamiliar?> obtenerGrupoDeUsuario(String usuarioId) {
    return _repository.obtenerGrupoDeUsuario(usuarioId);
  }

  Future<void> salir({required String grupoId, required String usuarioId}) {
    return _repository.salir(grupoId: grupoId, usuarioId: usuarioId);
  }
}

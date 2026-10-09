import '../data/repositories/grupo_repository.dart';
import '../domain/repositories/grupo_repository.dart' as domain;
import '../models/grupo_familiar.dart';

class GrupoController {
  GrupoController({domain.GrupoRepository? repository})
    : _repository = repository ?? FirebaseGrupoRepository();

  final domain.GrupoRepository _repository;

  Future<GrupoFamiliar> crear({
    required String nombre,
    required String creadorId,
  }) => _repository.crear(nombre: nombre, creadorId: creadorId);

  Future<GrupoFamiliar> unirse({
    required String codigo,
    required String usuarioId,
  }) => _repository.unirse(codigo: codigo, usuarioId: usuarioId);

  Future<GrupoFamiliar?> obtenerGrupoDeUsuario(String usuarioId) =>
      _repository.obtenerGrupoDeUsuario(usuarioId);

  Future<void> salir({required String grupoId, required String usuarioId}) =>
      _repository.salir(grupoId: grupoId, usuarioId: usuarioId);
}

import '../data/repositories/espacio_repository.dart';
import '../domain/repositories/espacio_repository.dart' as domain;
import '../models/espacio.dart';

class EspacioController {
  EspacioController({domain.EspacioRepository? repository})
    : _repository = repository ?? FirebaseEspacioRepository();

  final domain.EspacioRepository _repository;

  Future<Espacio> crear(Espacio espacio) => _repository.crear(espacio);

  Stream<List<Espacio>> observarPorGrupo(String grupoId) =>
      _repository.observarPorGrupo(grupoId);

  Future<List<Espacio>> listarPorGrupo(String grupoId) =>
      _repository.observarPorGrupo(grupoId).first;

  Future<Espacio?> obtenerPorId({
    required String grupoId,
    required String espacioId,
  }) => _repository.obtenerPorId(grupoId: grupoId, espacioId: espacioId);
}

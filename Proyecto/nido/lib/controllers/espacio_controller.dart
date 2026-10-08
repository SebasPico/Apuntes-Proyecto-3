import '../data/repositories/espacio_repository.dart';
import '../models/espacio.dart';

class EspacioController {
  EspacioController({EspacioRepository? repository})
    : _repository = repository ?? EspacioRepository();

  final EspacioRepository _repository;

  Future<void> crear(Espacio espacio) => _repository.crear(espacio);

  Future<List<Espacio>> listarPorGrupo(String grupoId) =>
      _repository.listarPorGrupo(grupoId);
}

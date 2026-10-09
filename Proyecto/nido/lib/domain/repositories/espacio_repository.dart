import '../../models/espacio.dart';

abstract interface class EspacioRepository {
  Future<Espacio> crear(Espacio espacio);

  Stream<List<Espacio>> observarPorGrupo(String grupoId);

  Future<Espacio?> obtenerPorId({
    required String grupoId,
    required String espacioId,
  });
}

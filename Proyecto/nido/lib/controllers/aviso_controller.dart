import '../data/repositories/aviso_repository.dart';
import '../domain/repositories/aviso_repository.dart' as domain;
import '../models/aviso_inventario.dart';

class AvisoController {
  AvisoController({domain.AvisoRepository? repository})
    : _repository = repository ?? FirebaseAvisoRepository();

  final domain.AvisoRepository _repository;

  Stream<List<AvisoInventario>> observarPorGrupo(String grupoId) =>
      _repository.observarPorGrupo(grupoId);

  Future<void> marcarLeida({
    required String grupoId,
    required String avisoId,
    required String usuarioId,
  }) => _repository.marcarLeida(
    grupoId: grupoId,
    avisoId: avisoId,
    usuarioId: usuarioId,
  );
}

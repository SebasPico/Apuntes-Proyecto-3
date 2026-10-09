import '../../models/aviso_inventario.dart';

abstract interface class AvisoRepository {
  Stream<List<AvisoInventario>> observarPorGrupo(String grupoId);

  Future<void> marcarLeida({
    required String grupoId,
    required String avisoId,
    required String usuarioId,
  });
}

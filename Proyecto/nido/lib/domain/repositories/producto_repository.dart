import '../../models/producto.dart';

abstract interface class ProductoRepository {
  Future<Producto> crear(Producto producto);

  Future<List<Producto>> listarPorEspacio({
    required String grupoId,
    required String espacioId,
  });

  Stream<List<Producto>> observarPorEspacio({
    required String grupoId,
    required String espacioId,
  });

  Future<void> actualizar(Producto producto);

  Future<void> ajustarCantidad({
    required Producto producto,
    required int cambio,
  });

  Future<void> eliminar(Producto producto);
}

import '../data/repositories/producto_repository.dart';
import '../domain/repositories/producto_repository.dart' as domain;
import '../models/producto.dart';

class ProductoController {
  ProductoController({domain.ProductoRepository? repository})
    : _repository = repository ?? FirebaseProductoRepository();

  final domain.ProductoRepository _repository;

  Future<Producto> crear(Producto producto) => _repository.crear(producto);

  Future<List<Producto>> listarPorEspacio({
    required String grupoId,
    required String espacioId,
  }) => _repository.listarPorEspacio(
    grupoId: grupoId,
    espacioId: espacioId,
  );

  Stream<List<Producto>> observarPorEspacio({
    required String grupoId,
    required String espacioId,
  }) => _repository.observarPorEspacio(
    grupoId: grupoId,
    espacioId: espacioId,
  );

  Future<void> actualizar(Producto producto) =>
      _repository.actualizar(producto);

  Future<void> ajustarCantidad({
    required Producto producto,
    required int cambio,
  }) => _repository.ajustarCantidad(producto: producto, cambio: cambio);

  Future<void> eliminar(Producto producto) => _repository.eliminar(producto);
}

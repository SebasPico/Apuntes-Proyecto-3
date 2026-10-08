import '../data/repositories/producto_repository.dart';
import '../models/producto.dart';

class ProductoController {
  ProductoController({ProductoRepository? repository})
      : _repository = repository ?? ProductoRepository();

  final ProductoRepository _repository;

  Future<void> crear(Producto producto) => _repository.crear(producto);

  Future<List<Producto>> listarPorGrupo(String grupoId) =>
      _repository.listarPorGrupo(grupoId);

  Future<void> actualizar(Producto producto) => _repository.actualizar(producto);

  Future<void> eliminar(String productoId) => _repository.eliminar(productoId);
}

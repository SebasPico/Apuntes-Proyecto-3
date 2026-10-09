import 'package:flutter_test/flutter_test.dart';
import 'package:nido/models/aviso_inventario.dart';
import 'package:nido/models/espacio.dart';
import 'package:nido/models/grupo_familiar.dart';
import 'package:nido/models/producto.dart';
import 'package:nido/models/usuario.dart';

void main() {
  test('user profile serializes without credential data', () {
    final user = Usuario(
      id: 'uid-1',
      nombreCompleto: 'Ana Pérez',
      email: 'ana@example.com',
    );

    expect(user.toMap(), {
      'nombreCompleto': 'Ana Pérez',
      'email': 'ana@example.com',
      'createdAt': null,
    });
  });

  test('group round-trip keeps membership and invitation code', () {
    final group = GrupoFamiliar(
      id: 'group-1',
      nombre: 'Familia',
      codigoAcceso: 'NIDO-ABCD1234',
      integrantesIds: ['uid-1'],
      creadorId: 'uid-1',
    );

    final restored = GrupoFamiliar.fromMap(group.id, group.toMap());

    expect(restored.nombre, group.nombre);
    expect(restored.codigoAcceso, group.codigoAcceso);
    expect(restored.integrantesIds, group.integrantesIds);
  });

  test('space round-trip stores a stable icon key', () {
    final space = Espacio(
      id: 'space-1',
      nombre: 'Cocina',
      colorValue: 0xFFE07A5F,
      iconKey: 'kitchen',
      grupoId: 'group-1',
    );

    final restored = Espacio.fromMap(space.id, space.toMap());

    expect(restored.iconKey, 'kitchen');
    expect(restored.grupoId, 'group-1');
  });

  test('product status is derived from current stock and minimum', () {
    final product = Producto(
      id: 'product-1',
      nombre: 'Arroz',
      categoria: 'Alimentos',
      cantidad: 2,
      cantidadMinima: 2,
      unidad: 'Kg',
      prioridad: 'Media',
      grupoId: 'group-1',
      espacioId: 'space-1',
      creadoPor: 'uid-1',
    );

    expect(product.estado, 'Por revisar');
    expect(product.copyWith(cantidad: 3).estado, 'Disponible');
    expect(product.toMap().containsKey('passwordHash'), isFalse);
  });

  test('inventory alert retains product details and read state', () {
    final alert = AvisoInventario.fromMap('alert-1', {
      'grupoId': 'group-1',
      'espacioId': 'space-1',
      'productoId': 'product-1',
      'nombreProducto': 'Arroz',
      'nombreEspacio': 'Cocina',
      'tipo': 'minimo',
      'cantidad': 2,
      'cantidadMinima': 2,
      'usuarioId': 'uid-1',
      'leidaPor': ['uid-2'],
      'createdAt': '2026-04-14T10:30:00.000Z',
    });

    expect(alert.id, 'alert-1');
    expect(alert.nombreProducto, 'Arroz');
    expect(alert.cantidad, 2);
    expect(alert.leidaPorUsuario('uid-2'), isTrue);
    expect(alert.leidaPorUsuario('uid-3'), isFalse);
    expect(alert.fecha, DateTime.utc(2026, 4, 14, 10, 30));
  });
}

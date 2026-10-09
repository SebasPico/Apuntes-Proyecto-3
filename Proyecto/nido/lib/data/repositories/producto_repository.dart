import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/producto_repository.dart' as domain;
import '../../models/producto.dart';

class FirebaseProductoRepository implements domain.ProductoRepository {
  FirebaseProductoRepository({FirebaseFirestore? firestore})
    : _providedFirestore = firestore;

  final FirebaseFirestore? _providedFirestore;
  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _products({
    required String groupId,
    required String spaceId,
  }) => _firestore
      .collection('groups')
      .doc(groupId)
      .collection('spaces')
      .doc(spaceId)
      .collection('products');

  @override
  Future<Producto> crear(Producto producto) async {
    final reference = _products(
      groupId: producto.grupoId,
      spaceId: producto.espacioId,
    ).doc();
    final saved = producto.copyWith(id: reference.id);
    await reference.set({
      ...saved.toMap(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
    return saved;
  }

  @override
  Future<List<Producto>> listarPorEspacio({
    required String grupoId,
    required String espacioId,
  }) async {
    final snapshot = await _products(
      groupId: grupoId,
      spaceId: espacioId,
    ).orderBy('nombre').get();
    return snapshot.docs
        .map(
          (doc) => Producto.fromMap(
            doc.id,
            _withDate(doc.data(), 'fechaActualizacion'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Stream<List<Producto>> observarPorEspacio({
    required String grupoId,
    required String espacioId,
  }) => _products(groupId: grupoId, spaceId: espacioId)
      .orderBy('nombre')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Producto.fromMap(
                doc.id,
                _withDate(doc.data(), 'fechaActualizacion'),
              ),
            )
            .toList(growable: false),
      );

  @override
  Future<void> actualizar(Producto producto) async {
    final reference = _products(
      groupId: producto.grupoId,
      spaceId: producto.espacioId,
    ).doc(producto.id);
    await reference.update({
      ...producto.toMap(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> ajustarCantidad({
    required Producto producto,
    required int cambio,
  }) async {
    if (cambio == 0) return;
    final reference = _products(
      groupId: producto.grupoId,
      spaceId: producto.espacioId,
    ).doc(producto.id);
    await reference.update({
      'cantidad': FieldValue.increment(cambio),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> eliminar(Producto producto) => _products(
    groupId: producto.grupoId,
    spaceId: producto.espacioId,
  ).doc(producto.id).delete();

  Map<String, dynamic> _withDate(Map<String, dynamic> data, String field) {
    final value = data[field];
    return {...data, if (value is Timestamp) field: value.toDate()};
  }
}

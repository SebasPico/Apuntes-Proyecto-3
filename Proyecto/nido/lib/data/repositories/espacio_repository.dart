import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/espacio_repository.dart' as domain;
import '../../models/espacio.dart';

class FirebaseEspacioRepository implements domain.EspacioRepository {
  FirebaseEspacioRepository({FirebaseFirestore? firestore})
    : _providedFirestore = firestore;

  final FirebaseFirestore? _providedFirestore;
  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _spaces(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('spaces');

  @override
  Future<Espacio> crear(Espacio espacio) async {
    final reference = espacio.id.isEmpty
        ? _spaces(espacio.grupoId).doc()
        : _spaces(espacio.grupoId).doc(espacio.id);
    final saved = espacio.copyWith(id: reference.id);
    await reference.set({
      ...saved.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return saved;
  }

  @override
  Stream<List<Espacio>> observarPorGrupo(String grupoId) =>
      _spaces(grupoId).orderBy('nombre').snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Espacio.fromMap(
                doc.id,
                _withDate(doc.data(), 'createdAt'),
              ),
            )
            .toList(growable: false),
      );

  @override
  Future<Espacio?> obtenerPorId({
    required String grupoId,
    required String espacioId,
  }) async {
    final snapshot = await _spaces(grupoId).doc(espacioId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return Espacio.fromMap(
      snapshot.id,
      _withDate(data, 'createdAt'),
    );
  }

  Map<String, dynamic> _withDate(
    Map<String, dynamic> data,
    String field,
  ) {
    final value = data[field];
    return {
      ...data,
      if (value is Timestamp) field: value.toDate(),
    };
  }
}

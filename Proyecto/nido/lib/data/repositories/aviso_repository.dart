import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/aviso_repository.dart' as domain;
import '../../models/aviso_inventario.dart';

class FirebaseAvisoRepository implements domain.AvisoRepository {
  FirebaseAvisoRepository({FirebaseFirestore? firestore})
    : _providedFirestore = firestore;

  final FirebaseFirestore? _providedFirestore;
  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notificaciones(String grupoId) =>
      _firestore
          .collection('groups')
          .doc(grupoId)
          .collection('notifications');

  @override
  Stream<List<AvisoInventario>> observarPorGrupo(String grupoId) =>
      _notificaciones(grupoId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  final createdAt = data['createdAt'];
                  return AvisoInventario.fromMap(doc.id, {
                    ...data,
                    if (createdAt is Timestamp)
                      'createdAt': createdAt.toDate(),
                  });
                })
                .toList(growable: false),
          );

  @override
  Future<void> marcarLeida({
    required String grupoId,
    required String avisoId,
    required String usuarioId,
  }) => _notificaciones(grupoId).doc(avisoId).update({
    'leidaPor': FieldValue.arrayUnion([usuarioId]),
  });
}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/grupo_repository.dart' as domain;
import '../../models/grupo_familiar.dart';

class CodigoGrupoInvalidoException implements Exception {}

class FirebaseGrupoRepository implements domain.GrupoRepository {
  FirebaseGrupoRepository({FirebaseFirestore? firestore})
    : _providedFirestore = firestore;

  final FirebaseFirestore? _providedFirestore;
  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get _codes =>
      _firestore.collection('group_codes');

  @override
  Future<GrupoFamiliar> crear({
    required String nombre,
    required String creadorId,
  }) async {
    final groupRef = _groups.doc();
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generarCodigo();
      final codeRef = _codes.doc(code);
      final group = GrupoFamiliar(
        id: groupRef.id,
        nombre: nombre.trim(),
        codigoAcceso: code,
        integrantesIds: [creadorId],
        creadorId: creadorId,
        createdAt: DateTime.now(),
      );

      final created = await _firestore.runTransaction((transaction) async {
        final existingCode = await transaction.get(codeRef);
        if (existingCode.exists) return false;
        transaction.set(groupRef, {
          ...group.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.set(codeRef, {'grupoId': groupRef.id});
        return true;
      });
      if (created) return group;
    }
    throw StateError('No fue posible generar un código de grupo único.');
  }

  @override
  Future<GrupoFamiliar> unirse({
    required String codigo,
    required String usuarioId,
  }) async {
    final codigoNormalizado = codigo.trim().toUpperCase();
    final codeSnapshot = await _codes.doc(codigoNormalizado).get();
    final groupId = codeSnapshot.data()?['grupoId'] as String?;
    if (!codeSnapshot.exists || groupId == null) {
      throw CodigoGrupoInvalidoException();
    }

    final groupRef = _groups.doc(groupId);
    final joinRef = groupRef.collection('join_requests').doc(usuarioId);
    final batch = _firestore.batch();
    batch.set(joinRef, {'codigoAcceso': codigoNormalizado});
    batch.update(groupRef, {
      'integrantesIds': FieldValue.arrayUnion([usuarioId]),
    });
    await batch.commit();

    final joined = await groupRef.get();
    final data = joined.data();
    if (!joined.exists || data == null) {
      throw StateError('El grupo dejó de existir durante la unión.');
    }
    return GrupoFamiliar.fromMap(groupId, _withDate(data, 'createdAt'));
  }

  @override
  Future<GrupoFamiliar?> obtenerGrupoDeUsuario(String usuarioId) async {
    final groups = await _groups
        .where('integrantesIds', arrayContains: usuarioId)
        .limit(1)
        .get();
    if (groups.docs.isEmpty) return null;
    final doc = groups.docs.first;
    return GrupoFamiliar.fromMap(
      doc.id,
      _withDate(doc.data(), 'createdAt'),
    );
  }

  @override
  Future<void> salir({
    required String grupoId,
    required String usuarioId,
  }) async {
    await _groups.doc(grupoId).update({
      'integrantesIds': FieldValue.arrayRemove([usuarioId]),
    });
  }

  String _generarCodigo() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final suffix = List.generate(
      8,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    return 'NIDO-$suffix';
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/repositories/auth_repository.dart' as domain;
import '../../models/usuario.dart';

class FirebaseAuthRepository implements domain.AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _providedAuth = auth,
       _providedFirestore = firestore;

  final firebase_auth.FirebaseAuth? _providedAuth;
  final FirebaseFirestore? _providedFirestore;
  firebase_auth.FirebaseAuth get _auth =>
      _providedAuth ?? firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<Usuario> registrar({
    required String nombreCompleto,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('Firebase Authentication no devolvió un usuario.');
      }
      final profile = Usuario(
        id: user.uid,
        nombreCompleto: nombreCompleto.trim(),
        email: user.email ?? email.trim().toLowerCase(),
        createdAt: DateTime.now(),
      );
      await _users.doc(user.uid).set({
        ...profile.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return profile;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _authError(error);
    }
  }

  @override
  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('Firebase Authentication no devolvió un usuario.');
      }
      final snapshot = await _users.doc(user.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        return Usuario.fromMap(
          user.uid,
          _withDate(snapshot.data()!, 'createdAt'),
        );
      }

      final profile = Usuario(
        id: user.uid,
        nombreCompleto: user.displayName ?? '',
        email: user.email ?? email.trim().toLowerCase(),
        createdAt: DateTime.now(),
      );
      await _users.doc(user.uid).set({
        ...profile.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return profile;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _authError(error);
    }
  }

  @override
  Future<Usuario?> obtenerPorId(String id) async {
    final snapshot = await _users.doc(id).get();
    final data = snapshot.data();
    if (snapshot.exists && data != null) {
      return Usuario.fromMap(id, _withDate(data, 'createdAt'));
    }

    final user = _auth.currentUser;
    if (user == null || user.uid != id) return null;
    final email = user.email ?? '';
    final profile = Usuario(
      id: id,
      nombreCompleto: user.displayName ?? email.split('@').first,
      email: email,
      createdAt: DateTime.now(),
    );
    await _users.doc(id).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return profile;
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();

  Exception _authError(firebase_auth.FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => Exception(
        'Este correo ya está registrado, inicia sesión.',
      ),
      'invalid-email' => Exception('El correo electrónico no es válido.'),
      'weak-password' => Exception(
        'La contraseña no cumple los requisitos de seguridad.',
      ),
      'user-not-found' || 'wrong-password' || 'invalid-credential' => Exception(
        'Correo o contraseña incorrectos.',
      ),
      'network-request-failed' => Exception(
        'No se pudo conectar. Revisa tu conexión a internet.',
      ),
      _ => Exception('No se pudo completar la autenticación (${error.code}).'),
    };
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

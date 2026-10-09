import '../data/repositories/auth_repository.dart';
import '../domain/repositories/auth_repository.dart' as domain;
import '../models/usuario.dart';

class AuthController {
  AuthController({domain.AuthRepository? repository})
    : _repository = repository ?? FirebaseAuthRepository();

  final domain.AuthRepository _repository;

  String? get currentUserId => _repository.currentUserId;

  Future<Usuario> registrar({
    required String nombreCompleto,
    required String email,
    required String password,
  }) => _repository.registrar(
    nombreCompleto: nombreCompleto,
    email: email,
    password: password,
  );

  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  }) => _repository.iniciarSesion(email: email, password: password);

  Future<Usuario?> obtenerPorId(String id) => _repository.obtenerPorId(id);

  Future<void> cerrarSesion() => _repository.cerrarSesion();
}

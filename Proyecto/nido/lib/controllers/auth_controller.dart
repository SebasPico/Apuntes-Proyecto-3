import '../data/repositories/auth_repository.dart';
import '../models/usuario.dart';

/// Controlador de autenticación: valida datos y coordina con el repositorio.
class AuthController {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  Future<Usuario> registrar({
    required String nombreCompleto,
    required String email,
    required String password,
  }) async {
    try {
      return await _repository.crearUsuario(
        nombreCompleto: nombreCompleto,
        email: email,
        password: password,
      );
    } on EmailYaRegistradoException {
      throw Exception('Este correo ya está registrado, inicia sesión.');
    }
  }

  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      return await _repository.validarCredenciales(
        email: email,
        password: password,
      );
    } on CredencialesInvalidasException {
      throw Exception('Correo o contraseña incorrectos');
    }
  }

  Future<Usuario?> obtenerPorId(String id) {
    return _repository.obtenerPorId(id);
  }
}

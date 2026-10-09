import '../../models/usuario.dart';

abstract interface class AuthRepository {
  String? get currentUserId;

  Future<Usuario> registrar({
    required String nombreCompleto,
    required String email,
    required String password,
  });

  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  });

  Future<Usuario?> obtenerPorId(String id);

  Future<void> cerrarSesion();
}

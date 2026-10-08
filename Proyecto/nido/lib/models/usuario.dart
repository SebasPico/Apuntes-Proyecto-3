/// Representa un usuario registrado en la app.
class Usuario {
  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.passwordHash,
  });

  final String id;
  final String nombreCompleto;
  final String email;
  final String passwordHash;

  Map<String, Object?> toRow() => {
    'id': id,
    'nombreCompleto': nombreCompleto,
    'email': email,
    'passwordHash': passwordHash,
  };

  factory Usuario.fromRow(Map<String, Object?> fila) => Usuario(
    id: fila['id'] as String,
    nombreCompleto: fila['nombreCompleto'] as String,
    email: fila['email'] as String,
    passwordHash: fila['passwordHash'] as String,
  );
}

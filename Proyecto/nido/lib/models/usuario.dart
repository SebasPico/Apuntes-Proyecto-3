/// Usuario autenticado por Firebase Authentication.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.createdAt,
  });

  final String id;
  final String nombreCompleto;
  final String email;
  final DateTime? createdAt;

  Map<String, Object?> toMap() => {
    'nombreCompleto': nombreCompleto,
    'email': email,
    'createdAt': createdAt,
  };

  factory Usuario.fromMap(String id, Map<String, dynamic> map) => Usuario(
    id: id,
    nombreCompleto: map['nombreCompleto'] as String? ?? '',
    email: map['email'] as String? ?? '',
    createdAt: _dateFromMap(map['createdAt']),
  );
}

DateTime? _dateFromMap(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

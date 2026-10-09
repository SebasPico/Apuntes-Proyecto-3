/// Representa un grupo familiar almacenado en Firestore.
class GrupoFamiliar {
  const GrupoFamiliar({
    required this.id,
    required this.nombre,
    required this.codigoAcceso,
    required this.integrantesIds,
    required this.creadorId,
    this.createdAt,
  });

  final String id;
  final String nombre;
  final String codigoAcceso;
  final List<String> integrantesIds;
  final String creadorId;
  final DateTime? createdAt;

  GrupoFamiliar copyWith({List<String>? integrantesIds}) => GrupoFamiliar(
    id: id,
    nombre: nombre,
    codigoAcceso: codigoAcceso,
    integrantesIds: integrantesIds ?? this.integrantesIds,
    creadorId: creadorId,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'codigoAcceso': codigoAcceso,
    'integrantesIds': integrantesIds,
    'creadorId': creadorId,
    'createdAt': createdAt,
  };

  factory GrupoFamiliar.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return GrupoFamiliar(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      codigoAcceso: map['codigoAcceso'] as String? ?? '',
      integrantesIds: List<String>.from(
        map['integrantesIds'] as List<dynamic>? ?? const [],
      ),
      creadorId: map['creadorId'] as String? ?? '',
      createdAt: createdAt is DateTime
          ? createdAt
          : createdAt is String
          ? DateTime.tryParse(createdAt)
          : null,
    );
  }
}

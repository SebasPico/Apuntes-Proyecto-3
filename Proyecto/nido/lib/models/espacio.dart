class Espacio {
  const Espacio({
    this.id = '',
    required this.nombre,
    required this.colorValue,
    required this.iconKey,
    required this.grupoId,
    this.createdAt,
  });

  final String id;
  final String nombre;
  final int colorValue;
  final String iconKey;
  final String grupoId;
  final DateTime? createdAt;

  Espacio copyWith({String? id}) => Espacio(
    id: id ?? this.id,
    nombre: nombre,
    colorValue: colorValue,
    iconKey: iconKey,
    grupoId: grupoId,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'colorValue': colorValue,
    'iconKey': iconKey,
    'grupoId': grupoId,
    'createdAt': createdAt,
  };

  factory Espacio.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return Espacio(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0,
      iconKey: map['iconKey'] as String? ?? 'home',
      grupoId: map['grupoId'] as String? ?? '',
      createdAt: createdAt is DateTime
          ? createdAt
          : createdAt is String
          ? DateTime.tryParse(createdAt)
          : null,
    );
  }
}

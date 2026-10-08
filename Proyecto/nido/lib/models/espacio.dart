class Espacio {
  const Espacio({
    required this.id,
    required this.nombre,
    required this.colorValue,
    required this.iconCodePoint,
    required this.grupoId,
  });

  final String id;
  final String nombre;
  final int colorValue;
  final int iconCodePoint;
  final String grupoId;

  Map<String, Object?> toRow() => {
    'id': id,
    'nombre': nombre,
    'colorValue': colorValue,
    'iconCodePoint': iconCodePoint,
    'grupoId': grupoId,
  };

  factory Espacio.fromRow(Map<String, Object?> row) => Espacio(
    id: row['id'] as String,
    nombre: row['nombre'] as String,
    colorValue: row['colorValue'] as int,
    iconCodePoint: row['iconCodePoint'] as int,
    grupoId: row['grupoId'] as String,
  );
}

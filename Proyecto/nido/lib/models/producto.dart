class Producto {
  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.cantidadMinima,
    required this.unidad,
    required this.prioridad,
    required this.grupoId,
    required this.espacioId,
    required this.creadoPor,
    DateTime? fechaActualizacion,
  }) : fechaActualizacion = fechaActualizacion ?? DateTime.now();

  final String id;
  final String nombre;
  final String categoria;
  final int cantidad;
  final int cantidadMinima;
  final String unidad;
  final String prioridad;
  final String grupoId;
  final String espacioId;
  final String creadoPor;
  final DateTime fechaActualizacion;

  String get estado =>
      cantidad <= cantidadMinima ? 'Por revisar' : 'Disponible';

  Producto copyWith({
    String? id,
    String? nombre,
    String? categoria,
    int? cantidad,
    int? cantidadMinima,
    String? unidad,
    String? prioridad,
    String? grupoId,
    String? espacioId,
    String? creadoPor,
    DateTime? fechaActualizacion,
  }) => Producto(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    categoria: categoria ?? this.categoria,
    cantidad: cantidad ?? this.cantidad,
    cantidadMinima: cantidadMinima ?? this.cantidadMinima,
    unidad: unidad ?? this.unidad,
    prioridad: prioridad ?? this.prioridad,
    grupoId: grupoId ?? this.grupoId,
    espacioId: espacioId ?? this.espacioId,
    creadoPor: creadoPor ?? this.creadoPor,
    fechaActualizacion: fechaActualizacion ?? DateTime.now(),
  );

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'categoria': categoria,
    'cantidad': cantidad,
    'cantidadMinima': cantidadMinima,
    'unidad': unidad,
    'prioridad': prioridad,
    'grupoId': grupoId,
    'espacioId': espacioId,
    'creadoPor': creadoPor,
    'fechaActualizacion': fechaActualizacion,
  };

  factory Producto.fromMap(String id, Map<String, dynamic> map) {
    final updatedAt = map['fechaActualizacion'];
    return Producto(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      categoria: map['categoria'] as String? ?? 'General',
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 0,
      cantidadMinima: (map['cantidadMinima'] as num?)?.toInt() ?? 0,
      unidad: map['unidad'] as String? ?? 'Unidades',
      prioridad: map['prioridad'] as String? ?? 'Media',
      grupoId: map['grupoId'] as String? ?? '',
      espacioId: map['espacioId'] as String? ?? '',
      creadoPor: map['creadoPor'] as String? ?? '',
      fechaActualizacion: updatedAt is DateTime
          ? updatedAt
          : updatedAt is String
          ? DateTime.tryParse(updatedAt) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

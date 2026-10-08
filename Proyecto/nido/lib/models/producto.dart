class Producto {
  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.cantidadMinima,
    required this.unidad,
    required this.prioridad,
    required this.estado,
    required this.grupoId,
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
  final String estado;
  final String grupoId;
  final String creadoPor;
  final DateTime fechaActualizacion;

  Producto copyWith({
    String? id,
    String? nombre,
    String? categoria,
    int? cantidad,
    int? cantidadMinima,
    String? unidad,
    String? prioridad,
    String? estado,
    String? grupoId,
    String? creadoPor,
    DateTime? fechaActualizacion,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      unidad: unidad ?? this.unidad,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      grupoId: grupoId ?? this.grupoId,
      creadoPor: creadoPor ?? this.creadoPor,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  Map<String, Object?> toRow() => {
    'id': id,
    'nombre': nombre,
    'categoria': categoria,
    'cantidad': cantidad,
    'cantidadMinima': cantidadMinima,
    'unidad': unidad,
    'prioridad': prioridad,
    'estado': estado,
    'grupoId': grupoId,
    'creadoPor': creadoPor,
    'fechaActualizacion': fechaActualizacion.toIso8601String(),
  };

  factory Producto.fromRow(Map<String, Object?> row) {
    return Producto(
      id: row['id'] as String? ?? '',
      nombre: row['nombre'] as String? ?? '',
      categoria: row['categoria'] as String? ?? 'General',
      cantidad: row['cantidad'] as int? ?? 0,
      cantidadMinima: row['cantidadMinima'] as int? ?? 0,
      unidad: row['unidad'] as String? ?? 'Unidades',
      prioridad: row['prioridad'] as String? ?? 'Media',
      estado: row['estado'] as String? ?? 'Disponible',
      grupoId: row['grupoId'] as String? ?? '',
      creadoPor: row['creadoPor'] as String? ?? '',
      fechaActualizacion: row['fechaActualizacion'] != null
          ? DateTime.parse(row['fechaActualizacion'] as String)
          : DateTime.now(),
    );
  }
}

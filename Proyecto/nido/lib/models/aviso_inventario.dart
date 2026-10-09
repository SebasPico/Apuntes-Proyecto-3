class AvisoInventario {
  const AvisoInventario({
    required this.id,
    required this.grupoId,
    required this.espacioId,
    required this.productoId,
    required this.nombreProducto,
    required this.nombreEspacio,
    required this.tipo,
    required this.cantidad,
    required this.cantidadMinima,
    required this.usuarioId,
    required this.leidaPor,
    required this.fecha,
  });

  final String id;
  final String grupoId;
  final String espacioId;
  final String productoId;
  final String nombreProducto;
  final String nombreEspacio;
  final String tipo;
  final int cantidad;
  final int cantidadMinima;
  final String usuarioId;
  final List<String> leidaPor;
  final DateTime? fecha;

  bool leidaPorUsuario(String uid) => leidaPor.contains(uid);

  factory AvisoInventario.fromMap(String id, Map<String, dynamic> map) {
    final fecha = map['createdAt'];
    return AvisoInventario(
      id: id,
      grupoId: map['grupoId'] as String? ?? '',
      espacioId: map['espacioId'] as String? ?? '',
      productoId: map['productoId'] as String? ?? '',
      nombreProducto: map['nombreProducto'] as String? ?? 'Producto',
      nombreEspacio: map['nombreEspacio'] as String? ?? 'Espacio',
      tipo: map['tipo'] as String? ?? 'minimo',
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 0,
      cantidadMinima: (map['cantidadMinima'] as num?)?.toInt() ?? 0,
      usuarioId: map['usuarioId'] as String? ?? '',
      leidaPor: List<String>.from(
        map['leidaPor'] as List<dynamic>? ?? const [],
      ),
      fecha: fecha is DateTime
          ? fecha
          : fecha is String
          ? DateTime.tryParse(fecha)
          : null,
    );
  }
}

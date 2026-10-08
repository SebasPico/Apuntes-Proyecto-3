import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoModel {
  const ProductoModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.unidad,
    required this.grupoId,
    required this.creadoPor,
    this.updatedAt,
  });

  final String id;
  final String nombre;
  final String categoria;
  final int cantidad;
  final String unidad;
  final String grupoId;
  final String creadoPor;
  final DateTime? updatedAt;

  factory ProductoModel.fromMap(Map<String, dynamic> map) {
    final updatedAtValue = map['updatedAt'];

    return ProductoModel(
      id: map['id'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      categoria: map['categoria'] as String? ?? '',
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 0,
      unidad: map['unidad'] as String? ?? 'Unidades',
      grupoId: map['grupoId'] as String? ?? '',
      creadoPor: map['creadoPor'] as String? ?? '',
      updatedAt: updatedAtValue == null
          ? null
          : (updatedAtValue is Timestamp
                  ? updatedAtValue
                  : Timestamp.fromDate(DateTime.parse(updatedAtValue.toString())))
              .toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'unidad': unidad,
      'grupoId': grupoId,
      'creadoPor': creadoPor,
      'updatedAt': updatedAt,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class GrupoModel {
  const GrupoModel({
    required this.id,
    required this.nombre,
    required this.adminId,
    required this.miembros,
    this.createdAt,
  });

  final String id;
  final String nombre;
  final String adminId;
  final List<String> miembros;
  final DateTime? createdAt;

  factory GrupoModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    return GrupoModel(
      id: map['id'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      adminId: map['adminId'] as String? ?? '',
      miembros: List<String>.from(map['miembros'] ?? const <String>[]),
      createdAt: createdAtValue == null
          ? null
          : (createdAtValue is Timestamp
                  ? createdAtValue
                  : Timestamp.fromDate(DateTime.parse(createdAtValue.toString())))
              .toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'adminId': adminId,
      'miembros': miembros,
      'createdAt': createdAt,
    };
  }
}

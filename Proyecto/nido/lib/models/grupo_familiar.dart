import 'dart:convert';

/// Representa un grupo familiar y sus integrantes.
class GrupoFamiliar {
  GrupoFamiliar({
    required this.id,
    required this.nombre,
    required this.codigoAcceso,
    required this.integrantesIds,
  });

  final String id;
  final String nombre;
  final String codigoAcceso;
  final List<String> integrantesIds;

  GrupoFamiliar copyWith({List<String>? integrantesIds}) => GrupoFamiliar(
    id: id,
    nombre: nombre,
    codigoAcceso: codigoAcceso,
    integrantesIds: integrantesIds ?? this.integrantesIds,
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'nombre': nombre,
    'codigoAcceso': codigoAcceso,
    'integrantesIds': jsonEncode(integrantesIds),
  };

  factory GrupoFamiliar.fromRow(Map<String, Object?> fila) => GrupoFamiliar(
    id: fila['id'] as String,
    nombre: fila['nombre'] as String,
    codigoAcceso: fila['codigoAcceso'] as String,
    integrantesIds: (jsonDecode(fila['integrantesIds'] as String) as List)
        .cast<String>(),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    this.grupoId,
    this.createdAt,
  });

  final String uid;
  final String nombre;
  final String email;
  final String? grupoId;
  final DateTime? createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    return UserModel(
      uid: map['uid'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      email: map['email'] as String? ?? '',
      grupoId: map['grupoId'] as String?,
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
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'grupoId': grupoId,
      'createdAt': createdAt,
    };
  }
}

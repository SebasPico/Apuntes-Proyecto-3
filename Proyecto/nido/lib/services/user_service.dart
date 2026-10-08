import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;

    final data = snapshot.data()!;
    return UserModel.fromMap({...data, 'uid': uid});
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  Future<void> updateGrupoId(String uid, String? grupoId) async {
    await _users.doc(uid).update({'grupoId': grupoId});
  }
}

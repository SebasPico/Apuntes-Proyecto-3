import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConnectionTest {
  const FirebaseConnectionTest._();

  static Future<String> writeTestDocument() async {
    final reference = await FirebaseFirestore.instance.collection('test').add({
      'hola': 'mundo',
      'plataforma': 'android',
      'fecha': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }
}

import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../controllers/espacio_controller.dart';
import '../controllers/sesion_state.dart';
import '../models/espacio.dart';
import '../navigation/app_navigator.dart';
import '../views/inventario/inventario_screen.dart';

class NotificationService {
  NotificationService._();

  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static Map<String, dynamic>? _pendingData;
  static String? _registeredUid;
  static StreamSubscription<String>? _tokenSubscription;

  static const _channel = AndroidNotificationChannel(
    'nido_alertas',
    'Alertas de inventario',
    description: 'Avisos cuando un producto llega a su mínimo o se agota.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _openOrQueue(data);
        } on FormatException catch (error) {
          debugPrint('Payload de notificación inválido: $error');
        }
      },
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _openOrQueue(message.data),
    );
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _pendingData = initialMessage.data;

    _initialized = true;
  }

  static Future<void> registerDevice(String uid) async {
    if (kIsWeb) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (permission.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('El usuario denegó las notificaciones push.');
        return;
      }

      final token = await messaging.getToken();
      if (token != null) await _saveToken(uid, token);
      _registeredUid = uid;
      await _tokenSubscription?.cancel();
      _tokenSubscription = messaging.onTokenRefresh.listen(
        (newToken) async {
          final currentUid = _registeredUid;
          if (currentUid == null) return;
          try {
            await _saveToken(currentUid, newToken);
          } on FirebaseException catch (error) {
            debugPrint(
              'No se pudo actualizar el token de notificaciones: $error',
            );
          }
        },
        onError: (Object error) {
          debugPrint('Error al renovar el token de notificaciones: $error');
        },
      );
    } on FirebaseException catch (error) {
      debugPrint('No se pudo registrar el dispositivo para avisos: $error');
    } on PlatformException catch (error) {
      debugPrint('No se pudo activar el servicio de avisos: $error');
    }
  }

  static Future<void> unregisterDevice(String uid) async {
    if (kIsWeb) return;
    if (_registeredUid == uid) {
      await _tokenSubscription?.cancel();
      _tokenSubscription = null;
      _registeredUid = null;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('devices')
            .doc(token)
            .delete();
      }
    } on FirebaseException catch (error) {
      debugPrint('No se pudo quitar el token de notificaciones: $error');
    } on PlatformException catch (error) {
      debugPrint(
        'No se pudo acceder al servicio de avisos al cerrar sesión: $error',
      );
    }
  }

  static Future<void> openPending() async {
    final data = _pendingData;
    if (data == null || SesionState.instancia.usuario == null) return;
    _pendingData = null;
    await _openOrQueue(data);
  }

  static Future<void> _saveToken(String uid, String token) => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('devices')
      .doc(token)
      .set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nido_alertas',
          'Alertas de inventario',
          channelDescription:
              'Avisos cuando un producto llega a su mínimo o se agota.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> _openOrQueue(Map<String, dynamic> data) async {
    final navigator = appNavigatorKey.currentState;
    final user = SesionState.instancia.usuario;
    final group = SesionState.instancia.grupo;
    if (navigator == null || user == null || group == null) {
      _pendingData = data;
      return;
    }

    final groupId = data['grupoId']?.toString();
    final spaceId = data['espacioId']?.toString();
    final productId = data['productoId']?.toString();
    if (groupId == null ||
        groupId != group.id ||
        spaceId == null ||
        productId == null) {
      ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
        const SnackBar(
          content: Text('El aviso no corresponde al grupo familiar actual.'),
        ),
      );
      return;
    }

    final Espacio? space;
    try {
      space = await EspacioController().obtenerPorId(
        grupoId: groupId,
        espacioId: spaceId,
      );
    } on FirebaseException catch (error) {
      debugPrint('No se pudo cargar el espacio del aviso: $error');
      if (navigator.mounted) {
        ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar el espacio de este aviso.'),
          ),
        );
      }
      return;
    }
    if (!navigator.mounted) return;
    final resolvedSpace = space;
    if (resolvedSpace == null) {
      ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
        const SnackBar(content: Text('El espacio de este aviso ya no existe.')),
      );
      return;
    }
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => InventarioScreen(
          espacio: resolvedSpace,
          productoIdInicial: productId,
        ),
      ),
    );
  }
}

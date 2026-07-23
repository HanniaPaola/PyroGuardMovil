import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../../features/brigadista/domain/entities/push_alert.dart';
import '../network/api_client.dart';

/// Servicio de notificaciones push geolocalizadas (HU02).
class PushNotificationService {
  final ApiClient apiClient;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PushNotificationService({required this.apiClient});

  final _alertController = StreamController<PushAlert>.broadcast();
  Stream<PushAlert> get onAlertReceived => _alertController.stream;

  final _interventionController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get onInterventionAssigned =>
      _interventionController.stream;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotificationsPlugin.initialize(settings: initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> registerToken(String userToken) async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _sendTokenToBackend(fcmToken, userToken);
      }

      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken, userToken);
      });
    } catch (e) {
      debugPrint("Error registering FCM token: $e");
    }
  }

  String _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      return payloadMap['sub']?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<void> _sendTokenToBackend(String fcmToken, String userToken) async {
    try {
      final idUsuario = _extractUserIdFromToken(userToken);
      await apiClient.postJson('/v1/notificaciones/token', {
        'id_usuario': idUsuario,
        'fcm_token': fcmToken,
      }, bearerToken: userToken);
    } catch (e) {
      debugPrint("Error sending FCM token to backend: $e");
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _tokenRefreshSub?.cancel();
    } catch (e) {
      debugPrint("Error deleting FCM token: $e");
    }
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final tipo = data['tipo'];

    if (tipo == 'NUEVA_ALERTA' ||
        tipo == 'ESTADO_EMERGENCIA' ||
        tipo == 'AUMENTO_CRITICIDAD') {
      final alert = PushAlert(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        zoneId: data['zoneId'] ?? 'unknown',
        zoneName: data['zoneName'] ?? 'Zona General',
        riskLevel: data['riskLevel'] ?? 'CRÍTICO',
        distanceKm:
            double.tryParse(data['distanceKm']?.toString() ?? '0') ?? 0.0,
        receivedAt: DateTime.now(),
      );
      _alertController.add(alert);
    } else if (tipo == 'ASIGNACION_INTERVENCION') {
      _interventionController.add({
        'zoneId': data['zoneId'] ?? '',
        'zoneName': data['zoneName'] ?? 'Zona Desconocida',
      });
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'canal_emergencias',
            'Emergencias',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFFFF6A00),
          ),
        ),
      );
    }
  }

  void simulateIncomingAlert(PushAlert alert) {
    _alertController.add(alert);
  }

  void simulateInterventionAssignment(String zoneId, String zoneName) {
    _interventionController.add({'zoneId': zoneId, 'zoneName': zoneName});
  }

  void dispose() {
    _alertController.close();
    _interventionController.close();
  }
}

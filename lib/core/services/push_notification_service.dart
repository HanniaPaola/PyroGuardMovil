import 'dart:async';
import '../../features/brigadista/domain/entities/push_alert.dart';

/// Servicio de notificaciones push geolocalizadas (HU02).
/// Sustituir el cuerpo de los métodos por firebase_messaging /
/// flutter_local_notifications según el proveedor que se integre.
class PushNotificationService {
  final _alertController = StreamController<PushAlert>.broadcast();
  Stream<PushAlert> get onAlertReceived => _alertController.stream;

  Future<void> initialize() async {
    // Configurar canal de notificación con sonido/vibración distintiva
    // y solicitar permisos de notificación + ubicación en segundo plano.
  }

  /// Simula la recepción de una alerta push para fines de demo/desarrollo.
  void simulateIncomingAlert(PushAlert alert) {
    _alertController.add(alert);
  }

  void dispose() {
    _alertController.close();
  }
}

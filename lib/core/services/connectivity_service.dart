import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Servicio de conectividad mejorado usando internet_connection_checker_plus
/// para detectar recuperación de conexión y disparar sincronización automática.
class ConnectivityService {
  StreamSubscription<InternetStatus>? _subscription;
  bool _lastKnownStatus = true;

  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _statusController.stream;

  Future<bool> checkConnection() async {
    return await InternetConnection().hasInternetAccess;
  }

  void startMonitoring() {
    _subscription?.cancel();
    _subscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      final isOnline = status == InternetStatus.connected;
      if (isOnline != _lastKnownStatus) {
        _lastKnownStatus = isOnline;
        _statusController.add(isOnline);
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

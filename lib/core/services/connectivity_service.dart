import 'dart:async';
import 'dart:io';

/// Servicio de conectividad simple, usado por HU05 para detectar
/// recuperación de conexión y disparar sincronización automática.
class ConnectivityService {
  Timer? _timer;
  bool _lastKnownStatus = true;

  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _statusController.stream;

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      final isOnline = await checkConnection();
      if (isOnline != _lastKnownStatus) {
        _lastKnownStatus = isOnline;
        _statusController.add(isOnline);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _statusController.close();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/risk_zone.dart';
import '../../domain/entities/field_observation.dart';
import '../../domain/entities/push_alert.dart';
import '../../domain/entities/zone_intervention.dart';
import '../../domain/entities/simple_zone.dart';
import '../../domain/repositories/brigadista_repository.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/push_notification_service.dart';

/// Estado central del feature Brigadista. Orquesta mapa de riesgo (HU01),
/// alertas push (HU02), observaciones de campo (HU03), directiva técnica
/// (HU04), modo offline (HU05), historial de alertas (HU06) y perfil de
/// zona con historial de intervenciones (HU07).
class BrigadistaProvider extends ChangeNotifier {
  final BrigadistaRepository repository;
  final ConnectivityService connectivityService;
  final PushNotificationService pushService;

  BrigadistaProvider({
    required this.repository,
    required this.connectivityService,
    required this.pushService,
  }) {
    _listenConnectivity();
    _listenPushAlerts();
  }

  // ----- Zonas / Mapa (HU01) -----
  List<RiskZone> _zones = [];
  List<RiskZone> get zones => _zones;

  bool _loadingZones = false;
  bool get loadingZones => _loadingZones;

  RiskZone? _selectedZone;
  RiskZone? get selectedZone => _selectedZone;

  List<SimpleZone> _simpleZones = [];
  List<SimpleZone> get simpleZones => _simpleZones;

  bool _loadingSimpleZones = false;
  bool get loadingSimpleZones => _loadingSimpleZones;

  // ----- Conectividad / Offline (HU05) -----
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  // ----- Alertas push (HU02, HU06) -----
  final List<PushAlert> _alertHistory = [];
  List<PushAlert> get alertHistory => _alertHistory;
  bool _loadingHistory = false;
  bool get loadingHistory => _loadingHistory;

  // ----- Observaciones de campo (HU03) -----
  bool _submittingObservation = false;
  bool get submittingObservation => _submittingObservation;

  // ----- Perfil de zona / Intervenciones (HU07) -----
  List<ZoneIntervention> _interventions = [];
  List<ZoneIntervention> get interventions => _interventions;
  bool _loadingInterventions = false;
  bool get loadingInterventions => _loadingInterventions;

  // ----- Emergencias -----
  bool _sendingEmergency = false;
  bool get sendingEmergency => _sendingEmergency;

  Future<bool> reportEmergency() async {
    _sendingEmergency = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      await repository.sendEmergency(position.latitude, position.longitude);
      return true;
    } catch (e) {
      // Registrar error o propagarlo para la UI
      return false;
    } finally {
      _sendingEmergency = false;
      notifyListeners();
    }
  }

  // ----- Intervención Activa -----
  String? _activeInterventionId;
  String? _activeInterventionZoneId;
  String? get activeInterventionZoneId => _activeInterventionZoneId;
  String? _activeInterventionZoneName;
  String? get activeInterventionZoneName => _activeInterventionZoneName;

  bool _closingIntervention = false;
  bool get closingIntervention => _closingIntervention;

  void _listenConnectivity() {
    connectivityService.startMonitoring();
    connectivityService.onStatusChange.listen((isOnline) async {
      _isOffline = !isOnline;
      notifyListeners();

      if (isOnline) {
        await repository.syncPendingObservations();
        await _refreshPendingCount();
        await fetchActiveIntervention();
      }
    });
  }

  void _listenPushAlerts() {
    pushService.onAlertReceived.listen((alert) async {
      await repository.cacheAlert(alert);
      _alertHistory.insert(0, alert);
      notifyListeners();
    });

    pushService.onInterventionAssigned.listen((data) {
      _activeInterventionId = data['interventionId'];
      _activeInterventionZoneId = data['zoneId'];
      _activeInterventionZoneName = data['zoneName'];
      notifyListeners();
    });
  }

  Future<void> fetchActiveIntervention() async {
    try {
      final active = await repository.fetchActiveInterventions();
      if (active.isNotEmpty) {
        // Tomamos la primera intervención activa de la lista
        final intervention = active.first;
        _activeInterventionId = intervention.idIntervencion;
        _activeInterventionZoneId = intervention.idZona;
        _activeInterventionZoneName =
            'Zona asignada (ID: ${intervention.idZona})';
        notifyListeners();
      }
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> _refreshPendingCount() async {
    final pending = await repository.getPendingObservations();
    _pendingSyncCount = pending.length;
    notifyListeners();
  }

  Future<bool> closeActiveIntervention({
    required String result,
    required String notes,
  }) async {
    if (_activeInterventionId == null) return false;

    _closingIntervention = true;
    notifyListeners();

    try {
      await repository.closeIntervention(_activeInterventionId!, result, notes);

      _activeInterventionId = null;
      _activeInterventionZoneId = null;
      _activeInterventionZoneName = null;
      return true;
    } catch (_) {
      return false;
    } finally {
      _closingIntervention = false;
      notifyListeners();
    }
  }

  // ---------------- HU01: Mapa de riesgo ----------------
  Future<void> loadZones() async {
    _loadingZones = true;
    notifyListeners();

    try {
      final isOnline = await connectivityService.checkConnection();
      _isOffline = !isOnline;
      if (isOnline) {
        await fetchActiveIntervention();
      }
      _zones = await repository.getRiskZones();
    } finally {
      _loadingZones = false;
      notifyListeners();
    }
  }

  void selectZone(RiskZone zone) {
    _selectedZone = zone;
    notifyListeners();
  }

  Future<void> loadSimpleZones() async {
    _loadingSimpleZones = true;
    notifyListeners();

    try {
      _simpleZones = await repository.getSimpleZones();
    } finally {
      _loadingSimpleZones = false;
      notifyListeners();
    }
  }

  // ---------------- HU03: Observaciones de campo ----------------
  Future<bool> submitObservation(FieldObservation observation) async {
    _submittingObservation = true;
    notifyListeners();

    try {
      await repository.saveFieldObservation(observation);
      await _refreshPendingCount();
      return true;
    } catch (_) {
      return false;
    } finally {
      _submittingObservation = false;
      notifyListeners();
    }
  }

  // ---------------- HU06: Historial de alertas ----------------
  Future<void> loadAlertHistory() async {
    _loadingHistory = true;
    notifyListeners();

    try {
      final history = await repository.getAlertHistory();
      _alertHistory
        ..clear()
        ..addAll(history);
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  // ---------------- HU07: Perfil de zona ----------------
  Future<void> loadZoneInterventions(String zoneId) async {
    _loadingInterventions = true;
    notifyListeners();

    try {
      _interventions = await repository.getZoneInterventions(zoneId);
    } finally {
      _loadingInterventions = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    connectivityService.dispose();
    pushService.dispose();
    super.dispose();
  }
}

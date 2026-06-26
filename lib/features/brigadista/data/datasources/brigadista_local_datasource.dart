import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/risk_zone_model.dart';
import '../models/field_observation_model.dart';
import '../models/push_alert_model.dart';

/// Persistencia local para soportar modo offline (HU05) e historial (HU06).
/// Usa SharedPreferences como almacenamiento simple basado en JSON.
class BrigadistaLocalDataSource {
  static const _zonesKey = 'brigadista_cached_zones';
  static const _pendingObsKey = 'brigadista_pending_observations';
  static const _alertsKey = 'brigadista_alert_history';

  Future<void> cacheZones(List<RiskZoneModel> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = zones.map((z) => z.toJson()).toList();
    await prefs.setString(_zonesKey, jsonEncode(jsonList));
  }

  Future<List<RiskZoneModel>> getCachedZones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_zonesKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => RiskZoneModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> hasCachedZones() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_zonesKey);
  }

  Future<void> queueObservation(FieldObservationModel obs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingObsKey);
    final List<dynamic> list = raw != null ? jsonDecode(raw) : [];
    list.add(obs.toJson());
    await prefs.setString(_pendingObsKey, jsonEncode(list));
  }

  Future<List<FieldObservationModel>> getQueuedObservations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingObsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => FieldObservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearQueuedObservations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingObsKey);
  }

  Future<void> addAlertToHistory(PushAlertModel alert) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alertsKey);
    final List<dynamic> list = raw != null ? jsonDecode(raw) : [];
    list.insert(0, alert.toJson());

    // HU06: conservar historial al menos 30 días
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final filtered = list.where((e) {
      final date = DateTime.parse(e['receivedAt'] as String);
      return date.isAfter(cutoff);
    }).toList();

    await prefs.setString(_alertsKey, jsonEncode(filtered));
  }

  Future<List<PushAlertModel>> getAlertHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alertsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => PushAlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'dart:async';
import 'dart:io';
import '../../domain/entities/risk_zone.dart';
import '../../domain/entities/field_observation.dart';
import '../../domain/entities/push_alert.dart';
import '../../domain/entities/zone_intervention.dart';
import '../../domain/entities/simple_zone.dart';
import '../../domain/repositories/brigadista_repository.dart';
import '../datasources/brigadista_remote_datasource.dart';
import '../datasources/brigadista_local_datasource.dart';
import '../models/risk_zone_model.dart';
import '../models/field_observation_model.dart';
import '../models/push_alert_model.dart';

class BrigadistaRepositoryImpl implements BrigadistaRepository {
  final BrigadistaRemoteDataSource remote;
  final BrigadistaLocalDataSource local;

  BrigadistaRepositoryImpl({required this.remote, required this.local});

  Future<bool> get _isOnline async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<SimpleZone>> getSimpleZones() async {
    return remote.fetchSimpleZones();
  }

  @override
  Future<List<RiskZone>> getRiskZones() async {
    if (await _isOnline) {
      try {
        final zones = await remote.fetchRiskZones();
        await local.cacheZones(zones);
        return zones;
      } catch (_) {
        return local.getCachedZones();
      }
    }
    return local.getCachedZones();
  }

  @override
  Future<RiskZone> getZoneById(String zoneId) async {
    final zones = await getRiskZones();
    return zones.firstWhere((z) => z.id == zoneId, orElse: () => zones.first);
  }

  @override
  Future<void> sendEmergency(double latitude, double longitude) async {
    if (await _isOnline) {
      await remote.sendEmergency(latitude, longitude);
    } else {
      // Si no hay red, podríamos guardar la emergencia localmente si es requerido,
      // pero usualmente un SOS necesita envío inmediato o reintento activo.
      throw Exception(
        'Sin conexión para enviar emergencia. Busca señal o llama por radio.',
      );
    }
  }

  @override
  Future<void> saveFieldObservation(FieldObservation observation) async {
    final model = FieldObservationModel.fromEntity(observation);

    if (await _isOnline) {
      try {
        await remote.uploadObservation(model.toJson());
        return;
      } catch (_) {
        // Si falla el envío, se encola igual que en modo offline.
      }
    }
    await local.queueObservation(model);
  }

  @override
  Future<List<FieldObservation>> getPendingObservations() async {
    return local.getQueuedObservations();
  }

  @override
  Future<void> syncPendingObservations() async {
    if (!await _isOnline) return;

    final pending = await local.getQueuedObservations();
    if (pending.isEmpty) return;

    for (final obs in pending) {
      try {
        await remote.uploadObservation(obs.toJson());
      } catch (_) {
        // Se mantiene en cola si una observación individual falla.
        continue;
      }
    }
    await local.clearQueuedObservations();
  }

  @override
  Future<List<PushAlert>> getAlertHistory() async {
    return local.getAlertHistory();
  }

  @override
  Future<void> cacheAlert(PushAlert alert) async {
    final model = alert is PushAlertModel
        ? alert
        : PushAlertModel(
            id: alert.id,
            zoneId: alert.zoneId,
            zoneName: alert.zoneName,
            riskLevel: alert.riskLevel,
            distanceKm: alert.distanceKm,
            receivedAt: alert.receivedAt,
          );

    await local.addAlertToHistory(model);
  }

  @override
  Future<List<ZoneIntervention>> getZoneInterventions(String zoneId) async {
    return remote.fetchInterventions(zoneId);
  }

  @override
  Future<void> cacheZonesForOffline(List<RiskZone> zones) async {
    final models = zones
        .map((z) => z is RiskZoneModel ? z : RiskZoneModel.fromEntity(z))
        .toList();
    await local.cacheZones(models);
  }

  @override
  Future<bool> hasOfflineCache() async {
    return local.hasCachedZones();
  }
}

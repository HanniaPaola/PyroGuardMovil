import '../entities/risk_zone.dart';
import '../entities/field_observation.dart';
import '../entities/push_alert.dart';
import '../entities/zone_intervention.dart';
import '../entities/simple_zone.dart';
import '../entities/active_intervention.dart';

/// Contrato de dominio para el feature Brigadista.
/// La capa de datos implementa esto combinando fuente remota y local
/// para soportar el modo offline exigido en HU05.
abstract class BrigadistaRepository {
  Future<List<SimpleZone>> getSimpleZones();
  Future<List<RiskZone>> getRiskZones();
  Future<RiskZone> getZoneById(String zoneId);

  Future<void> sendEmergency(double latitude, double longitude);

  Future<void> saveFieldObservation(FieldObservation observation);
  Future<List<FieldObservation>> getPendingObservations();
  Future<void> syncPendingObservations();

  Future<List<PushAlert>> getAlertHistory();
  Future<void> cacheAlert(PushAlert alert);

  Future<List<ZoneIntervention>> getZoneInterventions(String zoneId);

  Future<void> cacheZonesForOffline(List<RiskZone> zones);
  Future<bool> hasOfflineCache();

  Future<List<ActiveIntervention>> fetchActiveInterventions();
  Future<void> closeIntervention(
    String idIntervencion,
    String estado,
    String observaciones,
  );
}

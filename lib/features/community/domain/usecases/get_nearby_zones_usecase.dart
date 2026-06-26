import '../entities/zone.dart';
import '../repositories/community_repository.dart';

class GetNearbyZonesUsecase {
  final CommunityRepository repository;

  GetNearbyZonesUsecase(this.repository);

  Future<List<Zone>> call(double lat, double lng) =>
      repository.getNearbyZones(lat, lng);
}

import '../entities/alert_history.dart';
import '../repositories/community_repository.dart';

class GetAlertHistoryUsecase {
  final CommunityRepository repository;

  GetAlertHistoryUsecase(this.repository);

  Future<List<AlertHistory>> call(String zoneId, {int months = 6}) =>
      repository.getAlertHistory(zoneId, months: months);
}

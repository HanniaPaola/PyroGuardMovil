import 'package:flutter/material.dart';
import '../../domain/entities/citizen_report.dart';
import '../../domain/usecases/submit_citizen_report_usecase.dart';
import '../../domain/repositories/citizen_report_repository.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/connectivity_service.dart';

enum SubmitStatus { idle, loading, success, error }

/// Estado de envío de reportes ciudadanos.
class CitizenReportProvider extends ChangeNotifier {
  final SubmitCitizenReportUsecase submitReportUsecase;
  final ConnectivityService connectivityService;
  final CitizenReportRepository repository;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  CitizenReportProvider({
    required SubmitCitizenReportUsecase submitReport,
    required this.connectivityService,
    required this.repository,
  }) : submitReportUsecase = submitReport {
    _listenConnectivity();
  }

  void _listenConnectivity() {
    connectivityService.startMonitoring();
    connectivityService.onStatusChange.listen((isOnline) async {
      _isOffline = !isOnline;
      notifyListeners();

      if (isOnline) {
        await repository.syncPendingReports();
      }
    });
  }

  SubmitStatus _status = SubmitStatus.idle;
  SubmitStatus get status => _status;

  bool get isLoading => _status == SubmitStatus.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CitizenReport? _lastReport;
  CitizenReport? get lastReport => _lastReport;

  Future<bool> submit({
    required String description,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) async {
    _status = SubmitStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await submitReportUsecase(
        description: description,
        latitude: latitude,
        longitude: longitude,
        photoUrl: photoUrl,
      );

      _lastReport = report;
      _status = SubmitStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = SubmitStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _status = SubmitStatus.error;
      _errorMessage = 'No se pudo enviar el reporte. Intenta de nuevo.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = SubmitStatus.idle;
    _errorMessage = null;
    _lastReport = null;
    notifyListeners();
  }
}

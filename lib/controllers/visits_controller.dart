import 'package:flutter/foundation.dart';
import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';
import 'package:flutter_nobrokeragefortenants/services/repositories/visits_repository.dart';

class VisitsController extends ChangeNotifier {
  VisitsController({required this.repository, required this.isBroker});

  final VisitsRepository repository;
  final bool isBroker;

  static const tabs = ['All', 'Pending', 'Upcoming', 'Completed', 'Cancelled'];

  int _selectedTab = 0;
  bool _isLoading = false;
  String? _actionVisitId;
  Object? _error;
  List<VisitModel> _visits = const [];

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get actionVisitId => _actionVisitId;
  Object? get error => _error;
  List<VisitModel> get visits => [];

  List<VisitModel> get visibleVisits {
    return _visits;
  }

  Future<void> loadVisits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _visits = await repository.getVisits(isBroker: isBroker, status: tabs[selectedTab]);
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTab(int index) {
    if (index == _selectedTab || index < 0 || index >= tabs.length) return;
    _selectedTab = index;
    loadVisits();
    notifyListeners();
  }

  Future<bool> confirmVisit(String visitId) => _performAction(visitId, repository.confirmVisit);

  Future<bool> cancelVisit(String visitId) => _performAction(visitId, repository.cancelVisit);

  Object? takeError() {
    final currentError = _error;
    _error = null;
    return currentError;
  }

  Future<bool> _performAction(String visitId, Future<void> Function(String visitId) action, {String status = "All"}) async {
    _actionVisitId = visitId;
    _error = null;
    notifyListeners();
    try {
      await action(visitId);
      _visits = await repository.getVisits(isBroker: isBroker, status: status);
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _actionVisitId = null;
      notifyListeners();
    }
  }
}

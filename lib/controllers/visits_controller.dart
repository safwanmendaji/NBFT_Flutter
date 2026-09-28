import 'package:flutter/foundation.dart';
 import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/repositories/visits_repository.dart';

class VisitsController extends ChangeNotifier {
  VisitsController({required this.repository, required this.isBroker});

  final VisitsRepository repository;
  final bool isBroker;

  static const tabs = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  int _selectedTab = 0;
  bool _isLoading = false;
  String? _actionVisitId;
  Object? _error;
  List<VisitModel> _visits = const [];

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get actionVisitId => _actionVisitId;
  Object? get error => _error;
  List<VisitModel> get visits => List.unmodifiable(_visits);

  List<VisitModel> get visibleVisits {
    if (_selectedTab == 0) return visits;

    final status = tabs[_selectedTab].toLowerCase();
    if (status == 'upcoming') {
      return _visits
          .where(
            (visit) =>
                visit.status == 'pending' || visit.status == 'confirmed',
          )
          .toList(growable: false);
    }
    return _visits
        .where((visit) => visit.status == status)
        .toList(growable: false);
  }

  Future<void> loadVisits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _visits = await repository.getVisits(isBroker: isBroker);
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
    notifyListeners();
  }

  Future<bool> confirmVisit(String visitId) =>
      _performAction(visitId, repository.confirmVisit);

  Future<bool> cancelVisit(String visitId) =>
      _performAction(visitId, repository.cancelVisit);

  Object? takeError() {
    final currentError = _error;
    _error = null;
    return currentError;
  }

  Future<bool> _performAction(
    String visitId,
    Future<void> Function(String visitId) action,
  ) async {
    _actionVisitId = visitId;
    _error = null;
    notifyListeners();
    try {
      await action(visitId);
      _visits = await repository.getVisits(isBroker: isBroker);
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

import 'package:flutter_nobrokeragefortenants/controllers/visits_controller.dart';
import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';
import 'package:flutter_nobrokeragefortenants/services/repositories/visits_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisitsController', () {
    test('loads and filters visits without view state', () async {
      final repository = _FakeVisitsRepository();
      final controller = VisitsController(
        repository: repository,
        isBroker: true,
      );

      await controller.loadVisits();
      controller.selectTab(1);

      expect(repository.lastBrokerValue, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.visibleVisits.map((visit) => visit.id), ['pending']);
    });

    test('refreshes visits after confirming a visit', () async {
      final repository = _FakeVisitsRepository();
      final controller = VisitsController(
        repository: repository,
        isBroker: false,
      );

      final succeeded = await controller.confirmVisit('pending');

      expect(succeeded, isTrue);
      expect(repository.confirmedVisitId, 'pending');
      expect(repository.loadCount, 1);
      expect(controller.actionVisitId, isNull);
    });

    test('exposes an action failure for the view to present', () async {
      final repository = _FakeVisitsRepository(shouldFail: true);
      final controller = VisitsController(
        repository: repository,
        isBroker: false,
      );

      final succeeded = await controller.cancelVisit('pending');

      expect(succeeded, isFalse);
      expect(controller.takeError(), isA<StateError>());
      expect(controller.takeError(), isNull);
    });
  });
}

class _FakeVisitsRepository implements VisitsRepository {
  _FakeVisitsRepository({this.shouldFail = false});

  final bool shouldFail;
  bool? lastBrokerValue;
  String? confirmedVisitId;
  int loadCount = 0;

  @override
  Future<void> cancelVisit(String visitId) async {
    if (shouldFail) throw StateError('Unable to cancel visit');
  }

  @override
  Future<void> confirmVisit(String visitId) async {
    confirmedVisitId = visitId;
  }

  @override
  Future<List<VisitModel>> getVisits({required bool isBroker}) async {
    lastBrokerValue = isBroker;
    loadCount++;
    return const [
      VisitModel(
        id: 'pending',
        title: 'Pending visit',
        location: 'Pune',
        date: '15 Sep 2026',
        time: '10:00',
        status: 'pending',
      ),
      VisitModel(
        id: 'completed',
        title: 'Completed visit',
        location: 'Pune',
        date: '14 Sep 2026',
        time: '09:00',
        status: 'completed',
      ),
    ];
  }
}

 import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';

abstract interface class VisitsRepository {
  Future<List<VisitModel>> getVisits({required bool isBroker});

  Future<void> confirmVisit(String visitId);

  Future<void> cancelVisit(String visitId);
}

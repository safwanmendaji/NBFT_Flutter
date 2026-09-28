import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the populated backend visit response', () {
    final visit = VisitModel.fromJson({
      '_id': 'visit-1',
      'propertyId': {
        'title': 'Lake View Apartment',
        'location': 'Baner',
        'media': [
          {'path': 'uploads/property.jpg'},
        ],
      },
      'visitDate': '2026-09-15T00:00:00.000Z',
      'startTime': '10:00 AM',
      'endTime': '10:30 AM',
      'status': 'Confirmed',
    });

    expect(visit.id, 'visit-1');
    expect(visit.title, 'Lake View Apartment');
    expect(visit.location, 'Baner');
    expect(visit.date, '15 Sep 2026');
    expect(visit.time, '10:00 AM - 10:30 AM');
    expect(visit.status, 'confirmed');
    expect(visit.image, 'uploads/property.jpg');
  });

  test('normalizes every backend visit status used by filters', () {
    String status(String value) =>
        VisitModel.fromJson({'status': value}).status;

    expect(status('Pending'), 'pending');
    expect(status('Confirmed'), 'confirmed');
    expect(status('Completed'), 'completed');
    expect(status('Cancelled'), 'cancelled');
  });
}
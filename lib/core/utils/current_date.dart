import 'package:intl/intl.dart';

String getFormattedDate() {
  final now = DateTime.now();
  final day = DateFormat('dd').format(now);
  final month = DateFormat('MMMM').format(now);
  final weekday = DateFormat('EEEE').format(now);
  final year = DateFormat('yyyy').format(now);

  return '$day $month, $weekday $year';
}

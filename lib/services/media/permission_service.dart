import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission({required Permission permission}) async {
  final status = await permission.request();
  return status.isGranted;
}

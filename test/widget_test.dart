import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/main.dart';
import 'package:flutter_nobrokeragefortenants/screens/splash/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the app from an empty session', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await Prefs.init();

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MySplashScreen), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:latres/main.dart';
import 'package:latres/pages/login_page.dart';

void main() {
  testWidgets('App renders LoginPage when not logged in', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that LoginPage is presented with Login title
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}

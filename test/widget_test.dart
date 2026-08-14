// Basic widget test for Personal Expense Tracker
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/main.dart';
import 'package:my_first_app/providers/settings_provider.dart';

void main() {
  testWidgets('App launches and shows home shell', (WidgetTester tester) async {
    // Provide mock SharedPreferences values for the test environment
    SharedPreferences.setMockInitialValues({});
    
    final settings = SettingsProvider();
    await settings.init();

    await tester.pumpWidget(
      ExpenseTrackerApp(
        firebaseInitialized: false,
        settingsProvider: settings,
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom nav items are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
  });
}

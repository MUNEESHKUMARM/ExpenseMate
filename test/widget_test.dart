// Basic widget test for Personal Expense Tracker
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/main.dart';
import 'package:my_first_app/providers/settings_provider.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
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
    await tester.pump(const Duration(milliseconds: 500));

    // Verify root widget renders
    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}

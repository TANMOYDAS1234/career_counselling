import 'package:career_counselling_app/app.dart';
import 'package:career_counselling_app/core/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the landing page and shows the brand', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const EduBotApp(),
      ),
    );
    await tester.pump();

    expect(find.text('EduBot'), findsWidgets);
    expect(find.text('Get Started Free'), findsWidgets);
  });
}

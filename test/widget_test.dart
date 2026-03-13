// Basic widget test demonstrating provider overrides and ensuring LoginScreen shown when not authenticated.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/main.dart';
import 'package:mini_news_intelligence/src/features/auth/auth_providers.dart';
import 'package:mini_news_intelligence/src/data/models/user_model.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(null as dynamic);

  @override
  Future<void> checkAuthOnStartup() async {
    state = AuthState(isAuthenticated: false, isLoading: false);
  }
}

void main() {
  testWidgets('Shows LoginScreen when not authenticated', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    // initial loading may show progress; allow frames
    await tester.pumpAndSettle();
    // Expect to find Login Screen title or username field
    expect(find.text('Login'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}

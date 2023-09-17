import 'package:clean_todo/data/local/todo/todo_local_service.dart';
import 'package:clean_todo/data/repository_impl/todo/todo_repository_impl.dart';
import 'package:clean_todo/domain/repository/todo/todo_repository.dart';
import 'package:clean_todo/ui/providers/todo_provider.dart';
import 'package:clean_todo/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:clean_todo/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Testing App to add, delete todos', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final localService = await SharedPreferences.getInstance();

    final TodoRepository todoRepository = TodoRepositoryImpl(todoLocalDataSource: TodoLocalService(localService));

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TodoProvider>(create: (context) => TodoProvider(todoRepository)),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              title: 'Todo Demo',
              theme: ThemeData(
                primarySwatch: Colors.amber,
              ),
              home: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("No todos found"), findsOneWidget);

      var fab = find.byTooltip('Increment');

      expect(fab, findsOneWidget);

      await tester.tap(fab);

      await tester.pumpAndSettle();

      expect(find.text("Add Todo"), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, "Title");

      await tester.enterText(find.byType(TextFormField).last, "Description");

      await tester.tap(find.byType(ElevatedButton));

      await tester.pumpAndSettle();

      expect(find.text("Title"), findsOneWidget);

      expect(find.text("Description"), findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, "Title 2");
      await tester.enterText(find.byType(TextFormField).last, "Description 2");
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text("Title 2"), findsOneWidget);
      expect(find.text("Description 2"), findsOneWidget);

      await tester.longPress(find.text("Title 2"));
      await tester.pumpAndSettle();

      expect(find.text("Delete Todo?"), findsOneWidget);

      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();

      expect(find.text("Title 2"), findsNothing);
      expect(find.text("Description 2"), findsNothing);

      await tester.tap(find.byTooltip('Options'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Delete All"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();

      expect(find.text("No todos found"), findsOneWidget);
    });
  });
}

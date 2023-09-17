import 'package:clean_todo/data/local/local_storage.dart';
import 'package:clean_todo/data/local/todo/todo_local_service.dart';
import 'package:clean_todo/data/repository_impl/todo/todo_repository_impl.dart';
import 'package:clean_todo/domain/entity/todo_entity.dart';
import 'package:clean_todo/domain/repository/todo/todo_repository.dart';
import 'package:clean_todo/main.dart';
import 'package:clean_todo/ui/providers/todo_provider.dart';
import 'package:clean_todo/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group("TodoListWidget", () {
    testWidgets("If Todo list is empty", (WidgetTester tester) async {
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        final localService = await SharedPreferences.getInstance();

        final TodoRepository todoRepository = TodoRepositoryImpl(todoLocalDataSource: TodoLocalService(localService));

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

        expect(find.text("No todos found"), findsOneWidget);
      });
    });

    testWidgets("If Todo list has 3 todos inside", (WidgetTester tester) async {
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        final localService = await SharedPreferences.getInstance();

        final TodoRepository todoRepository = TodoRepositoryImpl(todoLocalDataSource: TodoLocalService(localService));
        TodoProvider todoProvider = TodoProvider(todoRepository);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<TodoProvider>(create: (context) => todoProvider),
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

        todoProvider.saveTodo(
          Todo(
            title: "title",
            description: "description",
          ),
          updateTodo: true,
        );
        todoProvider.saveTodo(
          Todo(
            title: "title",
            description: "description",
          ),
          updateTodo: true,
        );
        todoProvider.saveTodo(
          Todo(
            title: "title",
            description: "description",
          ),
          updateTodo: true,
        );

        await tester.pumpAndSettle();

        expect(find.text("title"), findsNWidgets(3));
      });
    });
  });
}

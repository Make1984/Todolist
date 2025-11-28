import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/todo_service.dart';
import 'services/auth_service.dart';
import 'screens/todolist/todolist_main.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final authService = AuthService();
  final todoService = TodoService();

  // Load persisted data
  await authService.loadData();
  await todoService.loadTodos();

  runApp(MyApp(authService: authService, todoService: todoService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final TodoService todoService;

  const MyApp({
    super.key,
    required this.authService,
    required this.todoService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: todoService),
      ],
      child: MaterialApp(
        title: 'Todoアプリ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.isAuthenticated) {
              // Set current user in TodoService when authenticated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<TodoService>(
                  context,
                  listen: false,
                ).setCurrentUser(authService.currentUser?.id);
              });
              return const TodolistMain();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

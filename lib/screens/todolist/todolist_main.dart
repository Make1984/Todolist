import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/todo_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'todolist_addition.dart';
import 'todolist_edit.dart';
import 'todolist_delete.dart';

class TodolistMain extends StatelessWidget {
  const TodolistMain({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Todo一覧'),
            if (currentUser != null) ...[
              const Text(' - ', style: TextStyle(fontSize: 20)),
              Text(currentUser.name, style: const TextStyle(fontSize: 20)),
            ],
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () {
              final todoService = Provider.of<TodoService>(
                context,
                listen: false,
              );
              authService.logout();
              todoService.clearUserTodos();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Consumer<TodoService>(
          builder: (context, todoService, child) {
            if (todoService.todos.isEmpty) {
              return const Center(
                child: Text(
                  'Todoがありません\n下のボタンから追加してください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: todoService.todos.length,
              itemBuilder: (context, index) {
                final todo = todoService.todos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.black, width: 1.0),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (value) {
                        todoService.toggleTodoStatus(todo.id);
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration:
                            todo.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      todo.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TodolistEdit(todoId: todo.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        TodolistDelete(todoId: todo.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodolistAddition()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

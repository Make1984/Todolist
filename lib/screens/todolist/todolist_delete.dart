import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/todo_service.dart';

class TodolistDelete extends StatelessWidget {
  final String todoId;

  const TodolistDelete({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    final todoService = Provider.of<TodoService>(context, listen: false);
    final todo = todoService.getTodoById(todoId);

    if (todo == null) {
      // If todo not found, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(body: Center(child: Text('Todoが見つかりません')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo削除'),
        backgroundColor: Colors.red[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '以下のTodoを削除しますか？',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'タイトル:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '説明:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      todo.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                todoService.deleteTodo(todoId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('削除する', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('キャンセル', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

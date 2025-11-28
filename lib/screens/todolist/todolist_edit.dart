import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/todo_service.dart';

class TodolistEdit extends StatefulWidget {
  final String todoId;

  const TodolistEdit({super.key, required this.todoId});

  @override
  State<TodolistEdit> createState() => _TodolistEditState();
}

class _TodolistEditState extends State<TodolistEdit> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing todo data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todoService = Provider.of<TodoService>(context, listen: false);
      final todo = todoService.getTodoById(widget.todoId);
      if (todo != null) {
        _titleController.text = todo.title;
        _descriptionController.text = todo.description;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateTodo() {
    if (_formKey.currentState!.validate()) {
      final todoService = Provider.of<TodoService>(context, listen: false);
      todoService.updateTodo(
        widget.todoId,
        _titleController.text,
        _descriptionController.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo編集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '説明を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('更新', style: TextStyle(fontSize: 16)),
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
      ),
    );
  }
}

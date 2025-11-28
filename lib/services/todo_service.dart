import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';

class TodoService extends ChangeNotifier {
  final List<Todo> _todos = [];
  String? _currentUserId;

  List<Todo> get todos {
    if (_currentUserId == null) {
      return [];
    }
    return List.unmodifiable(
      _todos.where((todo) => todo.userId == _currentUserId),
    );
  }

  // Load saved todos
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString('todos');

    if (todosJson != null) {
      final List<dynamic> todosList = json.decode(todosJson);
      _todos.clear();
      _todos.addAll(todosList.map((json) => Todo.fromJson(json)).toList());
      notifyListeners();
    }
  }

  // Save todos to storage
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', todosJson);
  }

  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  Future<void> addTodo(String title, String description) async {
    if (_currentUserId == null) return;

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId!,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> updateTodo(String id, String title, String description) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        title: title,
        description: description,
      );
      await _saveTodos();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      await _saveTodos();
      notifyListeners();
    }
  }

  Todo? getTodoById(String id) {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearUserTodos() {
    _currentUserId = null;
    notifyListeners();
  }
}

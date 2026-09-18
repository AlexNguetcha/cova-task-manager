import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth.dart';
import '../models/task.dart';

class PaginatedResult<T> {
  final List<T> items;
  final int totalPages;
  final int totalElements;

  PaginatedResult({
    required this.items,
    required this.totalPages,
    required this.totalElements,
  });
}

class ApiService {
  // Change this to your Railway URL for production
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8082/api',
  );
  static const _storage = FlutterSecureStorage();

  // ── Auth ──

  Future<AuthResponse> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) throw Exception('Identifiants invalides');
    final data = AuthResponse.fromJson(jsonDecode(res.body));
    await _storage.write(key: 'accessToken', value: data.accessToken);
    await _storage.write(key: 'refreshToken', value: data.refreshToken);
    await _storage.write(key: 'user', value: res.body);
    return data;
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode != 201) throw Exception('Inscription échouée');
    final data = AuthResponse.fromJson(jsonDecode(res.body));
    await _storage.write(key: 'accessToken', value: data.accessToken);
    await _storage.write(key: 'refreshToken', value: data.refreshToken);
    await _storage.write(key: 'user', value: res.body);
    return data;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() => _storage.read(key: 'accessToken');

  Future<User?> getSavedUser() async {
    final data = await _storage.read(key: 'user');
    if (data == null) return null;
    return User.fromJson(jsonDecode(data));
  }

  // ── Tasks ──

  Future<PaginatedResult<Task>> getTasks({String? status, String? priority, String? search, int page = 0, int size = 10}) async {
    final token = await getToken();
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (priority != null && priority.isNotEmpty) params['priority'] = priority;
    if (search != null && search.isNotEmpty) params['search'] = search;
    params['page'] = page.toString();
    params['size'] = size.toString();
    final uri = Uri.parse('$_baseUrl/tasks').replace(queryParameters: params);

    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode != 200) throw Exception('Erreur chargement');
    final Map<String, dynamic> body = jsonDecode(res.body);
    final List<dynamic> list = body['content'] as List<dynamic>;
    final tasks = list.map((e) => Task.fromJson(e)).toList();
    return PaginatedResult(
      items: tasks,
      totalPages: body['totalPages'] as int,
      totalElements: body['totalElements'] as int,
    );
  }

  Future<Task> createTask(Task task) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task.toJson()),
    );
    if (res.statusCode != 201) throw Exception('Erreur création');
    return Task.fromJson(jsonDecode(res.body));
  }

  Future<Task> updateTask(int id, Task task) async {
    final token = await getToken();
    final res = await http.put(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(task.toJson()),
    );
    if (res.statusCode != 200) throw Exception('Erreur modification');
    return Task.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteTask(int id) async {
    final token = await getToken();
    final res = await http.delete(
      Uri.parse('$_baseUrl/tasks/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 204) throw Exception('Erreur suppression');
  }
}
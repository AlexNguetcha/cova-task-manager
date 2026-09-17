import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  List<Task> _tasks = [];
  bool _loading = true;
  String _statusFilter = '';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      _tasks = await _api.getTasks(status: _statusFilter.isEmpty ? null : _statusFilter, search: _search.isEmpty ? null : _search);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.TODO:
        return AppTheme.textSecondary;
      case TaskStatus.IN_PROGRESS:
        return AppTheme.secondary;
      case TaskStatus.COMPLETED:
        return AppTheme.success;
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.LOW:
        return AppTheme.textSecondary;
      case TaskPriority.MEDIUM:
        return AppTheme.secondary;
      case TaskPriority.HIGH:
        return AppTheme.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: AppTheme.textSecondary), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) {
                _search = v;
                _loadTasks();
              },
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tous', '', AppTheme.primary),
                const SizedBox(width: 8),
                _buildFilterChip('À faire', 'TODO', AppTheme.textSecondary),
                const SizedBox(width: 8),
                _buildFilterChip('En cours', 'IN_PROGRESS', AppTheme.secondary),
                const SizedBox(width: 8),
                _buildFilterChip('Terminé', 'COMPLETED', AppTheme.success),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.checklist_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const Text('Aucune tâche', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                            const SizedBox(height: 8),
                            const Text('Créez votre première tâche', style: TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.destructive,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Supprimer'),
                                    content: Text('Supprimer "${task.title}" ?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: AppTheme.destructive))),
                                    ],
                                  ),
                                );
                                return confirm ?? false;
                              },
                              onDismissed: (_) async {
                                await _api.deleteTask(task.id);
                                _loadTasks();
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Priority bar
                                      Container(
                                        width: 4,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _priorityColor(task.priority),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary,
                                                decoration: task.status == TaskStatus.COMPLETED ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            if (task.description != null && task.description!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(task.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                            ],
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(task.status).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(task.statusLabel, style: TextStyle(fontSize: 11, color: _statusColor(task.status), fontWeight: FontWeight.w500)),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(task.priorityLabel, style: TextStyle(fontSize: 11, color: _priorityColor(task.priority))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Edit button
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 20),
                                        onPressed: () async {
                                          await Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)));
                                          _loadTasks();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskFormScreen()));
          _loadTasks();
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final selected = _statusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _statusFilter = value);
        _loadTasks();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : color, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
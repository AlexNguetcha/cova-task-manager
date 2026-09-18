import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = '';
  String _priorityFilter = '';
  bool _showSearch = false;
  int _page = 0;
  int _totalPages = 0;
  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    _error = null;
    try {
      final result = await _api.getTasks(
        status: _statusFilter.isEmpty ? null : _statusFilter,
        priority: _priorityFilter.isEmpty ? null : _priorityFilter,
        search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
        page: _page,
        size: 10,
      );
      _tasks = result.items;
      _totalPages = result.totalPages;
      _totalElements = result.totalElements;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _FilterSheet(
        statusFilter: _statusFilter,
        priorityFilter: _priorityFilter,
        onApply: (status, priority) {
          setState(() {
            _statusFilter = status;
            _priorityFilter = priority;
            _page = 0;
          });
          _loadTasks();
        },
      ),
    );
  }

  void _openTaskDetail(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    _loadTasks();
  }

  void _openTaskForm({Task? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    _loadTasks();
  }

  Future<bool> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer la tâche'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${task.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.destructive),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = _statusFilter.isNotEmpty || _priorityFilter.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes tâches'),
                  if (_totalElements > 0)
                    Text(
                      '$_totalElements tâche${_totalElements > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withValues(alpha: 0.7), fontWeight: FontWeight.w400),
                    ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                _page = 0;
                _loadTasks();
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: activeFilters ? AppTheme.primary : null,
            ),
            onPressed: _openFilters,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated search bar
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _showSearch
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une tâche...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _loadTasks();
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        _page = 0;
                        _loadTasks();
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Active filter indicator
          if (activeFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.tune, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    _buildFilterLabel(),
                    style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _statusFilter = '';
                        _priorityFilter = '';
                        _page = 0;
                      });
                      _loadTasks();
                    },
                    child: const Text('Réinitialiser', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _buildFilterLabel() {
    final parts = <String>[];
    if (_statusFilter.isNotEmpty) {
      parts.add(_statusFilter == 'TODO' ? 'À faire' : _statusFilter == 'IN_PROGRESS' ? 'En cours' : 'Terminé');
    }
    if (_priorityFilter.isNotEmpty) {
      parts.add(_priorityFilter == 'HIGH' ? 'Haute' : _priorityFilter == 'MEDIUM' ? 'Moyenne' : 'Basse');
    }
    return 'Filtres : ${parts.join(' · ')}';
  }

  Widget _buildContent() {
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (_, __) => const _TaskSkeleton(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.cloud_off_rounded, size: 32, color: AppTheme.destructive.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 20),
              const Text('Oups !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Impossible de charger vos tâches.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadTasks,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withValues(alpha: 0.15), AppTheme.secondary.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(Icons.checklist_rounded, size: 40, color: AppTheme.primary.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
              const Text('Aucune tâche', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Créez votre première tâche pour\ncommencer à organiser votre travail.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withValues(alpha: 0.8), height: 1.4),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _openTaskForm(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Créer une tâche'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _page = 0;
        await _loadTasks();
      },
      color: AppTheme.primary,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(top: 4, bottom: 88),
        itemCount: _tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == _tasks.length) {
            return _PaginationBar(
              page: _page,
              totalPages: _totalPages,
              onPrevious: () {
                if (_page > 0) {
                  setState(() => _page--);
                  _loadTasks();
                }
              },
              onNext: () {
                if (_page < _totalPages - 1) {
                  setState(() => _page++);
                  _loadTasks();
                }
              },
            );
          }
          final task = _tasks[index];
          return _TaskCard(
            key: ValueKey(task.id),
            task: task,
            index: index,
            onTap: () => _openTaskDetail(task),
            onEdit: () => _openTaskForm(task: task),
            onDelete: () async {
              if (await _confirmDelete(task)) {
                await _api.deleteTask(task.id);
                _loadTasks();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${task.title}" supprimée'),
                      action: SnackBarAction(label: 'OK', onPressed: () {}),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Task Card
// ──────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.HIGH:
        return AppTheme.priorityHigh;
      case TaskPriority.MEDIUM:
        return AppTheme.priorityMedium;
      case TaskPriority.LOW:
        return AppTheme.priorityLow;
    }
  }

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.TODO:
        return AppTheme.statusTodo;
      case TaskStatus.IN_PROGRESS:
        return AppTheme.statusProgress;
      case TaskStatus.COMPLETED:
        return AppTheme.statusDone;
    }
  }

  String get _statusLabel {
    switch (task.status) {
      case TaskStatus.TODO:
        return 'À faire';
      case TaskStatus.IN_PROGRESS:
        return 'En cours';
      case TaskStatus.COMPLETED:
        return 'Terminée';
    }
  }

  bool get _isOverdue =>
      task.dueDate != null &&
      DateTime.parse(task.dueDate!).isBefore(DateTime.now()) &&
      task.status != TaskStatus.COMPLETED;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, index == 0 ? 8 : 0, 16, 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority strip
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: _priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  decoration: task.status == TaskStatus.COMPLETED ? TextDecoration.lineThrough : null,
                                  decorationColor: AppTheme.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_isOverdue)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(Icons.error_outline, size: 18, color: AppTheme.destructive.withValues(alpha: 0.7)),
                              ),
                          ],
                        ),
                        // Description
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withValues(alpha: 0.8)),
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Meta row
                        Row(
                          children: [
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel,
                                style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Priority indicator
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, size: 12, color: _priorityColor.withValues(alpha: 0.7)),
                                const SizedBox(width: 3),
                                Text(
                                  task.priority == TaskPriority.HIGH
                                      ? 'Haute'
                                      : task.priority == TaskPriority.MEDIUM
                                          ? 'Moy.'
                                          : 'Basse',
                                  style: TextStyle(fontSize: 11, color: _priorityColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            // Due date
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isOverdue ? Icons.schedule : Icons.calendar_today,
                                    size: 12,
                                    color: _isOverdue ? AppTheme.destructive : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatDate(task.dueDate!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _isOverdue ? AppTheme.destructive : AppTheme.textSecondary,
                                      fontWeight: _isOverdue ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      onPressed: onEdit,
                      splashRadius: 18,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppTheme.destructive.withValues(alpha: 0.5),
                      onPressed: onDelete,
                      splashRadius: 18,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    final months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${months[d.month - 1]}';
  }
}

// ──────────────────────────────────────────────
// Pagination Bar
// ──────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${page + 1} sur $totalPages',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page == 0 ? null : onPrevious,
                color: page == 0 ? AppTheme.border : AppTheme.primary,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page >= totalPages - 1 ? null : onNext,
                color: page >= totalPages - 1 ? AppTheme.border : AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Skeleton loader
// ──────────────────────────────────────────────

class _TaskSkeleton extends StatelessWidget {
  const _TaskSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 180, height: 12, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 6),
              Container(width: 120, height: 9, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 10),
              Container(width: 80, height: 16, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Filter Bottom Sheet
// ──────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final String statusFilter;
  final String priorityFilter;
  final void Function(String status, String priority) onApply;

  const _FilterSheet({
    required this.statusFilter,
    required this.priorityFilter,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _status;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _status = widget.statusFilter;
    _priority = widget.priorityFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Filtrer les tâches', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 24),

          // Status
          const Text('Statut', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip('Tous', '', _status == ''),
              _buildChoiceChip('À faire', 'TODO', _status == 'TODO'),
              _buildChoiceChip('En cours', 'IN_PROGRESS', _status == 'IN_PROGRESS'),
              _buildChoiceChip('Terminé', 'COMPLETED', _status == 'COMPLETED'),
            ],
          ),
          const SizedBox(height: 20),

          // Priority
          const Text('Priorité', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip('Toutes', '', _priority == ''),
              _buildChoiceChip('Haute', 'HIGH', _priority == 'HIGH'),
              _buildChoiceChip('Moyenne', 'MEDIUM', _priority == 'MEDIUM'),
              _buildChoiceChip('Basse', 'LOW', _priority == 'LOW'),
            ],
          ),
          const SizedBox(height: 28),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_status, _priority);
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, bool selected) {
    final color = value == 'HIGH' || value == 'IN_PROGRESS'
        ? AppTheme.secondary
        : value == 'COMPLETED'
            ? AppTheme.success
            : AppTheme.primary;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? color : AppTheme.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: selected ? color : AppTheme.border),
      onSelected: (v) {
        setState(() {
          if (value.isEmpty) {
            if (label.contains('Tous') || label.contains('Toutes')) {
              _status = '';
              _priority = '';
            }
          } else {
            if (['TODO', 'IN_PROGRESS', 'COMPLETED'].contains(value)) {
              _status = value;
            } else {
              _priority = value;
            }
          }
        });
      },
    );
  }
}
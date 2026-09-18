import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.TODO:
        return AppTheme.statusTodo;
      case TaskStatus.IN_PROGRESS:
        return AppTheme.statusProgress;
      case TaskStatus.COMPLETED:
        return AppTheme.statusDone;
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.HIGH:
        return AppTheme.priorityHigh;
      case TaskPriority.MEDIUM:
        return AppTheme.priorityMedium;
      case TaskPriority.LOW:
        return AppTheme.priorityLow;
    }
  }

  bool get _isOverdue =>
      task.dueDate != null &&
      DateTime.parse(task.dueDate!).isBefore(DateTime.now()) &&
      task.status != TaskStatus.COMPLETED;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _priorityColor(task.priority).withValues(alpha: 0.08),
                    _priorityColor(task.priority).withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _priorityColor(task.priority).withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _priorityColor(task.priority).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag, size: 14, color: _priorityColor(task.priority)),
                            const SizedBox(width: 4),
                            Text(
                              task.priority == TaskPriority.HIGH
                                  ? 'Haute priorité'
                                  : task.priority == TaskPriority.MEDIUM
                                      ? 'Priorité moyenne'
                                      : 'Basse priorité',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _priorityColor(task.priority),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isOverdue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.destructive.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, size: 14, color: AppTheme.destructive),
                              SizedBox(width: 4),
                              Text(
                                'En retard',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.destructive),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Description ──
            if (task.description != null && task.description!.isNotEmpty) ...[
              _sectionHeader('Description'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Text(
                  task.description!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Info grid ──
            _sectionHeader('Informations'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.circle_outlined,
                    'Statut',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(task.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(task.status),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.flag_outlined,
                    'Priorité',
                    Text(
                      task.priorityLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _priorityColor(task.priority),
                      ),
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const Divider(height: 24),
                    _infoRow(
                      _isOverdue ? Icons.schedule : Icons.calendar_today_outlined,
                      'Échéance',
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDate(task.dueDate!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _isOverdue ? FontWeight.w600 : FontWeight.w500,
                              color: _isOverdue ? AppTheme.destructive : AppTheme.textPrimary,
                            ),
                          ),
                          if (_isOverdue) ...[
                            const SizedBox(width: 6),
                            const Text(
                              '(En retard)',
                              style: TextStyle(fontSize: 12, color: AppTheme.destructive, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Timestamps ──
            _sectionHeader('Historique'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.add_circle_outline,
                    'Créée',
                    Text(
                      _formatDateTime(task.createdAt),
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.edit_outlined,
                    'Modifiée',
                    Text(
                      _formatDateTime(task.updatedAt),
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, Widget value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary.withValues(alpha: 0.6)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const Spacer(),
        value,
      ],
    );
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    final months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatDateTime(String date) {
    final d = DateTime.parse(date);
    final months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${months[d.month - 1]} ${d.year} à ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskStatus _status = TaskStatus.TODO;
  TaskPriority _priority = TaskPriority.MEDIUM;
  final _api = ApiService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        status: _status,
        priority: _priority,
        dueDate: null,
        createdAt: '',
        updatedAt: '',
      );
      if (widget.task == null) {
        await _api.createTask(task);
      } else {
        await _api.updateTask(widget.task!.id, task);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: AppTheme.destructive),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier' : 'Nouvelle tâche')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titre', hintText: 'Que devez-vous faire ?'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'Détails optionnels...'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: TaskStatus.TODO, child: Text('À faire')),
                  DropdownMenuItem(value: TaskStatus.IN_PROGRESS, child: Text('En cours')),
                  DropdownMenuItem(value: TaskStatus.COMPLETED, child: Text('Terminé')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priorité'),
                items: const [
                  DropdownMenuItem(value: TaskPriority.LOW, child: Text('Basse')),
                  DropdownMenuItem(value: TaskPriority.MEDIUM, child: Text('Moyenne')),
                  DropdownMenuItem(value: TaskPriority.HIGH, child: Text('Haute')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Modifier' : 'Créer la tâche'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
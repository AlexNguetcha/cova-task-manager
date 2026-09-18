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
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
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
      _dueDateCtrl.text = widget.task!.dueDate ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDateCtrl.text.isNotEmpty ? DateTime.parse(_dueDateCtrl.text) : now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dueDateCtrl.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final task = Task(
        id: widget.task?.id ?? 0,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        status: _status,
        priority: _priority,
        dueDate: _dueDateCtrl.text.isNotEmpty ? _dueDateCtrl.text : null,
        createdAt: '',
        updatedAt: '',
      );
      if (widget.task == null) {
        await _api.createTask(task);
      } else {
        await _api.updateTask(widget.task!.id, task);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task == null ? 'Tâche créée avec succès' : 'Tâche modifiée avec succès'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppTheme.destructive,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          if (_titleCtrl.text.isNotEmpty)
            TextButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    )
                  : const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Title ──
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Que devez-vous faire ?',
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Le titre est requis';
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // ── Description ──
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Ajoutez des détails...',
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 20),

                // ── Status & Priority side by side ──
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskStatus>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.circle_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: TaskStatus.TODO, child: Text('À faire')),
                          DropdownMenuItem(value: TaskStatus.IN_PROGRESS, child: Text('En cours')),
                          DropdownMenuItem(value: TaskStatus.COMPLETED, child: Text('Terminé')),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          prefixIcon: Icon(Icons.flag_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: TaskPriority.LOW, child: Text('Basse')),
                          DropdownMenuItem(value: TaskPriority.MEDIUM, child: Text('Moyenne')),
                          DropdownMenuItem(value: TaskPriority.HIGH, child: Text('Haute')),
                        ],
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Due date ──
                TextFormField(
                  controller: _dueDateCtrl,
                  decoration: InputDecoration(
                    labelText: "Date d'échéance",
                    hintText: 'Sélectionner une date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                    suffixIcon: _dueDateCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _dueDateCtrl.clear()),
                          )
                        : null,
                  ),
                  readOnly: true,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 32),

                // ── Submit button (mobile friendly) ──
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(isEdit ? 'Modifier la tâche' : 'Créer la tâche'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
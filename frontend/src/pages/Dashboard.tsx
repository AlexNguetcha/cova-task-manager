import { useState } from 'react'
import { useTasks, useCreateTask, useUpdateTask, useDeleteTask } from '@/hooks/useTasks'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Plus, Search, Loader2, Trash2, Edit3, CheckCircle2, Clock, Circle, AlertTriangle, Flag } from 'lucide-react'
import type { Task, TaskStatus, TaskPriority, TaskFormData } from '@/types'
import { useToast } from '@/hooks/use-toast'

const statusConfig: Record<TaskStatus, { label: string; icon: typeof Circle; color: string }> = {
  TODO: { label: 'Todo', icon: Circle, color: 'text-muted-foreground' },
  IN_PROGRESS: { label: 'In Progress', icon: Clock, color: 'text-secondary' },
  COMPLETED: { label: 'Completed', icon: CheckCircle2, color: 'text-primary' },
}

const priorityConfig: Record<TaskPriority, { label: string; color: string }> = {
  LOW: { label: 'Low', color: 'text-muted-foreground' },
  MEDIUM: { label: 'Medium', color: 'text-secondary' },
  HIGH: { label: 'High', color: 'text-destructive' },
}

export default function Dashboard() {
  const [statusFilter, setStatusFilter] = useState<string>('')
  const [priorityFilter, setPriorityFilter] = useState<string>('')
  const [search, setSearch] = useState('')
  const [editingTask, setEditingTask] = useState<Task | null>(null)
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const { toast } = useToast()

  const { data: tasks, isLoading, error } = useTasks(
    statusFilter || undefined,
    priorityFilter || undefined,
    search || undefined,
  )
  const createTask = useCreateTask()
  const updateTask = useUpdateTask()
  const deleteTask = useDeleteTask()

  const openCreate = () => {
    setEditingTask(null)
    setIsDialogOpen(true)
  }

  const closeDialog = () => {
    setIsDialogOpen(false)
    setEditingTask(null)
  }

  const handleCreate = async (data: TaskFormData) => {
    try {
      await createTask.mutateAsync(data)
      closeDialog()
      toast({ title: 'Task created' })
    } catch {
      toast({ title: 'Failed to create task', variant: 'destructive' })
    }
  }

  const handleUpdate = async (data: TaskFormData) => {
    if (!editingTask) return
    try {
      await updateTask.mutateAsync({ id: editingTask.id, ...data })
      closeDialog()
      toast({ title: 'Task updated' })
    } catch {
      toast({ title: 'Failed to update task', variant: 'destructive' })
    }
  }

  const handleDelete = async (id: number) => {
    try {
      await deleteTask.mutateAsync(id)
      toast({ title: 'Task deleted' })
    } catch {
      toast({ title: 'Failed to delete task', variant: 'destructive' })
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-foreground">Tasks</h1>
        <Button onClick={openCreate}>
          <Plus className="mr-2 h-4 w-4" />
          New Task
        </Button>
      </div>

      {/* Task form dialog */}
      <Dialog open={isDialogOpen} onOpenChange={(open) => { if (!open) closeDialog() }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{editingTask ? 'Edit Task' : 'Create Task'}</DialogTitle>
          </DialogHeader>
          <TaskForm
            key={editingTask?.id || 'create'}
            initial={editingTask}
            onSubmit={editingTask ? handleUpdate : handleCreate}
            isLoading={createTask.isPending || updateTask.isPending}
          />
        </DialogContent>
      </Dialog>

      {/* Filters */}
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search tasks..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9"
          />
        </div>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-36">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value=" ">All</SelectItem>
            <SelectItem value="TODO">Todo</SelectItem>
            <SelectItem value="IN_PROGRESS">In Progress</SelectItem>
            <SelectItem value="COMPLETED">Completed</SelectItem>
          </SelectContent>
        </Select>
        <Select value={priorityFilter} onValueChange={setPriorityFilter}>
          <SelectTrigger className="w-36">
            <SelectValue placeholder="Priority" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value=" ">All</SelectItem>
            <SelectItem value="HIGH">High</SelectItem>
            <SelectItem value="MEDIUM">Medium</SelectItem>
            <SelectItem value="LOW">Low</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex justify-center py-12">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="rounded-lg border border-destructive/20 bg-destructive/5 p-4 text-sm text-destructive">
          Failed to load tasks. Please try again.
        </div>
      )}

      {/* Empty state */}
      {tasks?.length === 0 && (
        <div className="py-16 text-center">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-muted">
            <Plus className="h-6 w-6 text-muted-foreground" />
          </div>
          <h3 className="font-medium text-foreground">No tasks yet</h3>
          <p className="mt-1 text-sm text-muted-foreground">
            Create your first task to get started.
          </p>
        </div>
      )}

      {/* Task list */}
      {tasks && tasks.length > 0 && (
        <div className="space-y-2">
          {tasks.map((task) => {
            const sConfig = statusConfig[task.status]
            const pConfig = priorityConfig[task.priority]
            const StatusIcon = sConfig.icon
            const isOverdue = task.dueDate && new Date(task.dueDate) < new Date() && task.status !== 'COMPLETED'

            return (
              <div
                key={task.id}
                className="group flex items-start gap-3 rounded-lg border bg-card p-4 transition-all hover:shadow-sm animate-fade-in"
              >
                <StatusIcon className={`mt-0.5 h-5 w-5 ${sConfig.color} flex-shrink-0`} />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <h3 className="font-medium text-foreground truncate">
                      {task.title}
                    </h3>
                    {isOverdue && (
                      <AlertTriangle className="h-4 w-4 flex-shrink-0 text-destructive" title="Overdue" />
                    )}
                  </div>
                  {task.description && (
                    <p className="mt-1 text-sm text-muted-foreground line-clamp-2">
                      {task.description}
                    </p>
                  )}
                  <div className="mt-2 flex items-center gap-3 text-xs text-muted-foreground">
                    <span>{sConfig.label}</span>
                    <span className={`flex items-center gap-1 ${pConfig.color}`}>
                      <Flag className="h-3 w-3" />
                      {pConfig.label}
                    </span>
                    {task.dueDate && (
                      <span className={isOverdue ? 'text-destructive font-medium' : ''}>
                        Due: {new Date(task.dueDate).toLocaleDateString()}
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => {
                      setEditingTask(task)
                      setIsDialogOpen(true)
                    }}
                  >
                    <Edit3 className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handleDelete(task.id)}
                  >
                    <Trash2 className="h-4 w-4 text-destructive" />
                  </Button>
                </div>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}

function TaskForm({
  onSubmit,
  isLoading,
  initial,
}: {
  onSubmit: (data: TaskFormData) => void
  isLoading?: boolean
  initial?: Task | null
}) {
  const [title, setTitle] = useState(initial?.title || '')
  const [description, setDescription] = useState(initial?.description || '')
  const [status, setStatus] = useState<TaskStatus>(initial?.status || 'TODO')
  const [priority, setPriority] = useState<TaskPriority>(initial?.priority || 'MEDIUM')
  const [dueDate, setDueDate] = useState(initial?.dueDate || '')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim()) return
    onSubmit({
      title,
      description: description || undefined,
      status: status !== 'TODO' ? status : undefined,
      priority: priority !== 'MEDIUM' ? priority : undefined,
      dueDate: dueDate || undefined,
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <label className="text-sm font-medium">Title</label>
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="What needs to be done?"
          autoFocus
        />
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Description</label>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Optional details..."
          rows={3}
          className="flex w-full rounded-lg border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div className="space-y-2">
          <label className="text-sm font-medium">Status</label>
          <Select value={status} onValueChange={(v) => setStatus(v as TaskStatus)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="TODO">Todo</SelectItem>
              <SelectItem value="IN_PROGRESS">In Progress</SelectItem>
              <SelectItem value="COMPLETED">Completed</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium">Priority</label>
          <Select value={priority} onValueChange={(v) => setPriority(v as TaskPriority)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="LOW">Low</SelectItem>
              <SelectItem value="MEDIUM">Medium</SelectItem>
              <SelectItem value="HIGH">High</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Due Date</label>
        <Input
          type="date"
          value={dueDate}
          onChange={(e) => setDueDate(e.target.value)}
        />
      </div>

      <Button type="submit" className="w-full" disabled={isLoading || !title.trim()}>
        {isLoading ? 'Saving...' : initial ? 'Update Task' : 'Create Task'}
      </Button>
    </form>
  )
}
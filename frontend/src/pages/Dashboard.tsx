import { useState } from 'react'
import { useTasks, useCreateTask, useUpdateTask, useDeleteTask } from '@/hooks/useTasks'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Plus, Search, Loader2, Trash2, Edit3, AlertTriangle, Flag } from 'lucide-react'
import type { Task, TaskStatus, TaskPriority, TaskFormData } from '@/types'
import { useToast } from '@/hooks/use-toast'
import { cn } from '@/lib/utils'

const statusBadge: Record<TaskStatus, { label: string; bg: string; dot: string }> = {
  TODO: { label: 'À faire', bg: 'bg-muted text-muted-foreground', dot: 'bg-muted-foreground' },
  IN_PROGRESS: { label: 'En cours', bg: 'bg-secondary/10 text-secondary', dot: 'bg-secondary' },
  COMPLETED: { label: 'Terminé', bg: 'bg-primary/10 text-primary', dot: 'bg-primary' },
}

const priorityBar: Record<TaskPriority, string> = {
  LOW: 'bg-muted-foreground/30',
  MEDIUM: 'bg-secondary',
  HIGH: 'bg-destructive',
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
      toast({ title: 'Tâche créée' })
    } catch {
      toast({ title: 'Échec de la création', variant: 'destructive' })
    }
  }

  const handleUpdate = async (data: TaskFormData) => {
    if (!editingTask) return
    try {
      await updateTask.mutateAsync({ id: editingTask.id, ...data })
      closeDialog()
      toast({ title: 'Tâche modifiée' })
    } catch {
      toast({ title: 'Échec de la modification', variant: 'destructive' })
    }
  }

  const handleDelete = async (id: number) => {
    try {
      await deleteTask.mutateAsync(id)
      toast({ title: 'Tâche supprimée' })
    } catch {
      toast({ title: 'Échec de la suppression', variant: 'destructive' })
    }
  }

  return (
    <div className="space-y-8">
      {/* ── Header ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-foreground">
            Mes tâches
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {tasks ? `${tasks.length} tâche${tasks.length > 1 ? 's' : ''}` : 'Gérez vos activités'}
          </p>
        </div>
        <Button onClick={openCreate} className="bg-primary hover:bg-primary-600 shadow-sm">
          <Plus className="mr-2 h-4 w-4" />
          Nouvelle tâche
        </Button>
      </div>

      {/* ── Filters ── */}
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Rechercher..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9 bg-card border-muted"
          />
        </div>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-36 bg-card border-muted">
            <SelectValue placeholder="Statut" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value=" ">Tous</SelectItem>
            <SelectItem value="TODO">À faire</SelectItem>
            <SelectItem value="IN_PROGRESS">En cours</SelectItem>
            <SelectItem value="COMPLETED">Terminé</SelectItem>
          </SelectContent>
        </Select>
        <Select value={priorityFilter} onValueChange={setPriorityFilter}>
          <SelectTrigger className="w-36 bg-card border-muted">
            <SelectValue placeholder="Priorité" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value=" ">Toutes</SelectItem>
            <SelectItem value="HIGH">Haute</SelectItem>
            <SelectItem value="MEDIUM">Moyenne</SelectItem>
            <SelectItem value="LOW">Basse</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* ── Loading ── */}
      {isLoading && (
        <div className="flex justify-center py-20">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      )}

      {/* ── Error ── */}
      {error && (
        <div className="rounded-xl border border-destructive/20 bg-destructive/5 p-5 text-sm text-destructive">
          <p className="font-medium">Erreur de chargement</p>
          <p className="mt-1 text-destructive/80">Impossible de récupérer vos tâches. Veuillez réessayer.</p>
        </div>
      )}

      {/* ── Empty state ── */}
      {tasks?.length === 0 && (
        <div className="py-20 text-center">
          <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-primary/10 to-secondary/10">
            <Flag className="h-7 w-7 text-primary" />
          </div>
          <h3 className="text-lg font-semibold text-foreground">Aucune tâche pour le moment</h3>
          <p className="mt-2 text-sm text-muted-foreground max-w-xs mx-auto">
            Créez votre première tâche et organisez votre travail en toute simplicité.
          </p>
          <Button onClick={openCreate} className="mt-6 bg-primary hover:bg-primary-600 shadow-sm">
            <Plus className="mr-2 h-4 w-4" />
            Créer une tâche
          </Button>
        </div>
      )}

      {/* ── Task list ── */}
      {tasks && tasks.length > 0 && (
        <div className="space-y-3">
          {tasks.map((task) => {
            const badge = statusBadge[task.status]
            const barColor = priorityBar[task.priority]
            const isOverdue = task.dueDate && new Date(task.dueDate) < new Date() && task.status !== 'COMPLETED'

            return (
              <div
                key={task.id}
                className="group relative flex items-start gap-4 rounded-xl border border-muted bg-card p-5 transition-all hover:border-primary/20 hover:shadow-md hover:shadow-primary/5 animate-fade-in"
              >
                {/* Priority bar */}
                <div className={cn('absolute left-0 top-3 bottom-3 w-1 rounded-full', barColor)} />

                {/* Content */}
                <div className="flex-1 min-w-0 pl-3">
                  <div className="flex items-start gap-2">
                    <h3 className={cn(
                      'font-semibold text-foreground truncate',
                      task.status === 'COMPLETED' && 'line-through text-muted-foreground',
                    )}>
                      {task.title}
                    </h3>
                    {isOverdue && (
                      <AlertTriangle className="mt-0.5 h-4 w-4 flex-shrink-0 text-destructive" />
                    )}
                  </div>

                  {task.description && (
                    <p className="mt-1.5 text-sm text-muted-foreground line-clamp-2 leading-relaxed">
                      {task.description}
                    </p>
                  )}

                  <div className="mt-3 flex flex-wrap items-center gap-3">
                    {/* Status badge */}
                    <span className={cn('inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium', badge.bg)}>
                      <span className={cn('h-1.5 w-1.5 rounded-full', badge.dot)} />
                      {badge.label}
                    </span>

                    {/* Priority */}
                    <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
                      <Flag className="h-3 w-3" />
                      {task.priority === 'HIGH' ? 'Haute' : task.priority === 'MEDIUM' ? 'Moyenne' : 'Basse'}
                    </span>

                    {/* Due date */}
                    {task.dueDate && (
                      <span className={cn(
                        'text-xs',
                        isOverdue ? 'text-destructive font-medium' : 'text-muted-foreground',
                      )}>
                        {isOverdue ? 'En retard' : 'Échéance'} : {new Date(task.dueDate).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
                      </span>
                    )}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-8 w-8 text-muted-foreground hover:text-foreground"
                    onClick={() => {
                      setEditingTask(task)
                      setIsDialogOpen(true)
                    }}
                  >
                    <Edit3 className="h-3.5 w-3.5" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-8 w-8 text-muted-foreground hover:text-destructive"
                    onClick={() => handleDelete(task.id)}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
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
    <form onSubmit={handleSubmit} className="space-y-5">
      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground">Titre</label>
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Que devez-vous faire ?"
          autoFocus
          className="border-muted focus:border-secondary"
        />
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground">Description</label>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Ajoutez des détails..."
          rows={3}
          className="flex w-full rounded-xl border border-muted bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-secondary focus-visible:ring-offset-2"
        />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div className="space-y-1.5">
          <label className="text-sm font-medium text-foreground">Statut</label>
          <Select value={status} onValueChange={(v) => setStatus(v as TaskStatus)}>
            <SelectTrigger className="border-muted">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="TODO">À faire</SelectItem>
              <SelectItem value="IN_PROGRESS">En cours</SelectItem>
              <SelectItem value="COMPLETED">Terminé</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1.5">
          <label className="text-sm font-medium text-foreground">Priorité</label>
          <Select value={priority} onValueChange={(v) => setPriority(v as TaskPriority)}>
            <SelectTrigger className="border-muted">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="LOW">Basse</SelectItem>
              <SelectItem value="MEDIUM">Moyenne</SelectItem>
              <SelectItem value="HIGH">Haute</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground">Date d'échéance</label>
        <Input
          type="date"
          value={dueDate}
          onChange={(e) => setDueDate(e.target.value)}
          className="border-muted focus:border-secondary"
        />
      </div>

      <Button type="submit" className="w-full bg-primary hover:bg-primary-600 shadow-sm" disabled={isLoading || !title.trim()}>
        {isLoading ? 'Enregistrement...' : initial ? 'Modifier la tâche' : 'Créer la tâche'}
      </Button>
    </form>
  )
}
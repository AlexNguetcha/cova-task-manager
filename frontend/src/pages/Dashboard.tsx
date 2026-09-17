import { useState } from 'react'
import { useTasks, useCreateTask, useUpdateTask, useDeleteTask } from '@/hooks/useTasks'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Plus, LayoutList, LayoutGrid, Flag } from 'lucide-react'
import type { Task, TaskFormData } from '@/types'
import { useToast } from '@/contexts/ToastContext'
import { TaskSkeleton } from '@/components/Skeleton'
import { TaskCard } from '@/components/TaskCard'
import { TaskFilters } from '@/components/TaskFilters'
import { ViewTaskDialog, DeleteTaskDialog } from '@/components/TaskDialogs'
import { TaskPagination } from '@/components/TaskPagination'
import { TaskForm } from '@/components/TaskForm'

export default function Dashboard() {
  const [statusFilter, setStatusFilter] = useState('')
  const [priorityFilter, setPriorityFilter] = useState('')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(0)
  const [editingTask, setEditingTask] = useState<Task | null>(null)
  const [viewTask, setViewTask] = useState<Task | null>(null)
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<Task | null>(null)
  const [viewMode, setViewMode] = useState<'list' | 'grid'>('list')
  const { toast } = useToast()

  const { data, isLoading, error } = useTasks(
    statusFilter || undefined,
    priorityFilter || undefined,
    search || undefined,
    page,
  )
  const tasks = data?.content
  const totalPages = data?.totalPages ?? 0
  const totalElements = data?.totalElements ?? 0
  const pageStart = page * 10
  const createTask = useCreateTask()
  const updateTask = useUpdateTask()
  const deleteTask = useDeleteTask()

  const openCreate = () => { setEditingTask(null); setIsDialogOpen(true) }
  const closeDialog = () => { setIsDialogOpen(false); setEditingTask(null) }

  const handleCreate = async (formData: TaskFormData) => {
    try {
      await createTask.mutateAsync(formData)
      closeDialog(); setPage(0)
      toast({ title: 'Tâche créée avec succès', description: formData.title })
    } catch {
      toast({ title: 'Échec de la création', variant: 'destructive' })
    }
  }

  const handleUpdate = async (formData: TaskFormData) => {
    if (!editingTask) return
    try {
      await updateTask.mutateAsync({ id: editingTask.id, ...formData })
      closeDialog()
      toast({ title: 'Tâche modifiée avec succès', description: formData.title })
    } catch {
      toast({ title: 'Échec de la modification', variant: 'destructive' })
    }
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try {
      await deleteTask.mutateAsync(deleteTarget.id)
      setDeleteTarget(null)
      toast({ title: 'Tâche supprimée', description: deleteTarget.title })
    } catch {
      toast({ title: 'Échec de la suppression', variant: 'destructive' })
    }
  }

  const handleSearch = (v: string) => { setSearch(v); setPage(0) }

  return (
    <div className="space-y-8">
      {/* ── Header ── */}
      <div className="flex items-start sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-foreground">Mes tâches</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {totalElements > 0 ? `${totalElements} tâche${totalElements > 1 ? 's' : ''}` : 'Gérez vos activités'}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-shrink-0">
          <div className="hidden sm:flex border border-muted rounded-lg p-0.5 bg-card">
            <Button variant="ghost" size="icon"
              className={`h-8 w-8 ${viewMode === 'list' ? 'bg-muted text-foreground' : 'text-muted-foreground'}`}
              onClick={() => setViewMode('list')}
            ><LayoutList className="h-4 w-4" /></Button>
            <Button variant="ghost" size="icon"
              className={`h-8 w-8 ${viewMode === 'grid' ? 'bg-muted text-foreground' : 'text-muted-foreground'}`}
              onClick={() => setViewMode('grid')}
            ><LayoutGrid className="h-4 w-4" /></Button>
          </div>
          <Button onClick={openCreate} className="bg-primary hover:bg-primary-600 shadow-sm">
            <Plus className="mr-2 h-4 w-4" />
            <span className="hidden sm:inline">Nouvelle tâche</span>
            <span className="sm:hidden">Créer</span>
          </Button>
        </div>
      </div>

      {/* ── Dialogs ── */}
      <DeleteTaskDialog task={deleteTarget} isPending={deleteTask.isPending} onConfirm={handleDelete} onClose={() => setDeleteTarget(null)} />
      <ViewTaskDialog task={viewTask} onClose={() => setViewTask(null)} />

      <Dialog open={isDialogOpen} onOpenChange={closeDialog}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{editingTask ? 'Modifier la tâche' : 'Nouvelle tâche'}</DialogTitle>
          </DialogHeader>
          <TaskForm
            initial={editingTask}
            onSubmit={editingTask ? handleUpdate : handleCreate}
            isLoading={createTask.isPending || updateTask.isPending}
          />
        </DialogContent>
      </Dialog>

      {/* ── Filters ── */}
      <TaskFilters
        search={search}
        statusFilter={statusFilter}
        priorityFilter={priorityFilter}
        onSearchChange={handleSearch}
        onStatusChange={(v) => { setStatusFilter(v); setPage(0) }}
        onPriorityChange={(v) => { setPriorityFilter(v); setPage(0) }}
      />

      {/* ── Loading ── */}
      {isLoading && (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => <TaskSkeleton key={i} />)}
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
      {!isLoading && tasks?.length === 0 && (
        <div className="py-20 text-center">
          <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-primary/10 to-secondary/10">
            <Flag className="h-7 w-7 text-primary" />
          </div>
          <h3 className="text-lg font-semibold text-foreground">Aucune tâche pour le moment</h3>
          <p className="mt-2 text-sm text-muted-foreground max-w-xs mx-auto">
            Créez votre première tâche et organisez votre travail en toute simplicité.
          </p>
          <Button onClick={openCreate} className="mt-6 bg-primary hover:bg-primary-600 shadow-sm">
            <Plus className="mr-2 h-4 w-4" /> Créer une tâche
          </Button>
        </div>
      )}

      {/* ── Task list / grid ── */}
      {!isLoading && tasks && tasks.length > 0 && (
        <div className={viewMode === 'grid' ? 'grid grid-cols-1 sm:grid-cols-2 gap-4' : 'space-y-3'}>
          {tasks.map((task, index) => (
            <TaskCard
              key={task.id}
              task={task}
              taskNumber={pageStart + index + 1}
              onView={setViewTask}
              onEdit={(t) => { setEditingTask(t); setIsDialogOpen(true) }}
              onDelete={setDeleteTarget}
            />
          ))}
          <TaskPagination page={page} totalPages={totalPages} onPageChange={setPage} />
        </div>
      )}
    </div>
  )
}
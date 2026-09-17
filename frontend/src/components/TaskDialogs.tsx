import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Flag } from 'lucide-react'
import type { Task, TaskStatus } from '@/types'
import { cn } from '@/lib/utils'

const statusBadge: Record<TaskStatus, { label: string; bg: string; dot: string }> = {
  TODO: { label: 'À faire', bg: 'bg-muted text-muted-foreground', dot: 'bg-muted-foreground' },
  IN_PROGRESS: { label: 'En cours', bg: 'bg-secondary/10 text-secondary', dot: 'bg-secondary' },
  COMPLETED: { label: 'Terminé', bg: 'bg-primary/10 text-primary', dot: 'bg-primary' },
}

interface DeleteTaskDialogProps {
  task: Task | null
  isPending: boolean
  onConfirm: () => void
  onClose: () => void
}

export function DeleteTaskDialog({ task, isPending, onConfirm, onClose }: DeleteTaskDialogProps) {
  return (
    <Dialog open={!!task} onOpenChange={(open) => { if (!open) onClose() }}>
      <DialogContent className="max-w-sm">
        <DialogHeader>
          <DialogTitle>Supprimer la tâche</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <p className="text-sm text-muted-foreground">
            Êtes-vous sûr de vouloir supprimer cette tâche ?
          </p>
          {task && (
            <p className="text-sm font-medium text-foreground bg-muted rounded-lg px-3 py-2">
              {task.title}
            </p>
          )}
          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={onClose}>Annuler</Button>
            <Button variant="destructive" onClick={onConfirm} disabled={isPending}>
              {isPending ? 'Suppression...' : 'Supprimer'}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

interface ViewTaskDialogProps {
  task: Task | null
  onClose: () => void
}

export function ViewTaskDialog({ task, onClose }: ViewTaskDialogProps) {
  return (
    <Dialog open={!!task} onOpenChange={(open) => { if (!open) onClose() }}>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>{task?.title}</DialogTitle>
        </DialogHeader>
        {task && (
          <div className="space-y-5">
            {task.description ? (
              <div>
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider mb-1.5">Description</p>
                <p className="text-sm text-foreground leading-relaxed whitespace-pre-wrap">{task.description}</p>
              </div>
            ) : (
              <p className="text-sm text-muted-foreground italic">Aucune description</p>
            )}

            <div className="flex flex-wrap gap-x-6 gap-y-3">
              <div>
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider mb-1">Statut</p>
                <span className={cn('inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium', statusBadge[task.status].bg)}>
                  <span className={cn('h-1.5 w-1.5 rounded-full', statusBadge[task.status].dot)} />
                  {statusBadge[task.status].label}
                </span>
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider mb-1">Priorité</p>
                <span className="inline-flex items-center gap-1 text-sm text-foreground">
                  <Flag className="h-3.5 w-3.5" />
                  {task.priority === 'HIGH' ? 'Haute' : task.priority === 'MEDIUM' ? 'Moyenne' : 'Basse'}
                </span>
              </div>
              {task.dueDate && (
                <div>
                  <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider mb-1">Échéance</p>
                  <p className="text-sm text-foreground">
                    {new Date(task.dueDate).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })}
                  </p>
                </div>
              )}
            </div>

            <div className="flex flex-wrap gap-x-6 gap-y-3 text-xs text-muted-foreground pt-3 border-t border-muted">
              <div>
                <span className="font-medium">Créée</span> : {new Date(task.createdAt).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
              </div>
              <div>
                <span className="font-medium">Modifiée</span> : {new Date(task.updatedAt).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
              </div>
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}
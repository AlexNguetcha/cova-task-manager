import { Button } from '@/components/ui/button'
import { Trash2, Edit3, Eye, AlertTriangle, Flag, Hash } from 'lucide-react'
import type { Task, TaskStatus, TaskPriority } from '@/types'
import { cn } from '@/lib/utils'

interface TaskCardProps {
  task: Task
  taskNumber: number
  onView: (task: Task) => void
  onEdit: (task: Task) => void
  onDelete: (task: Task) => void
}

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

export function TaskCard({ task, taskNumber, onView, onEdit, onDelete }: TaskCardProps) {
  const badge = statusBadge[task.status]
  const barColor = priorityBar[task.priority]
  const isOverdue = task.dueDate && new Date(task.dueDate) < new Date() && task.status !== 'COMPLETED'

  return (
    <div
      className="group relative rounded-xl border border-muted bg-card p-4 sm:p-5 transition-all hover:border-primary/20 hover:shadow-md hover:shadow-primary/5 animate-fade-in cursor-pointer"
      onClick={() => onView(task)}
    >
      {/* Priority bar */}
      <div className={cn('absolute left-0 top-3 bottom-3 w-1 rounded-full', barColor)} />

      {/* Top row: content + actions */}
      <div className="flex items-start gap-3">
        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-start gap-2">
            <h3 className={cn(
              'font-semibold text-foreground',
              task.status === 'COMPLETED' && 'line-through text-muted-foreground',
            )}>
              {task.title}
            </h3>
            {isOverdue && (
              <AlertTriangle className="mt-0.5 h-4 w-4 flex-shrink-0 text-destructive" />
            )}
          </div>

          {task.description && (
            <p className="mt-1.5 text-sm text-muted-foreground leading-relaxed break-words line-clamp-2">
              {task.description}
            </p>
          )}
        </div>

        {/* Actions (desktop: on hover, mobile: always visible) */}
        <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity max-sm:opacity-100 flex-shrink-0" onClick={(e) => e.stopPropagation()}>
          <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-foreground" title="Voir les détails" onClick={() => onView(task)}>
            <Eye className="h-3.5 w-3.5" />
          </Button>
          <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-foreground" title="Modifier" onClick={() => onEdit(task)}>
            <Edit3 className="h-3.5 w-3.5" />
          </Button>
          <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-destructive" title="Supprimer" onClick={() => onDelete(task)}>
            <Trash2 className="h-3.5 w-3.5" />
          </Button>
        </div>
      </div>

      {/* Bottom row: metadata */}
      <div className="mt-3 flex flex-wrap items-center gap-x-3 gap-y-1.5">
        <span className="inline-flex items-center gap-1 rounded-md bg-muted/50 px-2 py-0.5 text-xs font-medium text-muted-foreground/60">
          <Hash className="h-3 w-3" />
          {taskNumber}
        </span>
        <span className={cn('inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium', badge.bg)}>
          <span className={cn('h-1.5 w-1.5 rounded-full', badge.dot)} />
          {badge.label}
        </span>
        <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
          <Flag className="h-3 w-3" />
          {task.priority === 'HIGH' ? 'Haute' : task.priority === 'MEDIUM' ? 'Moyenne' : 'Basse'}
        </span>
        {task.dueDate && (
          <span className={cn('text-xs', isOverdue ? 'text-destructive font-medium' : 'text-muted-foreground')}>
            {isOverdue ? 'En retard' : 'Échéance'} : {new Date(task.dueDate).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
          </span>
        )}
      </div>
    </div>
  )
}
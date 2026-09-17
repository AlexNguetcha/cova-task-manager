import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Search } from 'lucide-react'

interface TaskFiltersProps {
  search: string
  statusFilter: string
  priorityFilter: string
  onSearchChange: (value: string) => void
  onStatusChange: (value: string) => void
  onPriorityChange: (value: string) => void
}

export function TaskFilters({
  search,
  statusFilter,
  priorityFilter,
  onSearchChange,
  onStatusChange,
  onPriorityChange,
}: TaskFiltersProps) {
  return (
    <div className="flex flex-col sm:flex-row gap-3">
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder="Rechercher..."
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          className="pl-9 bg-card border-muted"
        />
      </div>
      <div className="flex gap-3">
        <Select value={statusFilter} onValueChange={onStatusChange}>
          <SelectTrigger className="flex-1 sm:w-36 bg-card border-muted">
            <SelectValue placeholder="Statut" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value=" ">Tous</SelectItem>
            <SelectItem value="TODO">À faire</SelectItem>
            <SelectItem value="IN_PROGRESS">En cours</SelectItem>
            <SelectItem value="COMPLETED">Terminé</SelectItem>
          </SelectContent>
        </Select>
        <Select value={priorityFilter} onValueChange={onPriorityChange}>
          <SelectTrigger className="flex-1 sm:w-36 bg-card border-muted">
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
    </div>
  )
}
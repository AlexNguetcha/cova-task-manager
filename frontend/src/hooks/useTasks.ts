import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '@/lib/api'
import type { Task, TaskFormData } from '@/types'

export function useTasks(status?: string, priority?: string, search?: string) {
  const params = new URLSearchParams()
  if (status) params.set('status', status)
  if (priority) params.set('priority', priority)
  if (search) params.set('search', search)
  const qs = params.toString()

  return useQuery({
    queryKey: ['tasks', { status, priority, search }],
    queryFn: async () => {
      const { data } = await api.get<Task[]>(`/tasks${qs ? `?${qs}` : ''}`)
      return data
    },
  })
}

export function useCreateTask() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (task: TaskFormData) => {
      const { data } = await api.post<Task>('/tasks', task)
      return data
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['tasks'] }),
  })
}

export function useUpdateTask() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...task }: TaskFormData & { id: number }) => {
      const { data } = await api.put<Task>(`/tasks/${id}`, task)
      return data
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['tasks'] }),
  })
}

export function useDeleteTask() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: number) => {
      await api.delete(`/tasks/${id}`)
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['tasks'] }),
  })
}
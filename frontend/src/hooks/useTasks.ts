import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '@/lib/api'
import type { Task, TaskFormData, PaginatedResponse } from '@/types'

export function useTasks(status?: string, priority?: string, search?: string, page = 0) {
  const params = new URLSearchParams()
  if (status) params.set('status', status)
  if (priority) params.set('priority', priority)
  if (search) params.set('search', search)
  params.set('page', String(page))
  params.set('size', '10')
  const qs = params.toString()

  return useQuery({
    queryKey: ['tasks', { status, priority, search, page }],
    queryFn: async () => {
      const { data } = await api.get<Task[] | PaginatedResponse<Task>>(`/tasks${qs ? `?${qs}` : ''}`)
      // Handle both paginated and plain array responses
      if (Array.isArray(data)) {
        return { content: data, totalPages: 1, totalElements: data.length, number: 0, size: data.length, first: true, last: true }
      }
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
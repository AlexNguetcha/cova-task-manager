export interface User {
  id: number
  name: string
  email: string
}

export interface AuthResponse {
  accessToken: string
  refreshToken: string
  tokenType: string
  user: User
}

export interface Task {
  id: number
  title: string
  description: string | null
  status: 'TODO' | 'IN_PROGRESS' | 'COMPLETED'
  createdAt: string
  updatedAt: string
}

export type TaskStatus = Task['status']

export interface TaskFormData {
  title: string
  description?: string
  status?: TaskStatus
}

export interface LoginFormData {
  email: string
  password: string
}

export interface RegisterFormData {
  name: string
  email: string
  password: string
}
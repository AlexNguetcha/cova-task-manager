import { createContext, useContext, useState, useCallback, type ReactNode } from 'react'
import type { User, LoginFormData, RegisterFormData } from '@/types'
import api from '@/lib/api'

interface AuthContextType {
  user: User | null
  isLoading: boolean
  login: (data: LoginFormData) => Promise<void>
  register: (data: RegisterFormData) => Promise<void>
  logout: () => void
  isAuthenticated: boolean
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    const stored = localStorage.getItem('user')
    return stored ? JSON.parse(stored) : null
  })
  const [isLoading, setIsLoading] = useState(false)

  const login = useCallback(async (data: LoginFormData) => {
    setIsLoading(true)
    try {
      const res = await api.post('/auth/login', data)
      localStorage.setItem('accessToken', res.data.accessToken)
      localStorage.setItem('refreshToken', res.data.refreshToken)
      localStorage.setItem('user', JSON.stringify(res.data.user))
      setUser(res.data.user)
    } finally {
      setIsLoading(false)
    }
  }, [])

  const register = useCallback(async (data: RegisterFormData) => {
    setIsLoading(true)
    try {
      const res = await api.post('/auth/register', data)
      localStorage.setItem('accessToken', res.data.accessToken)
      localStorage.setItem('refreshToken', res.data.refreshToken)
      localStorage.setItem('user', JSON.stringify(res.data.user))
      setUser(res.data.user)
    } finally {
      setIsLoading(false)
    }
  }, [])

  const logout = useCallback(() => {
    localStorage.clear()
    setUser(null)
  }, [])

  return (
    <AuthContext.Provider
      value={{ user, isLoading, login, register, logout, isAuthenticated: !!user }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
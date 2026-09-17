import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { LogOut, ListTodo } from 'lucide-react'
import { Button } from '@/components/ui/button'

export function ProtectedLayout() {
  const { isAuthenticated, user, logout } = useAuth()

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/5 via-background to-secondary/5">
      {/* Header */}
      <header className="border-b border-muted bg-card/80 backdrop-blur-sm sticky top-0 z-10">
        <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-4">
          <div className="flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-primary-600 shadow-sm">
              <ListTodo className="h-5 w-5 text-white" />
            </div>
            <span className="text-lg font-bold tracking-tight text-primary">Task Manager</span>
          </div>

          <div className="flex items-center gap-3">
            <span className="text-sm font-medium text-muted-foreground">
              {user?.name}
            </span>
            <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-foreground" onClick={logout}>
              <LogOut className="mr-2 h-4 w-4" />
              Déconnexion
            </Button>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="mx-auto max-w-5xl px-4 py-8">
        <Outlet />
      </main>
    </div>
  )
}
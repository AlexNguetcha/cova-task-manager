import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { ListTodo, CheckCircle2 } from 'lucide-react'

const loginSchema = z.object({
  email: z.string().email('Adresse email invalide'),
  password: z.string().min(1, 'Mot de passe requis'),
})

type LoginForm = z.infer<typeof loginSchema>

export default function Login() {
  const { login, isLoading } = useAuth()
  const navigate = useNavigate()

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors },
  } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginForm) => {
    try {
      await login(data)
      navigate('/')
    } catch (err: any) {
      const message = err.response?.data?.message || 'Identifiants invalides'
      setError('email', { message })
    }
  }

  return (
    <div className="flex min-h-screen">
      {/* ── Left Panel ── */}
      <div className="hidden lg:flex lg:w-1/2 relative bg-gradient-to-br from-primary via-primary-700 to-primary-900 items-center justify-center p-12 overflow-hidden">
        {/* Decorative circles */}
        <div className="absolute -top-40 -right-40 h-80 w-80 rounded-full bg-white/5" />
        <div className="absolute -bottom-20 -left-20 h-60 w-60 rounded-full bg-white/5" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-96 w-96 rounded-full bg-white/5" />

        <div className="relative text-center">
          <div className="mx-auto mb-8 flex h-20 w-20 items-center justify-center rounded-3xl bg-white/10 backdrop-blur-sm">
            <ListTodo className="h-10 w-10 text-white" />
          </div>
          <h2 className="text-3xl font-bold text-white">Task Manager</h2>
          <p className="mt-4 text-lg text-white/70 max-w-sm mx-auto leading-relaxed">
            Organisez, suivez et gérez vos tâches en toute simplicité.
          </p>
          <div className="mt-10 space-y-4 text-left max-w-xs mx-auto">
            {['Priorités et échéances', 'Filtres intelligents', 'Interface épurée'].map((item) => (
              <div key={item} className="flex items-center gap-3 text-white/80">
                <CheckCircle2 className="h-5 w-5 text-white/60 flex-shrink-0" />
                <span className="text-sm">{item}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Right Panel ── */}
      <div className="flex-1 flex items-center justify-center px-6 bg-gradient-to-br from-primary/[0.02] via-background to-secondary/[0.02]">
        <div className="w-full max-w-md animate-fade-in">
          {/* Mobile logo */}
          <div className="lg:hidden mb-10 text-center">
            <div className="mx-auto mb-5 flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-primary-600 shadow-lg shadow-primary/20">
              <ListTodo className="h-7 w-7 text-white" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight text-foreground">Bon retour</h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Connectez-vous à votre espace
            </p>
          </div>

          {/* Desktop title */}
          <div className="hidden lg:block mb-8">
            <h1 className="text-2xl font-bold tracking-tight text-foreground">Bon retour</h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Connectez-vous à votre compte
            </p>
          </div>

          {/* Card */}
          <div className="rounded-2xl border border-muted/60 bg-card p-8 shadow-sm shadow-primary/5">
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
              <div className="space-y-1.5">
                <Label htmlFor="email" className="text-sm font-medium">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="vous@exemple.com"
                  className="h-11 border-muted/60 focus:border-secondary transition-colors"
                  {...register('email')}
                />
                {errors.email && (
                  <p className="text-xs text-destructive">{errors.email.message}</p>
                )}
              </div>

              <div className="space-y-1.5">
                <Label htmlFor="password" className="text-sm font-medium">Mot de passe</Label>
                <Input
                  id="password"
                  type="password"
                  placeholder="Entrez votre mot de passe"
                  className="h-11 border-muted/60 focus:border-secondary transition-colors"
                  {...register('password')}
                />
                {errors.password && (
                  <p className="text-xs text-destructive">{errors.password.message}</p>
                )}
              </div>

              <Button type="submit" className="w-full h-11 bg-primary hover:bg-primary-600 shadow-sm shadow-primary/20 text-sm font-medium" disabled={isLoading}>
                {isLoading ? 'Connexion...' : 'Se connecter'}
              </Button>
            </form>

            <div className="mt-8 pt-6 border-t border-muted/40 text-center">
              <p className="text-sm text-muted-foreground">
                Pas encore de compte ?{' '}
                <Link to="/register" className="font-semibold text-primary hover:text-primary-600 transition-colors">
                  S'inscrire
                </Link>
              </p>
            </div>
          </div>

          {/* Demo hint */}
          <p className="mt-6 text-center text-xs text-muted-foreground/60">
            Démo : demo@cova.africa / demo1234
          </p>
        </div>
      </div>
    </div>
  )
}
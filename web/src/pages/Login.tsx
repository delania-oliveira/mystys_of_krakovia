import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { toast } from 'sonner';
import { AlertTriangle, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { useAuth } from '@/hooks/useAuth';

import { api } from '../../api/axios'
import axios from 'axios';

const LoginSchema = z.object({
  username: z.string().min(3, { message: 'O nome de usuário é obrigatório' }),
  password: z.string().min(8, { message: 'A senha é obrigatória' }),
});

type LoginSchemaType = z.infer<typeof LoginSchema>;



export function Login() {
  const { login } = useAuth()
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formError, setFormError] = useState('');
  const navigate = useNavigate();

  const form = useForm<LoginSchemaType>({
    resolver: zodResolver(LoginSchema),
    defaultValues: { username: '', password: '' }
  })

  async function onSubmit(data: LoginSchemaType) {
    setIsSubmitting(true)
    setFormError('')

    try {
      const response = await api.post('/login', data)
      const { token } = response.data

      await login(token)

      toast.success('Login bem-sucedido!', {
        description: `Bem-vindo(a) de volta, ${data.username}`
      })

      setTimeout(() => navigate('/profile'), 0)

    } catch (error) {
      toast.error('Falha no login.')

      if (axios.isAxiosError(error) && error.response) {
        setFormError(error.response.data.message || 'Usuário ou senha inválidos.')
      } else {
        setFormError('Não foi possível conectar ao servidor. Tente novamente mais tarde.')
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <Card className="w-full max-w-md bg-black/60 border-gray-700 text-white">
      <CardHeader className="text-center">
        <CardTitle className="text-3xl font-bold">Acessar Conta</CardTitle>
        <CardDescription className="text-gray-400">
          Bem-vindo(a) de volta! Faça login para continuar.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {formError && (
          <Alert variant="destructive" className="mb-4">
            <AlertTriangle className="h-4 w-4" />
            <AlertTitle>Erro de Autenticação.</AlertTitle>
            <AlertDescription>{formError}</AlertDescription>
          </Alert>
        )}

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <FormField
              control={form.control}
              name="username"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Nome de Usuário</FormLabel>
                  <FormControl>
                    <Input placeholder="seu_usuario" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="password"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Senha</FormLabel>
                  <FormControl>
                    <Input type="password" placeholder="********" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button type="submit" size="lg" className="w-full" disabled={isSubmitting}>
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {isSubmitting ? 'Entrando...' : 'Entrar'}
            </Button>
          </form>
        </Form>
        <p className="mt-6 text-center text-sm text-gray-400">
          Não tem uma conta?{' '}
          <Link to="/register" className="font-semibold text-white hover:underline">
            Crie uma conta
          </Link>
        </p>
      </CardContent>
    </Card>
  );
}

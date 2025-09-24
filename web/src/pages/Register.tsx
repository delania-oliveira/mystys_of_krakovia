import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { toast } from 'sonner';
import { AlertTriangle, Loader2, CheckCircle2 } from 'lucide-react';
import { useDebounce } from '@/hooks/use-debounce';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { api } from '../../api/axios'

const RegisterSchema = z.object({
  username: z.string()
    .min(3, { message: 'O nome de usuário deve ter pelo menos 3 caracteres.' })
    .regex(/^[a-zA-Z0-9_]+$/, { message: 'Apenas letras, números e underline são permitidos.' }),
  password: z.string()
    .min(8, { message: 'A senha deve ter pelo menos 8 caracteres.' }),
});

type RegisterSchemaType = z.infer<typeof RegisterSchema>;

// Função que simula a chamada a API para verificar o username
async function checkUsernameAvailability(username: string): Promise<boolean> {
  const response = await api.post('/check_username', { username: username })
  return response.data.available;
}

export function Register() {
  const [isCheckingUsername, setIsCheckingUsername] = useState(false);
  const [isUsernameAvailable, setIsUsernameAvailable] = useState<boolean | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formError, setFormError] = useState('');
  const navigate = useNavigate();

  const form = useForm<RegisterSchemaType>({
    resolver: zodResolver(RegisterSchema),
    defaultValues: { username: '', password: '' },
    mode: 'onChange',
  });

  const watchedUsername = form.watch('username');
  const debouncedUsername = useDebounce(watchedUsername, 500);

  useEffect(() => {
    const { success } = RegisterSchema.shape.username.safeParse(debouncedUsername);
    if (!debouncedUsername || !success) {
      setIsUsernameAvailable(null);
      return;
    }

    async function checkUsername() {
      setIsCheckingUsername(true);
      setIsUsernameAvailable(null);
      const isAvailable = await checkUsernameAvailability(debouncedUsername);
      setIsUsernameAvailable(isAvailable);
      setIsCheckingUsername(false);

      if (!isAvailable) {
        form.setError('username', {
          type: 'manual',
          message: 'Este nome de usuário já está em uso.',
        });
      } else {
        if (form.formState.errors.username?.type === 'manual') {
          form.clearErrors('username');
        }
      }
    }

    checkUsername();
  }, [debouncedUsername, form]);

  async function onSubmit(data: RegisterSchemaType) {
    setIsSubmitting(true);
    setFormError('');

    const isAvailable = await checkUsernameAvailability(data.username);
    if (!isAvailable) {
      form.setError('username', { type: 'manual', message: 'Este nome de usuário já está em uso.' });
      setIsSubmitting(false);
      return;
    } else {
      api.post("/register", {username: data.username, password: data.password})
      toast.success('Conta criada com sucesso!', {
        description: `Bem-vindo(a), ${data.username}!`,
      });
      setTimeout(() => navigate('/'), 2000);
    }

  }

  return (
    <Card className="w-full max-w-md bg-black/60 border-gray-700 text-white">
      <CardHeader className="text-center">
        <CardTitle className="text-3xl font-bold">Criar Conta</CardTitle>
        <CardDescription className="text-gray-400">
          Use um nome de usuário e senha para se registrar.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {formError && (
          <Alert variant="destructive" className="mb-4">
            <AlertTriangle className="h-4 w-4" />
            <AlertTitle>Erro de Cadastro</AlertTitle>
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
                    <div className="relative">
                      <Input placeholder="seu_usuario" {...field} />
                      {/* 4. Feedback visual em tempo real */}
                      <div className="absolute inset-y-0 right-0 pr-3 flex items-center text-sm leading-5">
                        {isCheckingUsername && <Loader2 className="h-4 w-4 animate-spin text-gray-400" />}
                        {!isCheckingUsername && isUsernameAvailable === true && <CheckCircle2 className="h-4 w-4 text-green-500" />}
                      </div>
                    </div>
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
                  <FormControl><Input type="password" placeholder="********" {...field} /></FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button type="submit" size="lg" className="w-full" disabled={isSubmitting || isCheckingUsername}>
              {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {isSubmitting ? 'Verificando...' : 'Criar Conta'}
            </Button>
          </form>
        </Form>
        <p className="mt-6 text-center text-sm text-gray-400">
          Já tem uma conta?{' '}
          <Link to="/login" className="font-semibold text-white hover:underline">
            Faça login
          </Link>
        </p>
      </CardContent>
    </Card>
  );
}

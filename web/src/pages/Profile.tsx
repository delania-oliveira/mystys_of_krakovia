import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuth } from "@/hooks/useAuth";
import { zodResolver } from "@hookform/resolvers/zod";
import { api } from "../../api/axios";
import axios from "axios";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import * as z from "zod";

const passwordSchema = z.object({
  oldPassword: z.string().min(1, "A senha antiga é obrigatória"),
  newPassword: z.string().min(8, "A nova senha deve ter menos 8 caracteres"),
  confirmPassword: z.string()
}).refine(data => data.newPassword === data.confirmPassword, {
  message: "As senhas não correspodem",
  path: ["confirmPassword"]
})

type PasswordSchemaType = z.infer<typeof passwordSchema>

const formatDate = (dateString: string | undefined | null) => {
  if (!dateString) {
    return 'Nunca logou'
  }

  const date = new Date(dateString);
  if (isNaN(date.getTime()) || date.getUTCFullYear() <= 1970) {
    return 'Nunca logou'
  }
  return date.toLocaleDateString('pt-BR')
}

export function Profile() {
  const { user, logout } = useAuth()

  const form = useForm<PasswordSchemaType>({
    resolver: zodResolver(passwordSchema),
    defaultValues: { oldPassword: '', newPassword: '', confirmPassword: '' }
  })

  async function onChangePassword(data: PasswordSchemaType) {
    try {
      await api.post('/change_password', {
        currentPassword: data.oldPassword,
        newPassword: data.newPassword
      })
      toast.success("Senha alterada com sucesso!")
      form.reset()
    } catch (error) {
      console.error("Erro ao alterar senha: ", error)

      if (axios.isAxiosError(error) && error.response) {
        const errorMessage = error.response.data.message || "Ocorreu um erro desconhecido"

        toast.error("Falha ao alterar a senha", {
          description: errorMessage
        })

        if (errorMessage.includes("Current Password incorrect")) {
          form.setError('oldPassword', {
            type: 'manual',
            message: 'Senha antiga incorreta'
          })
        }
      } else {
        toast.error("Falha na comunicação com o servidor")
      }
    }
  }

  async function onDeleteAccount() {
    try {
      await api.delete('/accounts')
      toast.success("Conta deletada com sucesso!", {
        description: "Sentiremos sua falta!"
      })
      logout()
    } catch (error) {
      console.error("Erro ao deletar conta: ", error)
      toast.error("Falha ao deletar a conta", {
        description: "Não foi possível completar a ação no momento. Tente Novamente"
      })
    }
  }

  return (
    <div className="container py-8 px-4 text-white">
      <Tabs defaultValue="overview" className="w-full max-w-lg mx-auto">
        <TabsList className="grid w-full grid-cols-3 bg-black/50 border border-gray-700">
          <TabsTrigger value="overview" className="data-[state=active]:bg-red-700 data-[state=active]:text-white hover:cursor-pointer">Visão Geral</TabsTrigger>
          <TabsTrigger value="security" className="data-[state=active]:bg-red-700 data-[state=active]:text-white hover:cursor-pointer">Segurança</TabsTrigger>
          <TabsTrigger value="danger" className="data-[state=active]:bg-red-700 data-[state=active]:text-white hover:cursor-pointer">Zona de Perigo</TabsTrigger>
        </TabsList>
        <TabsContent value="overview">
          <Card className="bg-black/60 backdrop-blur-sm border-gray-700">
            <CardHeader>
              <CardTitle>Informações da Conta</CardTitle>
            </CardHeader>
            <CardContent className="text-sm space-y-2 text-gray-300">
              <p><strong>Membro desde:</strong> {formatDate(user?.createdAt)}</p>
              <p><strong>Último Login:</strong> {formatDate(user?.lastLogin)}</p>
              <p><strong>Personagens Criados:</strong> {user?.characters?.length ?? 0}</p>
            </CardContent>
            <CardHeader>
              <CardTitle>Meus Personagens</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Nome</TableHead>
                    <TableHead>Classe</TableHead>
                    <TableHead>Level</TableHead>
                    <TableHead>Data de Criação</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {user?.characters.map((char) => (
                    <TableRow key={char.id}>
                      <TableCell className="font-medium">{char.name}</TableCell>
                      <TableCell>{char.class}</TableCell>
                      <TableCell>{char.level}</TableCell>
                      <TableCell>{formatDate(char.createdAt)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="security">
          <Card className="bg-black/60 backdrop-blur-sm border-gray-700">
            <CardHeader><CardTitle>Mudar senha</CardTitle></CardHeader>
            <CardContent>
              <Form {...form}>
                <form onSubmit={form.handleSubmit(onChangePassword)} className="space-y-4">
                  <FormField control={form.control} name="oldPassword" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Senha Antiga</FormLabel>
                      <FormControl>
                        <Input type="password" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="newPassword" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nova Senha</FormLabel>
                      <FormControl>
                        <Input type="password" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="confirmPassword" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Confirmar Nova Senha</FormLabel>
                      <FormControl>
                        <Input type="password" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <Button type="submit" className="w-full">Salvar Alterações</Button>
                </form>
              </Form>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="danger">
          <Card className="bg-black/60 backdrop-blur-sm border-red-500/50">
            <CardHeader>
              <CardTitle className="text-white">Deletar Conta</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm text-gray-300">Esta ação é irreversível. Todo o seu progresso será perdido para sempre.</p>
              <AlertDialog>
                <AlertDialogTrigger asChild>
                  <Button variant="destructive" className="hover:cursor-pointer w-full">Eu entendo, deletar minha conta</Button>
                </AlertDialogTrigger>
                <AlertDialogContent>
                  <AlertDialogHeader>
                    <AlertDialogTitle>Você tem certeza absoluta?</AlertDialogTitle>
                    <AlertDialogDescription>
                      Essa ação não pode ser desfeita. Isso irá deletar permanentemente sua conta e remover seus dados de nossos servidores.
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter>
                    <AlertDialogCancel className="hover:cursor-pointer">Cancelar</AlertDialogCancel>
                    <AlertDialogAction onClick={onDeleteAccount} className="bg-red-600 hover:cursor-pointer hover:bg-red-700">
                      Continuar e deletar
                    </AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
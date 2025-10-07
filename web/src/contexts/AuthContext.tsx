import { createContext, useEffect, useState, type ReactNode } from "react"
import { api } from "../../api/axios"

interface Character {
  id: string
  name: string
  class: string
  level: number
  createdAt: string
  lastLogin: string
}

interface User {
  account_name: string
  createdAt: string
  characters: Character[]
  lastLogin?: string | null
}

export interface AuthContextType {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  login: (token: string) => void
  logout: () => void
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [token, setToken] = useState<string | null>(() => {
    return localStorage.getItem('authToken')
  })

  useEffect(() => {
    async function loadUserFromToken() {
      if (token) {
        try {
          api.defaults.headers.common['Authorization'] = `Bearer ${token}`
          const response = await api.get(`/user`)

          const accountData = response.data.user
          const charactersData = response.data.characters

          let lastLogin: string | null = null

          if (charactersData && charactersData.length > 0) {
            const loginDates = charactersData
              .map((char: Character) => new Date(char.lastLogin))
              .filter((date: Date) => !isNaN(date.getTime()));

            if (loginDates.length > 0) {
              const lastestDate = new Date(Math.max.apply(null, loginDates as any))
              lastLogin = lastestDate.toISOString()
            }
          }
          setUser({
            ...accountData,
            characters: charactersData,
            lastLogin: lastLogin
          })
        } catch (error) {
          console.error("Falha ao buscar dados do usuário com o token: ", error)
          logout()
        }
      }
    }
    loadUserFromToken()
  }, [token])

  const login = (newToken: string) => {
    localStorage.setItem('authToken', newToken)
    setToken(newToken)
    api.defaults.headers.common['Authorization'] = `Bearer ${newToken}`
  }

  const logout = () => {
    setUser(null)
    setToken(null)
    localStorage.removeItem('authToken')
    delete api.defaults.headers.common['Authorization']
  }

  const isAuthenticated = !!token

  return (
    <AuthContext.Provider value={{ user, token, isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}
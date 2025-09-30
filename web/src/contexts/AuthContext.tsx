import { createContext, useEffect, useState, type ReactNode } from "react"
import { api } from "../../api/axios"

interface User {
  username: string
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
          const { data } = await api.get(`/user`)
          setUser(data.user)
        } catch (error) {
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
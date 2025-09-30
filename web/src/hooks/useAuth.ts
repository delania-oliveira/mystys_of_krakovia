import { useContext } from "react";
import { AuthContext, type AuthContextType } from '@/contexts/AuthContext';

export function useAuth(): AuthContextType {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAth deve ser usado dentro de um AuthProvider')
  }
  return context
}
import { useAuth } from "@/hooks/useAuth";
import { Navigate, Outlet } from "react-router-dom";

export function GuestRoute() {
  const { isAuthenticated } = useAuth()

  return isAuthenticated ? <Navigate to="/profile" replace /> : <Outlet />
}
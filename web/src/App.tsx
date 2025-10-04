import { Routes, Route } from 'react-router-dom';
import { Layout } from '@/pages/Layout';
import { Home } from '@/pages/Home';
import { Register } from '@/pages/Register';
import { Profile } from './pages/Profile';
import { Login } from './pages/Login';
import { ProtectedRoute } from './components/layout/ProtectedRoute';
import { GuestRoute } from './components/layout/GuestRoute';
import { Download } from './pages/Download';

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />

        <Route element={<GuestRoute />}>
          <Route path="register" element={<Register />} />
          <Route path="login" element={<Login />} />
        </Route>

        <Route element={<ProtectedRoute />}>
          <Route path="profile" element={<Profile />} />
          <Route path="download" element={<Download />} />
        </Route>

        <Route path="*" element={<Home />} />
      </Route>
    </Routes>
  );
}
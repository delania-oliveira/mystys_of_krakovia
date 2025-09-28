import { Routes, Route } from 'react-router-dom';
import { Layout } from '@/pages/Layout';
import { Home } from '@/pages/Home';
import { Register } from '@/pages/Register';
import { Profile } from './pages/Profile';
import { Login } from './pages/Login';

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />
        <Route path="register" element={<Register />} />
        <Route path="login" element={<Login />} />
        {/* <Route path="sobre" element={<Sobre />} /> */}
        {/* <Route path="download" element={<Download />} /> */}
        <Route path="*" element={<Home />} />
      </Route>
      <Route path="profile" element={<Profile />} />
    </Routes>
  );
}
import { Link } from 'react-router-dom';
import { Button } from '../ui/button';
import { Download } from 'lucide-react';
import logoImg from '@/assets/MOK_LOGO4.png'

export function Navbar() {
  return (
    <nav className="fixed top-0 left-0 w-full bg-black/30 backdrop-blur-sm z-20">
      <div className="container mx-auto h-22 flex items-center justify-between px-4">
        <Link to="/" className="text-xl font-bold text-white">
          <img
            src={logoImg}
            alt="Logo do jogo Mystys of Krakovia"
            className="h-20 w-auto"
          />
        </Link>
        <div className="flex items-baseline gap-4 text-white">
          <Link to="/" className="hover:text-primary transition-colors">
            Início
          </Link>
          <Link to="/sobre" className="hover:text-primary transition-colors">
            Sobre
          </Link>
          <Link to="/login" className="hover:text-primary transition-colors">
            Login
          </Link>
          <Button asChild size="lg" className="mt-6 text-lg font-bold">
            <Link to="/download">
              <Download color='white' size={24} strokeWidth={3} />
              Download
            </Link>
          </Button>
        </div>
      </div>
    </nav>
  );
}
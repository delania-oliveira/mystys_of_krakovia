import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';

export function Home() {
  return (
    <div className="text-center">
      <h1
        className="text-4xl md:text-4xl font-bold font-[Cinzel] text-white tracking-wider"
        style={{ textShadow: '2px 2px 8px rgba(0,0,0,0.7)' }}
      >
        Quando os obeliscos se erguem e as névoas caírem, <br /> apenas os escolhidos poderão impedir que <br />
        os deuses antigos retomem o mundo.
      </h1>
      <Button asChild size="lg" className="mt-6 text-lg font-bold">
        <Link to="/register">Jogue Agora!</Link>
      </Button>
    </div>
  );
}
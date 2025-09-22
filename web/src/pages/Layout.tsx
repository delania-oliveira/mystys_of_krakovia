import { Outlet } from 'react-router-dom';
import { Navbar } from '@/components/layout/Navbar';
import { Footer } from '@/components/layout/Footer';
import backgroundVideo from '@/assets/Sep_20__2035_16s_202509211418_0z3gy.mp4';
import { Toaster } from '@/components/ui/sonner';

export function Layout() {
  return (
    <div className="flex flex-col h-screen bg-black">
      <Navbar />
      <main className="flex-grow relative flex items-center justify-end">
        <video
          autoPlay
          loop
          muted
          className="absolute top-0 left-0 w-full h-full object-cover z-0"
        >
          <source src={backgroundVideo} type="video/mp4" />
        </video>

        <div className="absolute top-0 left-0 w-full h-full bg-black/50 z-1"></div>

        <div className="relative z-10 flex flex-col items-center container mx-auto px-8">
          <Outlet />
        </div>
      </main>
      <Footer />
      <Toaster richColors position="top-right" />
    </div>
  );
}
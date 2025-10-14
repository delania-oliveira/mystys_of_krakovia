import axios from "axios";
import { Circle, Loader2, Users } from "lucide-react";
import { useEffect, useState } from "react";

interface ServerStatus {
  players: number
}

export function Footer() {
  const currentYear = new Date().getFullYear();

  const [status, setStatus] = useState<'online' | 'offline' | 'loading'>('loading')
  const [playerCount, setPlayerCount] = useState<number>(0)

  useEffect(() => {
    const fetchStatus = async () => {
      try {
        const response = await axios.get<ServerStatus>('http://week-characterized.gl.at.ply.gg:29821/health_check/Krakovia')

        if (response.status === 200) {
          setStatus('online')
          setPlayerCount(response.data.players)
        }
      } catch (error) {
        if (axios.isAxiosError(error) && error.response?.status === 404) {
          setStatus('offline')
          setPlayerCount(0)
        } else {
          console.error("Failed to fetch server status: ", error)
          setStatus('offline')
          setPlayerCount(0)
        }
      }
    }
    fetchStatus()

    const intervalId = setInterval(fetchStatus, 600000)

    return () => clearInterval(intervalId)
  }, [])

  return (
    <footer className="w-full bg-black/50 h-18 flex flex-col items-center justify-center p-2">

      <div className="flex items-center gap-4 text-white text-sm mb-2">
        {status === 'loading' && (
          <div className="flex items-center gap-2 text-gray-400">
            <Loader2 className="h-4 w-4 animate-spin" />
            <span>Verificando status...</span>
          </div>
        )}
        {status !== 'loading' && (
          <>
            <div className="flex items-center gap-1.5">
              <Circle className={`h-3 w-3 ${status === 'online' ? 'text-green-500 fill-green-500 animate-pulse' : 'text-red-500 fill-red-500'}`} />
              <span>
                Status: {status === 'online' ? 'Online' : 'Offline'}
              </span>
            </div>
            {status === 'online' && (
              <>
                <span className="text-gray-500">|</span>
                <div className="flex items-center gap-1.5">
                  <Users className="h-4 w-4" />
                  <span>Players: {playerCount}</span>
                </div>
              </>
            )}
          </>
        )}
      </div>

      <p className="text-muted-foreground text-sm">
        &copy; {currentYear} Mystys Of Krakovia
      </p>
    </footer>
  );
}

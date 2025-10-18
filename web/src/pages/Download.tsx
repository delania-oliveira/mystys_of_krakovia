import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import WindowsLogo from "../assets/windows-logo.svg";
import { Button } from "@/components/ui/button";

export function Download() {

  const getDownloadLink = () => {
    return 'https://drive.google.com/file/d/1zqjVVUBU_K0Ik_biAgA-lf4U5VhwQA4V/view?usp=drive_link'
  }

  return (
    <Card className="w-full max-w-6xl bg-black/60 backdrop-blur-sm border-gray-700 text-white">
      <CardHeader className="border-b border-gray-700/50 pb-4">
        <CardTitle className="text-3xl text-center">Dowload do Jogo</CardTitle>
      </CardHeader>
      <CardContent className="grid grid-cols-1 md:grid-cols-3 md:divide-x md:divide-gray-700/50 p-0">

        <div className="flex flex-col items-center justify-center p-6 text-center">
          <img
            src={WindowsLogo}
            alt="Logo do Windows"
            className="h-16 w-16 mb-4"
          />
          <h3 className="text-2xl font-semibold">Windows</h3>
          <p className="text-sm text-gray-400 mb-6">64-bit | 5.4 GB</p>
          <Button asChild size="lg" className="w-4/5">
            <a href={getDownloadLink()} download>Baixar</a>
          </Button>
        </div>

        <div className="p-6">
          <h3 className="text-2xl font-semibold mb-4">Requisitos do Sistema</h3>
          <div className="text-sm">
            <div className="mb-2"><span className="font-bold">Minimo</span></div>
            <ul className="list-disc list-inside text-gray-300 pl-2 space-y-1">
              <li>SO: Windows 10 ou acima (64-bit)</li>
              <li>Processador: Intel Core i5-4460</li>
              <li>Memória RAM: 8 GB</li>
              <li>Placa de Vídeo: NVIDIA GTX 1050</li>
              <li>Espaço em Disco: 10 GB</li>
            </ul>
          </div>
        </div>

        <div className="p-6">
          <h3 className="text-2xl font-semibold mb-4">Como Instalar</h3>
          <ol className="list-decimal list-inside text-gray-300 space-y-2">
            <li>Baixe o arquivo compactado (.zip)</li>
            <li>Extraia o conteúdo para uma pasta</li>
            <li>Execute o MystysOfKrakoviaInstaller.exe</li>
            <li>Siga as instruções na tela para completar a instalação</li>
            <li>Inicie o jogo e divirta-se!</li>
          </ol>
        </div>
      </CardContent>
    </Card>
  )
}
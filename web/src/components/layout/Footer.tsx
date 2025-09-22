export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="w-full bg-black/50 h-12 flex items-center justify-center">
      <p className="text-muted-foreground text-sm">
        &copy; {currentYear} Mystys Of Krakovia
      </p>
    </footer>
  );
}

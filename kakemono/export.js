const { exec } = require('child_process');
const http     = require('http');
const fs       = require('fs');
const path     = require('path');

const DIR    = __dirname;
const PORT   = 9191;
const OUTPUT = path.join(DIR, 'kakemono-export.png');
const CHROME = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

// ── Serveur HTTP local (event loop non bloqué) ───────────────────
const server = http.createServer((req, res) => {
  let filePath = path.join(DIR, req.url === '/' ? 'kakemono.html' : req.url);
  fs.readFile(filePath, (err, data) => {
    if (err) { res.writeHead(404); res.end('Not found'); return; }
    const mime = {
      '.html':'text/html', '.js':'application/javascript',
      '.css':'text/css',   '.png':'image/png',
      '.jpg':'image/jpeg', '.jpeg':'image/jpeg',
    };
    const ext = path.extname(filePath).toLowerCase();
    res.writeHead(200, { 'Content-Type': mime[ext] || 'application/octet-stream' });
    res.end(data);
  });
});

server.listen(PORT, () => {
  console.log(`Serveur prêt sur http://localhost:${PORT}`);
  // Petite pause pour laisser le serveur s'initialiser
  setTimeout(runChrome, 800);
});

function runChrome() {
  console.log('Capture Chrome headless...');
  const args = [
    '--headless=new',
    '--disable-gpu',
    '--no-sandbox',
    '--disable-extensions',
    '--disable-sync',
    '--no-first-run',
    '--disable-background-networking',
    `--user-data-dir=D:\\chrome-tmp-kakemono`,
    `--screenshot="${OUTPUT}"`,
    '--window-size=800,2000',
    '--virtual-time-budget=5000',
    `http://localhost:${PORT}/kakemono.html`,
  ].join(' ');

  const cmd = `"${CHROME}" ${args}`;

  exec(cmd, { timeout: 40000 }, (err, stdout, stderr) => {
    server.close();

    // Nettoie le dossier temp Chrome
    fs.rmSync('D:\\chrome-tmp-kakemono', { recursive: true, force: true });

    if (fs.existsSync(OUTPUT) && fs.statSync(OUTPUT).size > 50000) {
      console.log(`✅  PNG généré avec succès : ${OUTPUT}`);
      console.log(`    Taille : ${(fs.statSync(OUTPUT).size / 1024).toFixed(0)} KB`);
    } else {
      console.error('❌  Échec — fichier manquant ou trop petit.');
      if (err) console.error('   Erreur :', err.message);
    }
  });
}

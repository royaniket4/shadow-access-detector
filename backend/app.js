const express = require('express');
const cors = require('cors');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');
const QRCode = require('qrcode');

const app = express();
app.use(cors());

// 🔍 Get local IP
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

// 🚀 Shadow Access Scanner
app.get('/api/scan', (req, res) => {
  const scannerPath = path.join(__dirname, '../utils/scanner.py');
  console.log("🔍 scannerPath:", scannerPath);

  if (!fs.existsSync(scannerPath)) {
    console.log('❌ scanner.py not found.');
    return res.status(500).json({ error: 'scanner.py not found' });
  }

  const python = spawn('python3', [scannerPath]);
  let output = '';
  let errorOutput = '';

  python.stdout.on('data', (data) => {
    output += data.toString();
    console.log("📤 stdout chunk:", data.toString().trim());
  });

  python.stderr.on('data', (data) => {
    errorOutput += data.toString();
    console.log("📥 stderr chunk:", data.toString().trim());
  });

  python.on('close', (code) => {
    console.log("⚠️ exit code:", code);
    console.log("🧾 Raw output:", JSON.stringify(output));
    console.log("🧾 Raw stderr:", JSON.stringify(errorOutput));

    if (code !== 0) {
      return res.status(500).json({ error: 'Scanner failed', details: errorOutput });
    }

    try {
      const clean = output.trim();
      const result = JSON.parse(clean);
      console.log("✅ Parsed JSON:", result);
      res.json(result);
    } catch (err) {
      console.error('❌ JSON parse error:', err.message);
      res.status(500).json({ error: 'Invalid JSON from scanner', details: err.message });
    }
  });
});

// 📱 QR Code route
app.get('/api/qrcode', async (req, res) => {
  const ip = getLocalIP();
  const url = `http://${ip}:3000`; // frontend port
  try {
    const qr = await QRCode.toDataURL(url);
    res.json({ url, qr });
  } catch (err) {
    res.status(500).json({ error: 'QR generation failed' });
  }
});

// ✅ Start server
const ip = getLocalIP();
app.listen(5000, ip, () => {
  console.log(`✅ Backend running at http://${ip}:5000`);
});

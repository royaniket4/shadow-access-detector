#!/bin/bash

if [[ "$(basename "$PWD")" == "shadow-access-detector" ]]; then
  echo "✅ You're in the correct folder."
else
  echo "❌ Please run this script from inside the shadow-access-detector folder."
  exit 1
fi


echo "🚀 Starting Shadow Access Detector setup..."

# Step 1: Ensure we're in the correct project root
PROJECT_ROOT="$(pwd)"
echo "📁 Project root: $PROJECT_ROOT"

# Step 2: Cleanup old backend
if [ -d "$PROJECT_ROOT/backend" ]; then
  echo "🧹 Removing old backend..."
  rm -rf "$PROJECT_ROOT/backend"
fi

# Step 3: Setup backend
echo "📦 Setting up backend..."
mkdir "$PROJECT_ROOT/backend"
cd "$PROJECT_ROOT/backend" || exit
npm init -y
npm install express cors
mkdir routes utils

# Create app.js
cat <<EOF > app.js
const express = require('express');
const { exec } = require('child_process');
const cors = require('cors');
const app = express();
app.use(cors());

app.get('/api/scan', (req, res) => {
  exec('python3 backend/utils/scanner.py', (err, stdout, stderr) => {
    if (err) return res.status(500).send({ error: stderr });
    res.send(JSON.parse(stdout));
  });
});

app.listen(5000, () => console.log('✅ Backend running on port 5000'));
EOF

# Create Python scanner
cat <<EOF > utils/scanner.py
import os
import pwd
import subprocess
import json

def get_users():
    users = []
    for p in pwd.getpwall():
        if p.pw_uid >= 1000 and 'nologin' not in p.pw_shell:
            users.append(p.pw_name)
    return users

def get_last_login(user):
    try:
        output = subprocess.check_output(['lastlog', '-u', user]).decode()
        if 'Never logged in' in output:
            return None
        date_str = output.split('\\n')[1].split()[-4:]
        return ' '.join(date_str)
    except:
        return None

def scan_shadow_access():
    results = []
    users = get_users()
    for user in users:
        last_login = get_last_login(user)
        risk = 'High' if not last_login else 'Low'
        results.append({
            'user': user,
            'last_login': last_login or 'Never',
            'risk': risk
        })
    return results

if __name__ == "__main__":
    print(json.dumps(scan_shadow_access()))
EOF

cd "$PROJECT_ROOT"

# Step 4: Cleanup old frontend
if [ -d "$PROJECT_ROOT/frontend" ]; then
  echo "🧹 Removing old frontend..."
  rm -rf "$PROJECT_ROOT/frontend"
fi

# Step 5: Setup frontend
echo "🖥️ Setting up frontend..."
npx create-react-app frontend --use-npm
cd "$PROJECT_ROOT/frontend" || exit
npm install axios

# Create AccessTable component
mkdir -p src/components
cat <<EOF > src/components/AccessTable.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';

const AccessTable = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:5000/api/scan')
      .then(res => setData(res.data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div className="p-4">
      <h2 className="text-xl font-bold mb-4">Shadow Access Report</h2>
      <table className="w-full border">
        <thead>
          <tr>
            <th>User</th>
            <th>Last Login</th>
            <th>Risk</th>
          </tr>
        </thead>
        <tbody>
          {data.map((entry, i) => (
            <tr key={i}>
              <td>{entry.user}</td>
              <td>{entry.last_login}</td>
              <td className={entry.risk === 'High' ? 'text-red-500' : 'text-green-500'}>
                {entry.risk}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default AccessTable;
EOF

# Replace App.js
cat <<EOF > src/App.js
import React from 'react';
import AccessTable from './components/AccessTable';

function App() {
  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <h1 className="text-3xl font-bold mb-6 text-center">Shadow Access Detector</h1>
      <AccessTable />
    </div>
  );
}

export default App;
EOF

# Replace index.js
cat <<EOF > src/index.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# Basic CSS
cat <<EOF > src/index.css
body {
  font-family: sans-serif;
  background-color: #f9fafb;
}
table {
  border-collapse: collapse;
  width: 100%;
}
th, td {
  padding: 12px;
  border: 1px solid #ddd;
}
th {
  background-color: #f3f4f6;
}
EOF

cd "$PROJECT_ROOT"

echo "✅ Setup complete!"
echo "👉 To start backend: cd backend && npm start"
echo "👉 To start frontend: cd frontend && npm start"
echo "🛡️ Optional: Run 'npm audit fix --force' in both folders to fix vulnerabilities"

import React, { useEffect, useState } from 'react';
import axios from 'axios';

const AccessTable = () => {
  const [data, setData] = useState([]);
  const [qr, setQr] = useState(null);
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  const backendURL = 'http://' + window.location.hostname + ':5000';

  useEffect(() => {
    axios.get(`${backendURL}/api/scan`)
      .then(res => {
        setData(res.data);
        setIsLoading(false);
      })
      .catch(() => {
        setError("Failed to fetch data");
        setIsLoading(false);
      });

    axios.get(`${backendURL}/api/qrcode`)
      .then(res => setQr(res.data))
      .catch(() => setQr(null));
  }, []);

  if (isLoading) return <p>🔄 Loading Shadow Access Report...</p>;
  if (error) return <p className="text-red-600">❌ {error}</p>;

  return (
    <div className="p-4">
      <h2 className="text-xl font-bold mb-2">Shadow Access Report</h2>

      <button
        onClick={() => window.location.reload()}
        className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 mb-4"
      >
        🔄 Refresh Report
      </button>

      {qr && (
        <div className="mb-6 text-center">
          <h3 className="text-lg font-semibold">📱 Scan to Access Dashboard</h3>
          <div className="relative group inline-block">
            <img src={qr.qr} alt="QR Code" className="mx-auto my-2 w-40" />
            <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 bg-black text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition">
              Scan from same Wi-Fi device
            </div>
          </div>
          <p className="text-sm text-gray-600">{qr.url}</p>
          <button
            onClick={() => navigator.clipboard.writeText(qr.url)}
            className="bg-gray-800 text-white px-3 py-1 rounded hover:bg-gray-700 mt-2"
          >
            📋 Copy Dashboard Link
          </button>
        </div>
      )}

      {data.length === 0 ? (
        <p>⚠️ No shadow access detected.</p>
      ) : (
        <table className="table-auto w-full border">
          <thead>
            <tr className="bg-gray-200">
              <th className="px-4 py-2">User</th>
              <th className="px-4 py-2">Last Login</th>
              <th className="px-4 py-2">Risk</th>
            </tr>
          </thead>
          <tbody>
            {data.map((entry, i) => (
              <tr key={i} className="text-center border-t">
                <td className="px-4 py-2">{entry.user}</td>
                <td className="px-4 py-2">{entry.last_login}</td>
                <td className={`px-4 py-2 font-bold ${entry.risk === 'High' ? 'text-red-600' : 'text-green-600'}`}>
                  {entry.risk}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default AccessTable;

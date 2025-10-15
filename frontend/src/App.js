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

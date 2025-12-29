import React, { useEffect, useState } from 'react';
import Hello from './components/Hello';

function App() {
  const [msg, setMsg] = useState('');
  useEffect(() => {
    const backendUrl = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8080';
    fetch(`${backendUrl}/api/hello`)
      .then(r => r.json())
      .then(d => setMsg(d.message))
      .catch(() => setMsg('backend unavailable'));
  }, []);
  return (
    <div>
      <Hello message={msg} />
    </div>
  );
}

export default App;
import React, { useEffect, useState } from 'react';
import Hello from './components/Hello';

function App() {
  const [msg, setMsg] = useState('');
  useEffect(() => {
    const apiBase = process.env.REACT_APP_BACKEND_URL;
    const url = apiBase ? `${apiBase.replace(/\/$/, '')}/api/hello` : '/api/hello';
    fetch(url)
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

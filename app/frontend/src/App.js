import React, { useEffect, useState } from 'react';
import Hello from './components/Hello';

function App() {
  const [msg, setMsg] = useState('');
  useEffect(() => {
    fetch('/api/hello')
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
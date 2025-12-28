import React from 'react';

export default function Hello({ message }) {
  return <h1>{message || 'Loading...'}</h1>;
}
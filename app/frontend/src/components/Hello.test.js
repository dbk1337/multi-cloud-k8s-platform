import React from 'react';
import ReactDOMServer from 'react-dom/server';
import Hello from './Hello';

describe('Hello', () => {
  it('renders the provided message', () => {
    const html = ReactDOMServer.renderToString(<Hello message="Hi there" />);
    expect(html).toContain('Hi there');
  });

  it('renders loading when message is missing', () => {
    const html = ReactDOMServer.renderToString(<Hello />);
    expect(html).toContain('Loading...');
  });
});

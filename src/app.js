const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.json({ message: 'Hello from node-release-poc', version: '1.0.0' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

module.exports = app;

const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.json({ message: 'Hello from node-release-poc', version: '1.0.0' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/info', (req, res) => {
  res.json({ 
    name: 'node-release-poc',
    description: 'POC for release workflows',
    workflows: ['manual-release', 'auto-release']
  });
});

app.get('/status', (req, res) => {
  res.json({
    uptime: process.uptime(),
    timestamp: Date.now(),
    message: 'Service is running'
  });
});

app.get('/metrics', (req, res) => {
  res.json({
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    platform: process.platform,
    nodeVersion: process.version
  });
});

module.exports = app;

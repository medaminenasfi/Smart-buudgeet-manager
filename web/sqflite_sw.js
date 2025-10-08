// This is a minimal service worker for sqflite web support
const CACHE_NAME = 'sqflite-cache-v1';

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('message', (event) => {
  // Handle messages from main thread if needed
  console.log('Service worker received message:', event.data);
});
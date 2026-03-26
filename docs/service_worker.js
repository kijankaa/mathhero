// service_worker.js
// Service Worker dla trybu offline MathHero.
// WAŻNE: Po każdym deployu zaktualizuj CACHE_VERSION — stary cache zostanie usunięty.

const CACHE_VERSION = 'mathhero-v1';
const CACHE_NAME = CACHE_VERSION;

// Pliki cache przy instalacji (core assets).
// Po pierwszym eksporcie Godot dodaj nazwy wygenerowanych plików .js/.pck/.wasm.
const PRECACHE_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './index.js',
  './index.pck',
  './index.wasm',
  './index.audio.worklet.js',
  './index.audio.position.worklet.js',
];

// Instalacja — precache core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

// Aktywacja — usuń stare wersje cache
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => name !== CACHE_NAME)
          .map(name => {
            console.log('[SW] Usuwam stary cache:', name);
            return caches.delete(name);
          })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch — Cache First, fallback do sieci, dynamiczny cache nowych assetów
self.addEventListener('fetch', (event) => {
  // Tylko GET
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;

      return fetch(event.request).then(response => {
        // Cache dynamicznie nowych assetów (np. Godot .pck po eksporcie)
        if (response.ok) {
          const cloned = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, cloned));
        }
        return response;
      });
    }).catch(() => {
      // Offline fallback — zwróć index.html dla requestów nawigacyjnych
      if (event.request.destination === 'document') {
        return caches.match('./index.html');
      }
    })
  );
});

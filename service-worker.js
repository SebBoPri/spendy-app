// Spendy Service Worker - Enables offline functionality and caching
const CACHE_NAME = 'spendy-v2.0.0-airy';
const RUNTIME_CACHE = 'spendy-runtime-v2';

// Files to cache immediately on install
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  // Add your CSS if external
  // Add your JS if external
];

// Install event - cache essential resources
self.addEventListener('install', event => {
  console.log('[Service Worker] Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[Service Worker] Precaching app shell');
        return cache.addAll(PRECACHE_URLS);
      })
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  console.log('[Service Worker] Activating...');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME && cacheName !== RUNTIME_CACHE) {
            console.log('[Service Worker] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - network-first strategy for API calls, cache-first for static assets
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    // For Supabase API calls - network only (always fresh data)
    if (url.origin.includes('supabase')) {
      event.respondWith(fetch(request));
      return;
    }

    // For Claude AI API calls - network only
    if (url.origin.includes('anthropic') || url.origin.includes('claude')) {
      event.respondWith(fetch(request));
      return;
    }

    // For other cross-origin requests, try network first
    event.respondWith(
      fetch(request).catch(() => {
        return new Response('Offline - external resource unavailable', {
          status: 503,
          statusText: 'Service Unavailable'
        });
      })
    );
    return;
  }

  // For same-origin requests
  // API requests - network first, fall back to cache
  if (request.method === 'POST' || request.method === 'PUT' || request.method === 'DELETE') {
    event.respondWith(
      fetch(request).catch(error => {
        console.error('[Service Worker] Network request failed:', error);
        return new Response(JSON.stringify({
          error: 'You are offline. This action will be synced when you reconnect.'
        }), {
          status: 503,
          headers: { 'Content-Type': 'application/json' }
        });
      })
    );
    return;
  }

  // GET requests - cache first, fall back to network
  event.respondWith(
    caches.match(request).then(cachedResponse => {
      if (cachedResponse) {
        // Return cached version and update cache in background
        event.waitUntil(
          fetch(request).then(response => {
            return caches.open(RUNTIME_CACHE).then(cache => {
              cache.put(request, response.clone());
              return response;
            });
          }).catch(() => {
            // Network failed, but we have cache - that's fine
          })
        );
        return cachedResponse;
      }

      // Not in cache - fetch from network
      return fetch(request).then(response => {
        // Don't cache if not a success response
        if (!response || response.status !== 200 || response.type === 'error') {
          return response;
        }

        // Clone the response
        const responseToCache = response.clone();

        // Cache the fetched response for future use
        caches.open(RUNTIME_CACHE).then(cache => {
          cache.put(request, responseToCache);
        });

        return response;
      }).catch(error => {
        console.error('[Service Worker] Fetch failed:', error);

        // Return offline page for navigation requests
        if (request.mode === 'navigate') {
          return caches.match('/index.html');
        }

        return new Response('Offline', {
          status: 503,
          statusText: 'Service Unavailable'
        });
      });
    })
  );
});

// Background sync for offline actions (future enhancement)
self.addEventListener('sync', event => {
  console.log('[Service Worker] Background sync:', event.tag);
  if (event.tag === 'sync-receipts') {
    event.waitUntil(syncReceipts());
  }
});

async function syncReceipts() {
  // Placeholder for syncing receipts when back online
  console.log('[Service Worker] Syncing receipts...');
  // Implementation would go here
}

// Push notifications (future enhancement)
self.addEventListener('push', event => {
  console.log('[Service Worker] Push notification received');
  const options = {
    body: event.data ? event.data.text() : 'New notification from Spendy',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    vibrate: [200, 100, 200],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'View',
        icon: '/icons/checkmark.png'
      },
      {
        action: 'close',
        title: 'Close',
        icon: '/icons/cross.png'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('Spendy', options)
  );
});

self.addEventListener('notificationclick', event => {
  console.log('[Service Worker] Notification clicked');
  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

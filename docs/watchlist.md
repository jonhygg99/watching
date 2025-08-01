# Watchlist

## Visión General

El módulo de Watchlist es el núcleo de la aplicación Watching, permitiendo a los usuarios gestionar y realizar un seguimiento de sus series y películas. Implementa un sistema de caché para mejorar el rendimiento y la experiencia de usuario.

## Estructura del Módulo

```
watchlist/
├── cache/                  # Gestión de caché
│   └── watchlist_cache.dart
├── enums/                  # Enumeraciones
│   └── watchlist_type.dart
├── models/                 # Modelos de datos
│   └── watchlist_state.dart
├── providers/              # Proveedores Riverpod
│   ├── watchlist_cache_provider.dart
│   ├── watchlist_providers.dart
│   └── watchlist_type_provider.dart
├── services/               # Lógica de negocio
│   ├── watchlist_episode_actions.dart
│   ├── watchlist_episode_service.dart
│   └── watchlist_processor.dart
└── state/                  # Gestión de estado
    ├── watchlist_notifier/
    │   ├── watchlist_actions.dart
    │   ├── watchlist_cache_handler.dart
    │   └── watchlist_state_mixin.dart
    ├── watchlist_notifier.dart
    └── watchlist_provider.dart
```

## Componentes Principales

### 1. Modelos de Datos

#### WatchlistState

Gestiona el estado de la lista de seguimiento:

- `items`: Lista de elementos (series/películas)
- `isLoading`: Indica si se está cargando
- `error`: Almacena errores si los hay
- `hasData`: Indica si hay datos cargados

### 2. Gestión de Estado

#### WatchlistNotifier

Gestiona el estado y la lógica de negocio:

- Carga de datos desde la API
- Sincronización con caché
- Manejo de acciones del usuario

#### WatchlistCacheHandler

Maneja el almacenamiento en caché:

- Guarda/recupera datos localmente
- Gestiona la expiración de la caché
- Sincronización con datos remotos

### 3. Servicios

#### WatchlistEpisodeService

Gestiona las acciones relacionadas con episodios:

- Marcar como visto/no visto
- Actualizar progreso
- Sincronizar con el servidor

#### WatchlistProcessor

Procesa y transforma los datos:

- Formatea la respuesta de la API
- Combina datos locales y remotos
- Prepara los datos para la UI

## Flujo de Datos

1. **Carga Inicial**

   ```mermaid
   graph TD
     A[Pantalla Watchlist] -->|Solicita datos| B[WatchlistNotifier]
     B -->|Verifica caché| C[WatchlistCacheHandler]
     C -->|Datos en caché?| D{¿Válidos?}
     D -->|Sí| E[Retorna datos de caché]
     D -->|No| F[Solicita a la API]
     F -->|Almacena en caché| C
     F -->|Actualiza estado| B
     B -->|Muestra datos| A
   ```

2. **Acciones del Usuario**
   - Marcar episodio como visto
   - Actualizar progreso
   - Añadir/eliminar de la lista
   - Ordenar/filtrar elementos

## Manejo de Errores

La Watchlist implementa un sistema robusto de manejo de errores:

1. **Errores de Red**

   - Muestra mensaje al usuario
   - Intenta usar datos en caché si están disponibles
   - Reintenta automáticamente según la política de reintentos

2. **Errores de API**

   - Maneja códigos de estado HTTP
   - Procesa mensajes de error del servidor
   - Actualiza la UI según corresponda

3. **Errores Locales**
   - Validación de datos
   - Manejo de caché corrupta
   - Gestión de almacenamiento local

## Optimizaciones

1. **Caché Inteligente**

   - Almacenamiento local de datos
   - Invalidación automática
   - Sincronización en segundo plano

2. **Rendimiento**

   - Carga paginada
   - Actualizaciones incrementales
   - Uso eficiente de memoria

3. **Experiencia de Usuario**
   - Actualización optimista de la UI
   - Indicadores de carga
   - Retroalimentación visual

## Mejoras Futuras

- [ ] Sincronización en tiempo real
- [ ] Soporte para múltiples listas
- [ ] Filtros avanzados
- [ ] Búsqueda dentro de la watchlist
- [ ] Compartir listas con otros usuarios

## Ejemplo de Uso

```dart
// Obtener la watchlist
final watchlist = ref.watch(watchlistProvider);

// Marcar episodio como visto
await ref.read(watchlistNotifierProvider.notifier)
  .markEpisodeAsWatched(
    showId: '123',
    season: 1,
    episode: 5,
    watched: true,
  );

// Forzar actualización
await ref.refresh(watchlistProvider.future);
```

## Consideraciones de Seguridad

- Validación de datos del servidor
- Sanitización de entradas
- Manejo seguro de tokens
- Protección contra inyección

# Visión General de Watching

## 🎯 Propósito

Watching es una aplicación móvil desarrollada en Flutter diseñada para ayudar a los usuarios a realizar un seguimiento de sus series de televisión favoritas. La aplicación permite a los usuarios:

- Mantener una lista de series y películas que están viendo actualmente
- Registrar episodios y películas vistos
- Visualizar su progreso por temporada
- Descubrir nuevas series y películas populares
- Ver información detallada de películas y series (además de recomendaciones parecidas)
- Descubrir cuando se estrenarán nuevos episodios y películas
- Ver estadísticas de visualización
-

## 🚀 Características Principales

### 1. Autenticación de Usuarios

- Registro e inicio de sesión a través de un código de la api de usuario de Trakt.tv

### 2. Lista de Seguimiento (Watchlist)

- Añadir/eliminar series y películas a la lista
- Ver estado de visualización
- Ordenar y filtrar series

### 3. Detalles de Series

- Información detallada de cada serie
- Temporadas y episodios
- Progreso de visualización con indicadores visuales
- Marcar episodios como vistos

### 4. Progreso de Visualización

- Barra de progreso por temporada
- Conteo de episodios vistos/totales
- Sincronización en tiempo real

## 🛠️ Stack Tecnológico

### Frontend

- **Framework**: Flutter
- **Lenguaje**: Dart
- **Gestión de Estado**: Riverpod
- **Patrones de Arquitectura**: Clean Architecture, BLoC Pattern
- **UI/UX**: Material Design 3

### Backend

- **API REST**: Trakt.tv
- **Autenticación**: OAuth 2.0
- **Almacenamiento Local**: Hive/SharedPreferences

### Herramientas de Desarrollo

- **Control de Versiones**: Git
- **CI/CD**: GitHub Actions
- **Gestión de Dependencias**: Pub
- **Análisis de Código**: Dart Analysis, Lints

## 📱 Experiencia de Usuario

La aplicación está diseñada con un enfoque en la simplicidad y usabilidad:

- Interfaz intuitiva y minimalista
- Navegación fluida entre pantallas
- Retroalimentación visual inmediata
- Modo oscuro/ligero
- Soporte para múltiples idiomas

## 🔄 Flujo de Datos

1. **Capa de Datos**: Comunicación con la API de Trakt.tv
2. **Capa de Dominio**: Lógica de negocio y casos de uso
3. **Capa de Presentación**: Componentes UI y gestión de estado

## 🎨 Guía de Estilo

- **Tipografía**: Roboto (predeterminada de Material Design)
- **Paleta de Colores**: TODO
  - Primario: `#2196F3` (Azul)
  - Secundario: `#FF4081` (Rosa)
  - Fondo: `#FFFFFF` (Claro) / `#121212` (Oscuro)
  - Superficie: `#F5F5F5` (Claro) / `#1E1E1E` (Oscuro)

## 📅 Roadmap

- [x] Iniciar sesión con la api de Trakt.tv

### Discover

- [x] Recomendaciones de películas y series
- [ ] Añadir cache

### Watchlist

- [x] Listar series y películas en la watchlist
- [x] Añadir cache
- [x] Añadir series de forma paralela
- [x] Añadir información del episodio actual
- [x] Marcar el episodio como visto
- [x] Poner rating al episodio
- [x] Ver comentarios del episodio
- [ ] Añadir soporte para películas

### Show Details

- [x] Añadir Portada, nombre, sinopsis, géneros, duración, rating, año de estreno
- [x] Añadir Temporadas y episodios
- [x] Añadir Reparto principal (y secundario)
- [x] Ver comentarios de la serie
- [x] Añadir Recomendaciones relacionadas
- [x] Marcar episodios y temporada como vistos
- [ ] Añadir vídeos de trailer y otros
- [ ] Añadir Estreno de la próxima temporada
- [ ] Integrar con servicios de streaming
- [ ] Añadir Merchandising

### My Shows

- [ ] Añadir próximos estrenos de las series que se está viendo
- [ ] Añadir próximos estrenos de las películas que se quiere ver

### Otros

- [ ] Añadir estadísticas de visualización

## 🏗️ Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── services/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── watchlist/
│   └── show_details/
├── shared/
│   ├── widgets/
│   ├── providers/
│   └── themes/
└── main.dart
```

## 📝 Notas Adicionales

- La aplicación sigue los principios de diseño Material Design 3
- Se prioriza el rendimiento y la fluidez
- El código sigue las mejores prácticas de Flutter y Dart
- Se implementan pruebas unitarias y de widget

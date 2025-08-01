# Sistema de Autenticación

## Visión General

El sistema de autenticación de Watching está construido sobre la API de Trakt.tv, utilizando OAuth 2.0 para la autenticación de usuarios. La aplicación implementa un flujo de autenticación que permite a los usuarios iniciar sesión con su cuenta de Trakt.tv.

## Componentes Principales

### 1. LoginController

El controlador principal que gestiona el flujo de autenticación.

**Ubicación**: `lib/login/login_controller.dart`

**Responsabilidades**:

- Gestionar el estado del proceso de login
- Iniciar el flujo de autorización con Trakt.tv
- Manejar la autenticación con códigos de verificación
- Proporcionar retroalimentación al usuario durante el proceso

**Estado (LoginState)**:

- `loading`: Indica si hay una operación en curso
- `error`: Mensaje de error si ocurre algún problema
- `showCodeInput`: Controla la visibilidad del campo de código
- `username`: Nombre de usuario autenticado

### 2. Páginas de UI

#### LoginPage

**Ubicación**: `lib/login/login_page.dart`

**Características**:

- Interfaz de usuario para el inicio de sesión
- Manejo de diferentes estados de autenticación
- Integración con `LoginController`

#### LoginForm

**Ubicación**: `lib/login/login_form.dart`

**Componentes**:

- Formulario de inicio de sesión
- Validación de entrada
- Manejo de envío de formulario

### 3. Proveedores

#### AuthProvider

**Ubicación**: `lib/providers/auth_provider.dart`

**Funcionalidad**:

- Gestiona el estado de autenticación global
- Provee métodos para iniciar/cerrar sesión
- Almacena y recupera el token de acceso

## Flujo de Autenticación

### 1. Inicio del Proceso

**Usuario**: Hace clic en "Iniciar sesión con Trakt.tv"

**Aplicación**:

- Crea un estado inicial de autenticación
- Genera un valor aleatorio `state` para protección CSRF
- Abre el navegador web con la URL de autorización de Trakt.tv

**Código**:

```dart
void startAuth({bool signup = false, bool promptLogin = false}) {
  state = state.copyWith(showCodeInput: true);
  _authorizeWithTrakt(signup: signup, promptLogin: promptLogin);
}
```

### 2. Autorización en Trakt.tv

**Usuario**:

- Ingresa credenciales en la página de Trakt.tv
- Otorga permisos a la aplicación

**Servidor Trakt**:

- Valida las credenciales
- Redirige de vuelta a la aplicación con:
  - `code`: Código de autorización
  - `state`: El mismo valor generado inicialmente
  - `error`: En caso de fallo

**Aplicación**:

- Verifica que el `state` coincida
- Muestra campo para pegar el código

### 3. Intercambio de Código por Token

**Usuario**: Pega el código de autorización

**Aplicación**:

1. Muestra indicador de carga
2. Realiza petición POST a `/oauth/token` con:
   - `code`: Código de autorización
   - `client_id`: ID de la aplicación
   - `client_secret`: Secreto del cliente
   - `redirect_uri`: URI de redirección
   - `grant_type`: "authorization_code"

**Respuesta Exitosa (200 OK)**:

- `access_token`: Token de acceso
- `refresh_token`: Token para renovar el acceso
- `expires_in`: Tiempo de expiración
- `token_type`: Tipo de token (Bearer)

**Almacenamiento**:

- Guarda tokens en `SharedPreferences`
- Actualiza el estado de autenticación

**Código**:

```dart
Future<void> _exchangeCodeForToken(String code) async {
  try {
    state = state.copyWith(loading: true);
    final success = await ref.read(authProvider.notifier).login(code);
    if (success) {
      // Navegar a la pantalla principal
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      state = state.copyWith(
        loading: false,
        error: 'Error al iniciar sesión',
      );
    }
  } catch (e) {
    state = state.copyWith(
      loading: false,
      error: 'Error: ${e.toString()}',
    );
  }
}
```

### 4. Sesión Activa

**Aplicación**:

- Incluye `Authorization: Bearer <access_token>` en las cabeceras
- Maneja códigos de error 401 (No autorizado)
- Intenta renovar el token con `refresh_token` si es necesario

**Cierre de Sesión**:

1. Elimina tokens de `SharedPreferences`
2. Limpia el estado de autenticación
3. Redirige al usuario a la pantalla de inicio de sesión

**Código**:

```dart
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
  state = state.copyWith(username: null);
  if (context.mounted) {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
```

## Implementación Técnica

### OAuth 2.0 con Trakt.tv

La aplicación utiliza el flujo de autorización con código de autorización (Authorization Code Grant) de OAuth 2.0:

1. **Solicitud de Autorización**

   ```dart
   final url = Uri.https(
     'trakt.tv',
     '/oauth/authorize',
     {
       'response_type': 'code',
       'client_id': clientId,
       'redirect_uri': redirectUri,
       'state': state,
     },
   );
   ```

2. **Intercambio de Código por Token**
   ```dart
   final response = await http.post(
     Uri.https('api.trakt.tv', '/oauth/token'),
     body: {
       'code': code,
       'client_id': clientId,
       'client_secret': clientSecret,
       'redirect_uri': redirectUri,
       'grant_type': 'authorization_code',
     },
   );
   ```

### Almacenamiento

Los tokens de acceso y refresh se almacenan usando `shared_preferences`:

- Los tokens se guardan en el almacenamiento local del dispositivo
- Se utiliza para persistir la sesión del usuario entre reinicios de la aplicación
- La implementación actual no incluye cifrado adicional para los tokens almacenados

## Manejo de Errores

La aplicación maneja varios escenarios de error:

- Conexión a internet no disponible
- Credenciales inválidas
- Token expirado
- Errores del servidor

## Seguridad

- Todas las comunicaciones son a través de HTTPS
- Los tokens nunca se almacenan en texto plano
- Se implementa CSRF protection con el parámetro `state`
- Los tokens tienen un tiempo de expiración limitado

## Mejoras Futuras

- [ ] Añadir cifrado
- [ ] Implementar refresh token automático
- [ ] Añadir autenticación biométrica
- [ ] Mejorar manejo de sesiones expiradas

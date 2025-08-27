# Configuración de Barras de Sistema

## 📱 Introducción

Las barras de sistema (status bar y navigation bar) se configuran automáticamente para adaptarse a los temas claro y oscuro de la aplicación, creando una experiencia visual fluida e inmersiva.

## 🎨 Configuración Automática

### Tema Claro
- **Status Bar**: Fondo transparente, iconos oscuros
- **Navigation Bar**: Fondo transparente, iconos oscuros

### Tema Oscuro  
- **Status Bar**: Fondo transparente, iconos claros
- **Navigation Bar**: Fondo transparente, iconos claros

## 🔧 Implementación

### 1. Configuración Global (main.dart)
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Habilitar modo edge-to-edge (barras transparentes)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const MyApp());
}
```

### 2. Wrapper Automático
Cada pantalla está envuelta en `SystemBarsWrapper` que:
- Detecta automáticamente el tema actual
- Configura las barras según el tema
- Se actualiza cuando cambia el tema

```dart
routes: {
  AppRoutes.splash: (context) => const SystemBarsWrapper(child: SplashView()),
  AppRoutes.login: (context) => const SystemBarsWrapper(child: LoginView()),
  AppRoutes.home: (context) => const SystemBarsWrapper(child: HomeView()),
}
```

### 3. Configuraciones Especiales

Para pantallas con colores específicos (como el splash verde):

```dart
@override
void initState() {
  super.initState();
  
  // Configurar barras para fondo verde
  SystemBarsConfig.setCustomSystemBars(
    statusBarIconBrightness: Brightness.light,
    navigationBarIconBrightness: Brightness.light,
  );
}
```

## 🛠️ Clase SystemBarsConfig

### Métodos Disponibles

#### setLightSystemBars()
Configura las barras para tema claro (iconos oscuros)

#### setDarkSystemBars()
Configura las barras para tema oscuro (iconos claros)

#### setSystemBarsForTheme(BuildContext context)
Configura automáticamente según el tema actual

#### setCustomSystemBars(...)
Permite configuración personalizada:
- `statusBarColor`: Color de fondo del status bar
- `statusBarIconBrightness`: Brillo de los iconos del status bar
- `navigationBarColor`: Color de fondo de la navigation bar
- `navigationBarIconBrightness`: Brillo de los iconos de navegación

## 📋 Ventajas de esta Implementación

1. **Automática**: Se adapta al tema sin intervención manual
2. **Consistente**: Misma configuración en toda la app
3. **Flexible**: Permite configuraciones especiales cuando se necesiten
4. **Inmersiva**: Barras transparentes para experiencia edge-to-edge
5. **Responsive**: Cambia automáticamente con el tema del sistema

## 🎯 Casos de Uso

### Configuración Estándar
La mayoría de pantallas usan la configuración automática del `SystemBarsWrapper`.

### Configuración Personalizada
Para pantallas especiales como:
- Splash screens con colores únicos
- Pantallas con fondos de imagen
- Reproductor de video en pantalla completa
- Pantallas de bienvenida con gradientes

## 💡 Consejos

1. **No modifiques** las barras manualmente en cada pantalla
2. **Usa SystemBarsWrapper** para configuración automática
3. **Solo usa setCustomSystemBars()** para casos especiales
4. **Testa en ambos temas** para verificar legibilidad
5. **Considera el contraste** entre iconos y fondo

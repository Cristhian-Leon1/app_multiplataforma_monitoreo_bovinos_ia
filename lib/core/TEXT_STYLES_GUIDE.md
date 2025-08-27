# Guía de Estilos de Texto - App Monitoreo Bovinos IA

## 📚 Introducción

Los estilos de texto en nuestra aplicación están organizados siguiendo las mejores prácticas de Flutter y Material Design, integrados directamente en los temas claro y oscuro para garantizar consistencia y adaptabilidad automática.

## 🎨 Estructura de Estilos

### 1. Estilos del TextTheme (Automáticamente adaptativos)

Estos estilos están definidos en `AppTheme.lightTheme.textTheme` y `AppTheme.darkTheme.textTheme` y cambian automáticamente según el tema:

#### Títulos Principales
```dart
Theme.of(context).textTheme.displayLarge    // 32px, bold
Theme.of(context).textTheme.displayMedium   // 28px, bold  
Theme.of(context).textTheme.displaySmall    // 24px, bold
```

#### Encabezados
```dart
Theme.of(context).textTheme.headlineLarge   // 22px, w600
Theme.of(context).textTheme.headlineMedium  // 20px, w600
Theme.of(context).textTheme.headlineSmall   // 18px, w600
```

#### Títulos
```dart
Theme.of(context).textTheme.titleLarge      // 16px, w600
Theme.of(context).textTheme.titleMedium     // 14px, w600
Theme.of(context).textTheme.titleSmall      // 12px, w600
```

#### Cuerpo de Texto
```dart
Theme.of(context).textTheme.bodyLarge       // 16px, normal, height 1.5
Theme.of(context).textTheme.bodyMedium      // 14px, normal, height 1.4
Theme.of(context).textTheme.bodySmall       // 12px, normal, height 1.3
```

#### Labels
```dart
Theme.of(context).textTheme.labelLarge      // 14px, w500
Theme.of(context).textTheme.labelMedium     // 12px, w500
Theme.of(context).textTheme.labelSmall      // 10px, w500
```

### 2. Estilos Personalizados (AppTextStyles)

Para casos específicos que no están cubiertos por el TextTheme estándar:

#### Estilos Fijos (No cambian con el tema)
```dart
AppTextStyles.splashTitle                   // Título del splash (blanco)
AppTextStyles.splashSubtitle               // Subtítulo del splash (blanco70)
AppTextStyles.errorText                    // Texto de error (rojo)
AppTextStyles.successText                  // Texto de éxito (verde)
AppTextStyles.linkText                     // Texto de enlaces (verde, subrayado)
```

#### Estilos Adaptativos (Cambian con el tema)
```dart
AppTextStyles.getAppTitleStyle(context)     // Título de la app
AppTextStyles.getButtonTextStyle(context)   // Texto de botones
AppTextStyles.getLabelStyle(context)        // Labels de formularios
AppTextStyles.getCardTitleStyle(context)    // Títulos de cards
AppTextStyles.getCardSubtitleStyle(context) // Subtítulos de cards
```

## 🚀 Ejemplos de Uso

### Ejemplo 1: Título principal que se adapta al tema
```dart
Text(
  'Mi Título',
  style: Theme.of(context).textTheme.displayLarge,
)
```

### Ejemplo 2: Texto de cuerpo que se adapta al tema
```dart
Text(
  'Este es el contenido principal...',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### Ejemplo 3: Título de card adaptativo
```dart
Text(
  'Título del Card',
  style: AppTextStyles.getCardTitleStyle(context),
)
```

### Ejemplo 4: Estilo fijo para splash
```dart
Text(
  'Bienvenido',
  style: AppTextStyles.splashTitle,
)
```

## 🎯 Cuándo usar cada tipo

### Usa TextTheme cuando:
- Necesites estilos estándar de Material Design
- Quieras que el texto se adapte automáticamente al tema claro/oscuro
- Trabajes con títulos, cuerpo de texto, o labels comunes

### Usa AppTextStyles cuando:
- Necesites estilos específicos de la aplicación
- Requieras colores que no cambien con el tema (como splash, errores)
- Trabajes con elementos únicos como cards, botones personalizados

## 📋 Colores por Tema

### Tema Claro
- Texto principal: `Colors.black87`
- Texto secundario: `Colors.black54`
- Texto terciario: `Colors.black54`

### Tema Oscuro  
- Texto principal: `Colors.white`
- Texto secundario: `Colors.white70`
- Texto terciario: `Colors.white70`

## 🔧 Extensión y Modificación

Para agregar nuevos estilos:

1. **Si es un estilo estándar**: Agrégalo al `textTheme` en `AppTheme`
2. **Si es específico de la app**: Agrégalo a `AppTextStyles`
3. **Si debe adaptarse al tema**: Crea un método `getXXXStyle(BuildContext context)`

## 💡 Consejos de Uso

1. **Siempre prefiere** `Theme.of(context).textTheme` para estilos estándar
2. **Usa BuildContext** para estilos que deben adaptarse al tema
3. **Evita hardcodear colores** en los estilos de texto
4. **Testa en ambos temas** (claro y oscuro) para verificar legibilidad
5. **Mantén consistencia** usando los estilos predefinidos

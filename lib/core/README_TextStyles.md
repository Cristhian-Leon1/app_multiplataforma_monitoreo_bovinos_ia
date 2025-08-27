# Guía de Estilos de Texto - AppTextStyles

Esta guía explica cómo usar los estilos de texto reutilizables en la aplicación de Monitoreo Bovinos IA.

## 📍 Ubicación
Los estilos de texto están definidos en `lib/core/app_theme.dart` en la clase `AppTextStyles`.

## 🎨 Categorías de Estilos

### 1. **Títulos Principales**
```dart
// Para títulos muy grandes (32px)
Text('Mi Título', style: AppTextStyles.titleLarge)

// Para títulos medianos (24px) 
Text('Mi Título', style: AppTextStyles.titleMedium)

// Para títulos pequeños (20px)
Text('Mi Título', style: AppTextStyles.titleSmall)
```

### 2. **Encabezados**
```dart
// Para encabezados grandes (18px)
Text('Mi Encabezado', style: AppTextStyles.headingLarge)

// Para encabezados medianos (16px)
Text('Mi Encabezado', style: AppTextStyles.headingMedium)

// Para encabezados pequeños (14px)
Text('Mi Encabezado', style: AppTextStyles.headingSmall)
```

### 3. **Texto de Cuerpo**
```dart
// Para texto principal grande (16px)
Text('Contenido principal', style: AppTextStyles.bodyLarge)

// Para texto principal mediano (14px)
Text('Contenido principal', style: AppTextStyles.bodyMedium)

// Para texto principal pequeño (12px)
Text('Contenido secundario', style: AppTextStyles.bodySmall)
```

### 4. **Texto Secundario**
```dart
// Para subtítulos (16px)
Text('Subtítulo', style: AppTextStyles.subtitle)

// Para texto explicativo (12px)
Text('Texto pequeño', style: AppTextStyles.caption)
```

## 🎯 Estilos Específicos de la App

### **Splash Screen**
```dart
Text('Monitoreo Bovinos IA', style: AppTextStyles.splashTitle)
Text('Tecnología para el campo', style: AppTextStyles.splashSubtitle)
```

### **Branding**
```dart
Text('Monitoreo Bovinos IA', style: AppTextStyles.appTitle)
```

### **Botones**
```dart
Text('Iniciar Sesión', style: AppTextStyles.buttonText)
```

### **Formularios**
```dart
Text('Email', style: AppTextStyles.labelText)
Text('Error: Campo requerido', style: AppTextStyles.errorText)
Text('Éxito: Datos guardados', style: AppTextStyles.successText)
```

### **Enlaces**
```dart
Text('¿Olvidaste tu contraseña?', style: AppTextStyles.linkText)
```

### **Cards**
```dart
Text('Título de Card', style: AppTextStyles.cardTitle)
Text('Subtítulo de card', style: AppTextStyles.cardSubtitle)
```

## 🌈 Variaciones de Color

### **Texto Blanco**
```dart
Text('Título Blanco', style: AppTextStyles.titleLargeWhite)
Text('Título Mediano Blanco', style: AppTextStyles.titleMediumWhite)
Text('Encabezado Blanco', style: AppTextStyles.headingWhite)
Text('Cuerpo Blanco', style: AppTextStyles.bodyWhite)
```

### **Texto Color Primario**
```dart
Text('Título Verde', style: AppTextStyles.titleLargePrimary)
Text('Título Mediano Verde', style: AppTextStyles.titleMediumPrimary)
Text('Encabezado Verde', style: AppTextStyles.headingPrimary)
```

## 🛠️ Personalización Avanzada

Si necesitas modificar un estilo existente:

```dart
Text(
  'Mi texto personalizado',
  style: AppTextStyles.titleMedium.copyWith(
    color: Colors.blue,
    fontSize: 26,
    fontWeight: FontWeight.w900,
  ),
)
```

## 📐 Especificaciones de Diseño

| Estilo | Tamaño | Peso | Color por defecto |
|--------|--------|------|-------------------|
| titleLarge | 32px | bold | Colors.black87 |
| titleMedium | 24px | bold | Colors.black87 |
| titleSmall | 20px | w600 | Colors.black87 |
| headingLarge | 18px | w600 | Colors.black87 |
| headingMedium | 16px | w600 | Colors.black87 |
| headingSmall | 14px | w600 | Colors.black87 |
| bodyLarge | 16px | normal | Colors.black87 |
| bodyMedium | 14px | normal | Colors.black87 |
| bodySmall | 12px | normal | Colors.black54 |
| subtitle | 16px | w400 | Colors.black54 |
| caption | 12px | w400 | Colors.black54 |

## ✅ Mejores Prácticas

1. **Consistencia**: Usa siempre los estilos predefinidos antes de crear nuevos
2. **Jerarquía**: Respeta la jerarquía visual usando los tamaños apropiados
3. **Legibilidad**: Los estilos están optimizados para legibilidad
4. **Mantenimiento**: Si necesitas un nuevo estilo, agrégalo a `AppTextStyles`
5. **Reutilización**: Usa `copyWith()` para pequeñas modificaciones

## 🔄 Ejemplos de Uso Real

### Pantalla de Login
```dart
Text('Monitoreo Bovinos IA', style: AppTextStyles.appTitle)
Text('Bienvenido de vuelta', style: AppTextStyles.subtitle)
Text('Email', style: AppTextStyles.labelText)
Text('Iniciar Sesión', style: AppTextStyles.buttonText)
```

### Pantalla Principal
```dart
Text('¡Bienvenido!', style: AppTextStyles.titleMediumWhite)
Text('Mis Bovinos', style: AppTextStyles.cardTitle)
Text('Ver ganado registrado', style: AppTextStyles.cardSubtitle)
```

### Mensajes de Estado
```dart
Text('Usuario creado exitosamente', style: AppTextStyles.successText)
Text('Error: Credenciales inválidas', style: AppTextStyles.errorText)
```

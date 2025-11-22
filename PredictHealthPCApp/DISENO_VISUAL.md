# 🎨 PredictHealth - Descripción Visual

## 📱 Pantallas de la Aplicación

### 1. 🔐 LOGIN (Pantalla inicial)
```
┌────────────────────────────────────────┐
│                                        │
│           [Logo]                       │
│         PredictHealth                  │
│      Tu salud en tus manos             │
│                                        │
│      Correo electrónico                │
│      [________________]                │
│                                        │
│      Contraseña                        │
│      [________________]                │
│                                        │
│      [  Iniciar Sesión  ]              │
│                                        │
└────────────────────────────────────────┘
```
**Colores:**
- Fondo: Blanco
- Logo y título: Azul (#2196F3)
- Botón: Azul con hover oscuro

---

### 2. 📊 DASHBOARD (Pantalla principal)

```
┌──────┬────────────────────────────────────────────┐
│      │  📊 Dashboard de Salud                     │
│ NAV  │  Bienvenido, [Nombre Paciente]             │
│ BAR  │                                            │
│      ├────────────────┬───────────────────────────┤
│ 📊   │ [Gráfica 1]   │  [Gráfica 2]              │
│ Dash │ Presión       │  Frecuencia               │
│      │ Arterial      │  Cardíaca                 │
│ 📅   ├────────────────┼───────────────────────────┤
│ Res. │ [Gráfica 3]   │  [Gráfica 4]              │
│      │ Control       │  Actividad                │
│ 📋   │ de Peso       │  Física                   │
│ Hist.├────────────────┼───────────────────────────┤
│      │ [Gráfica 5]   │  [Gráfica 6]              │
│ 👤   │ Calidad       │  Citas                    │
│ Perf.│ del Sueño     │  Mensuales                │
│      │               │                           │
│ 🚪   │               │                           │
│ Exit │               │                           │
└──────┴────────────────┴───────────────────────────┘
```

**6 Gráficas incluidas:**
1. **Presión Arterial** - Línea doble (sistólica/diastólica)
2. **Frecuencia Cardíaca** - Línea con relleno
3. **Control de Peso** - Barras
4. **Actividad Física** - Barras de pasos diarios
5. **Calidad del Sueño** - Barras de horas
6. **Citas Mensuales** - Línea con puntos

**Colores de las gráficas:**
- Azul principal para datos normales
- Verde para objetivos alcanzados
- Amarillo para advertencias
- Rojo para datos críticos

---

### 3. 📅 RESERVACIONES

```
┌──────┬────────────────────────────────────────────┐
│      │  📅 Mis Reservaciones                      │
│ NAV  │                    [+ Nueva Reservación]   │
│ BAR  │                                            │
│      │  ┌────────────────────────────────────┐   │
│      │  │ Consulta General         [✓]      │   │
│      │  │ 👨‍⚕️ Dr. Juan Pérez              │   │
│      │  │ 📅 2024-11-25 • ⏰ 10:00          │   │
│      │  └────────────────────────────────────┘   │
│      │                                            │
│      │  ┌────────────────────────────────────┐   │
│      │  │ Cardiología             [⏳]      │   │
│      │  │ 👨‍⚕️ Dr. Carlos Martínez         │   │
│      │  │ 📅 2024-12-05 • ⏰ 14:30          │   │
│      │  └────────────────────────────────────┘   │
└──────┴────────────────────────────────────────────┘
```

**Modal para nueva reservación:**
```
        ┌──────────────────────────┐
        │  Nueva Reservación        │
        │                          │
        │  Tipo de Consulta        │
        │  [Consulta General ▼]    │
        │                          │
        │  Doctor                  │
        │  [Dr. Juan Pérez ▼]      │
        │                          │
        │  Fecha                   │
        │  [2024-12-01]            │
        │                          │
        │  Hora                    │
        │  [10:00]                 │
        │                          │
        │  [Cancelar]  [Guardar]   │
        └──────────────────────────┘
```

---

### 4. 📋 HISTORIAL MÉDICO

```
┌──────┬────────────────────────────────────────────┐
│      │  📋 Historial Médico                       │
│ NAV  │                                            │
│ BAR  │  ● ─────────────────────────────────────  │
│      │    ┌────────────────────────────────────┐ │
│      │    │ 📅 2024-11-01  [Consulta General] │ │
│      │    │ 👨‍⚕️ Dr. Juan Pérez               │ │
│      │    │                                    │ │
│      │    │ Diagnóstico:                       │ │
│      │    │ Chequeo rutinario                  │ │
│      │    │                                    │ │
│      │    │ 📝 Notas:                          │ │
│      │    │ Paciente en buen estado de salud  │ │
│      │    └────────────────────────────────────┘ │
│      │  │                                         │
│      │  ● ─────────────────────────────────────  │
│      │    ┌────────────────────────────────────┐ │
│      │    │ 📅 2024-10-15  [Análisis Sangre] │ │
│      │    │ 👨‍⚕️ Dra. Ana López              │ │
│      │    │ ...                                │ │
└──────┴────────────────────────────────────────────┘
```

**Características:**
- Timeline visual con línea vertical
- Cards con información completa
- Badges de colores según tipo de consulta
- Scroll para ver todo el historial

---

### 5. 👤 PERFIL

```
┌──────┬────────────────────────────────────────────┐
│      │  👤 Mi Perfil                 [✏️ Editar] │
│ NAV  │                                            │
│ BAR  │        ┌────────────────────┐              │
│      │        │       👤           │              │
│      │        │                    │              │
│      │        │   Paciente         │              │
│      │        └────────────────────┘              │
│      │     [Cambiar foto]   [Eliminar foto]       │
│      │  Nombre Completo                           │
│      │  [María García________________]            │
│      │                                            │
│      │  Correo Electrónico                        │
│      │  [maria@email.com_________]                │
│      │                                            │
│      │  Teléfono                                  │
│      │  [8112345678______________]                │
│      │                                            │
│      │  Fecha de Nacimiento                       │
│      │  [1995-05-15______________]                │
│      │                                            │
│      │      [Cancelar]  [Guardar Cambios]         │
└──────┴────────────────────────────────────────────┘
```

**Modos:**
- **Vista:** Campos deshabilitados (gris claro)
- **Edición:** Campos habilitados (blanco), botones visibles

---

## 🎨 Paleta de Colores Usada

### Colores Principales
- **Azul Principal:** `#2196F3` - Botones, headers
- **Azul Oscuro:** `#2B1AE9` - Sidebar, hover
- **Azul Claro:** `#67BFD5` - Acentos

### Colores Secundarios
- **Morado:** `#8B5CF6` - Botones secundarios
- **Morado Oscuro:** `#7C3AED` - Hover

### Neutrales
- **Blanco:** `#FFFFFF` - Fondo cards
- **Gris Claro:** `#F9FAFB` - Fondo general
- **Gris Medio:** `#6B7280` - Texto secundario
- **Gris Oscuro:** `#374151` - Texto principal

### Status
- **Verde:** `#10B981` - Éxito, confirmado
- **Amarillo:** `#F59E0B` - Advertencia, pendiente
- **Rojo:** `#EF4444` - Error, crítico

---

## 🖥️ Diseño Responsive

**Tamaño de ventana:** 1800x1500 px (configurable)

**Layout:**
- **Sidebar:** 250px fijo
- **Content:** Flexible, ocupa el resto
- **Cards:** Se adaptan al ancho disponible
- **Gráficas:** Grid 2x3 en pantallas normales

---

## ✨ Características de UI/UX

1. **Navegación intuitiva** - Sidebar siempre visible
2. **Feedback visual** - Hover effects en botones
3. **Iconos descriptivos** - Emojis para mejor comprensión
4. **Badges de estado** - Color-coded para rápida lectura
5. **Scroll suave** - En todas las vistas con mucho contenido
6. **Modals centrados** - Para acciones importantes
7. **Validación de formularios** - Con mensajes claros

---

## 🚀 Ventajas del diseño

✅ **Moderna** - Usa CustomTkinter para look profesional
✅ **Limpia** - Mucho espacio en blanco, fácil de leer
✅ **Consistente** - Mismos colores y estilos en toda la app
✅ **Accesible** - Contraste adecuado, fuentes legibles
✅ **Funcional** - Todo a máximo 2 clicks de distancia

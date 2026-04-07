# Reporte de Retrospectiva de Pruebas - Fix de Herencia de Enemigos

## 1. Resumen de la Tarea
Se abordó un error crítico de Godot donde las clases `Defragmenter` y `BitScrubber` no podían resolver su superclase `Enemy`, a pesar de estar definida globalmente con `class_name`.

## 2. Estrategia de Prueba
- **Análisis de Código**: Se revisaron las definiciones de `class_name` en `Enemy.gd`, `Defragmenter.gd` y `BitScrubber.gd`.
- **Verificación de Caché**: Se inspeccionó `.godot/global_script_class_cache.cfg` para confirmar que el motor de Godot reconoce las clases y sus rutas.
- **Validación Estática**: Se utilizó la herramienta `lint` para verificar que el analizador de GDScript no reporte errores tras los cambios.

## 3. Ejecución de Pruebas
- **Paso 1**: Revertir la herencia por ruta (`extends "res://..."`) a herencia por nombre de clase (`extends Enemy`).
- **Paso 2**: Ejecutar `lint` en `Defragmenter.gd`. Resultado: **PASS**.
- **Paso 3**: Ejecutar `lint` en `BitScrubber.gd`. Resultado: **PASS**.
- **Paso 4**: Verificar usos en `SaveManager.gd` para asegurar que el operador `is` funcione correctamente.

## 4. Resultados
- El analizador de Godot ahora reconoce correctamente la jerarquía de clases.
- Se eliminó la ambigüedad causada por el uso simultáneo de `class_name` y herencia por ruta explícita, lo cual a veces confunde al sistema de indexación de Godot 4.

## 5. Retrospectiva
- **Qué funcionó**: Volver a la herencia estándar por `class_name` después de asegurar que el archivo de caché estaba actualizado permitió que el motor resolviera las dependencias de forma nativa.
- **Lecciones aprendidas**: En Godot 4, mezclar herencia por ruta con `class_name` en la misma jerarquía puede causar errores de "Could not parse global class" si el motor intenta indexarlas en un orden específico. Es mejor mantener la consistencia usando nombres de clase globales.

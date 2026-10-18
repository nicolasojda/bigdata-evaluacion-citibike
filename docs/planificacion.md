# Planificación y control del proyecto

## Roles

| Integrante | Rol | Responsabilidades |
|---|---|---|
| Nicolás Ojeda | Arquitecto cloud e ingeniero de datos | Arquitectura, configuración de IAM, creación del dataset, ingesta, particionamiento, clusterización y estructura del repositorio |
| Benjamín Sotomayor | Analista y científico de datos | Análisis exploratorio, preparación de variables, entrenamiento y evaluación del modelo, interpretación de métricas |
| Ambos | Trabajo conjunto | Evaluación e inferencia final, informe técnico y revisión antes de la entrega |

## Carta Gantt

| Fase | Tarea | Responsable | Días |
|---|---|---|---|
| 1. Arquitectura e ingesta | Diseño de arquitectura y diagrama | Nicolás Ojeda | 1 a 2 |
| | Configuración del proyecto GCP, IAM y dataset | Nicolás Ojeda | 1 a 2 |
| | Reconocimiento del esquema citibike_trips | Benjamín Sotomayor | 2 a 3 |
| | Ingesta por lotes (CREATE TABLE AS SELECT) | Nicolás Ojeda | 3 |
| 2. Depuración y optimización | Particionamiento y clusterización | Nicolás Ojeda | 4 a 5 |
| | Script de exportación a Parquet | Nicolás Ojeda | 5 a 6 |
| | Análisis exploratorio distribuido | Benjamín Sotomayor | 4 a 6 |
| 3. Modelamiento | Modelo base de regresión lineal | Benjamín Sotomayor | 7 |
| | Limpieza de valores extremos y reentrenamiento | Benjamín Sotomayor | 8 |
| | Evaluación e inferencia | Ambos | 9 |
| 4. Documentación | Estructura del repositorio | Nicolás Ojeda | 10 a 11 |
| | Redacción del informe técnico | Ambos | 10 a 12 |
| | Revisión final y entrega | Ambos | 12 |

## Hitos

| Hito | Criterio de aceptación | Estado |
|---|---|---|
| H1. Entorno configurado y datos ingeridos | Dataset creado, roles asignados y tabla copiada desde el conjunto público | Cumplido |
| H2. Tabla optimizada y análisis exploratorio | Tabla particionada y clusterizada; estadísticos y gráficos calculados | Cumplido |
| H3. Modelo entrenado y evaluado | Métricas de ML.EVALUATE para ambas iteraciones | Cumplido |
| H4. Entrega final | Informe técnico y repositorio revisados por ambos integrantes | Cumplido |

## Bitácora de incidencias

| ID | Incidencia | Impacto | Resolución |
|---|---|---|---|
| INC-01 | Consultas exploratorias sin filtro de fecha consumían una fracción alta de la cuota de lectura | Riesgo de agotar el nivel gratuito | Tabla particionada y filtro obligatorio por la columna de partición |
| INC-02 | R² negativo en la primera iteración del modelo | Modelo sin capacidad predictiva | Filtro de viajes entre 60 y 7.200 segundos, nuevas variables y reentrenamiento |
| INC-03 | Error de permisos al ejecutar ML.EVALUATE desde la cuenta del analista | Bloqueo de la evaluación | Asignación de roles/bigquery.jobUser a nivel de proyecto |
| INC-04 | La tabla particionada por día apareció vacía: en modo sandbox cada partición de tiempo vence a los 60 días según su fecha | Pérdida del contenido de la tabla optimizada | Nueva versión particionada por rango entero del año, que no está sujeta a ese vencimiento |
| INC-05 | El entrenamiento de la iteración 2 sobre todos los viajes desde 2016 superó la cuota de 10 GB de almacenamiento del sandbox | Bloqueo del entrenamiento | Entrenamiento sobre una muestra determinística del 10 % de los viajes |

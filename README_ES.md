# Sistema de Bases de Datos Distribuidas - Bancos/Préstamos

## Descripción

Sistema de bases de datos distribuidas heterogéneas para una aplicación bancaria con fragmentación horizontal por región.

## Arquitectura

- **Nodo 1 (Oracle)**: Datos de Región A
- **Nodo 2 (Oracle)**: Datos de Región B
- **Nodo 3 (Oracle)**: Replicación completa de todos los datos
- **MySQL (Docker)**: Respaldo/replica de los datos del Nodo 3

## Requisitos Previos

- Docker Desktop instalado y ejecutándose
- Python 3 instalado
- Acceso a Oracle Container Registry (para descargar imágenes de Oracle)

## Instrucciones de Instalación

### Paso 1: Instalar Dependencias de Python

Abre PowerShell en la carpeta del proyecto y ejecuta:

```powershell
pip install -r requirements.txt
```

### Paso 2: Iniciar Contenedores Oracle

Si los contenedores Oracle no están ejecutándose, inícialos:

```powershell
docker-compose -f docker-compose-oracle.yml up -d
```

**Espera 5-10 minutos** para que las bases de datos se inicialicen. Puedes verificar el progreso con:

```powershell
docker-compose -f docker-compose-oracle.yml logs -f
```

Espera hasta ver el mensaje: `DATABASE IS READY TO USE!`

### Paso 3: Configurar Enlaces de Base de Datos

Crea los enlaces entre todos los nodos Oracle:

```powershell
.\run_sql_node1.ps1 00_setup_database_links.sql
.\run_sql_node2.ps1 00_setup_database_links.sql
.\run_sql_node3.ps1 00_setup_database_links.sql
```

### Paso 4: Iniciar Contenedor MySQL

```powershell
docker-compose -f docker-compose-mysql.yml up -d
```

### Paso 5: Crear Tablas y Fragmentar Datos

Crea las tablas en cada nodo:

```powershell
.\run_sql_node1.ps1 01_create_tables_node1.sql
.\run_sql_node2.ps1 02_create_tables_node2.sql
.\run_sql_node3.ps1 03_create_tables_node3.sql
.\setup_mysql.ps1
```

### Paso 6: Crear Vistas Globales

Crea las vistas que permiten consultar datos de todas las regiones:

```powershell
.\run_sql_node1.ps1 05_create_global_views.sql
.\run_sql_node2.ps1 05_create_global_views.sql
.\run_sql_node3.ps1 05_create_global_views.sql
```

### Paso 7: Sincronizar Datos a MySQL

Copia todos los datos del Nodo 3 a MySQL como respaldo:

```powershell
python sync_node3_to_mysql.py
```

### Paso 8: Ejecutar la Aplicación

```powershell
python bank_app.py
```

## Instalación Automática (Recomendado)

Para instalar todo automáticamente, ejecuta:

```powershell
.\setup_all.ps1
```

Este script ejecuta todos los pasos anteriores en orden.

## Uso de la Aplicación

Al ejecutar `python bank_app.py`, verás un menú con las siguientes opciones:

1. **Ver todas las sucursales** - Muestra sucursales de todas las regiones
2. **Ver sucursales por región** - Filtra por Región A o B
3. **Ver todos los préstamos** - Muestra préstamos de todas las regiones
4. **Ver préstamos por región** - Filtra préstamos por región
5. **Insertar nueva sucursal** - Agrega una sucursal (se enruta automáticamente al nodo correcto)
6. **Insertar nuevo préstamo** - Agrega un préstamo (se enruta automáticamente según la sucursal)
7. **Ver estadísticas** - Muestra estadísticas generales
8. **Cambiar nodo de base de datos** - Cambia la conexión a otro nodo (node1, node2, node3, mysql)
9. **Salir** - Cierra la aplicación

## Características

- ✅ Fragmentación horizontal por región
- ✅ Enrutamiento automático de inserciones al nodo correcto
- ✅ Consultas transparentes entre todas las regiones
- ✅ Soporte de bases de datos heterogéneas (Oracle + MySQL)
- ✅ Interfaz de línea de comandos simple

## Archivos Importantes

- `docker-compose-oracle.yml` - Configuración de contenedores Oracle
- `docker-compose-mysql.yml` - Configuración de contenedor MySQL
- `00_setup_database_links.sql` - Script para crear enlaces entre nodos
- `01-03_create_tables_node*.sql` - Scripts para crear tablas en cada nodo
- `05_create_global_views.sql` - Script para crear vistas globales
- `sync_node3_to_mysql.py` - Script para sincronizar datos a MySQL
- `bank_app.py` - Aplicación principal

## Notas

- Las bases de datos Oracle tardan varios minutos en inicializarse la primera vez
- Los datos se fragmentan automáticamente por región
- Las inserciones se enrutan automáticamente al nodo correcto según la región
- MySQL actúa como respaldo de los datos del Nodo 3


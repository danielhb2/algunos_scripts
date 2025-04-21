# Gestor de Notas en Bash
![](imagenes/captura1.png)
## Descripción
Este script es un gestor de notas simple pero potente que permite crear, editar y organizar notas diarias desde la línea de comandos. Las notas se organizan automáticamente en directorios por año y se nombran según la fecha de creación.

## Características
- Interfaz interactiva con navegación mediante flechas del teclado
- Organización automática de notas por año
- Dos tipos de notas por día:
  - Nota principal (.txt)
  - Nota anexa (.anexo)
- Búsqueda de texto en todas las notas
- Previsualización de contenido
- Edición y agregado de contenido
- Confirmación interactiva para operaciones críticas

## Dependencias
El script requiere las siguientes herramientas:

### Requeridas
- `bash`: Shell en el que corre el script
- `fzf`: Para la interfaz interactiva y selección de archivos
- `nano`: Editor de texto por defecto
- `cat`: Para visualizar contenido (si bat no está instalado)
- `grep`: Para búsqueda de texto
- `find`: Para listar archivos
- `date`: Para manejar fechas

### Opcionales
- `bat`: Alternativa mejorada a cat (proporciona syntax highlighting)

## Instalación

1. Instalar las dependencias necesarias:

En Ubuntu/Debian:
```bash
sudo apt install fzf nano bat
```

En Fedora:
```bash
sudo dnf install fzf nano bat
```

En Arch Linux:
```bash
sudo pacman -S fzf nano bat
```

2. Hacer el script ejecutable:
```bash
chmod +x notas.sh
```

## Uso

### Iniciar el programa
```bash
./notas.sh
```

### Estructura de directorios
El script crea y mantiene la siguiente estructura:
```
~/mis_notas/
├── 2024/
│   ├── 28-01-2024.txt
│   └── 28-01-2024.anexo
├── 2025/
└── ...
```

### Operaciones disponibles
1. **Nueva nota**: Crea una nota principal para el día actual
2. **Nueva nota anexa**: Crea una nota anexa para el día actual
3. **Editar nota**: Seleccionar y editar una nota existente
4. **Previsualizar notas**: Ver el contenido de una nota
5. **Agregar contenido**: Añadir texto a una nota existente
6. **Eliminar nota**: Borrar una nota seleccionada
7. **Buscar texto**: Buscar texto en todas las notas

### Navegación
- Usar flechas ↑/↓ para moverse entre opciones
- Enter para seleccionar
- Esc para cancelar/volver
- / para buscar en listas de archivos

## Personalización

El script usa las siguientes aplicaciones por defecto:
- Editor: nano
- Visor: bat (o cat si bat no está instalado)

Para cambiar el editor, modifica la variable EDITOR al inicio del script:
```bash
EDITOR="nano"  # Cambiar a vim, emacs, etc.
```

## Notas y Consideraciones
- Las notas se guardan en texto plano
- Se crea automáticamente un directorio para cada año
- Solo se permite una nota principal y una anexa por día
- Los archivos se nombran automáticamente con el formato DD-MM-YYYY

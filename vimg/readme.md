# VIMG - Visor de Imágenes con FZF (castellano)

Un visor de imágenes sencillo pero potente para línea de comandos que funciona tanto en terminales TTY como en entorno gráfico, con navegación de directorios integrada usando FZF.

![ejemplo1](vimg01.webp)  ![ejemplo2](vimg02.webp)

## Características

- **Doble modo**: Funciona en modo gráfico (con feh) y en terminales TTY (con fbi)
- **Navegación intuitiva**: Interfaz basada en FZF para seleccionar imágenes y navegar entre directorios
- **Fácil de usar**: Sin configuración compleja, simplemente ejecuta el script
- **Autodetección de entorno**: Determina automáticamente si está en un entorno gráfico o TTY
- **Adaptable**: Ajusta automáticamente las imágenes según el tamaño de la terminal en modo TTY
- **Navegación entre directorios**: Permite explorar toda la estructura de directorios sin salir del visor

## Dependencias

Para usar VIMG necesitarás tener instalados:

- **fzf**: Para la interfaz de selección de imágenes y navegación
- **feh**: Para visualizar imágenes en entorno gráfico (X11/Wayland)
- **fbi**: Para visualizar imágenes en TTY (modo consola)
- **find**: Para buscar imágenes y directorios (normalmente preinstalado)

Dependencias opcionales pero recomendadas:
- **ImageMagick**: Para la detección del tamaño de imagen (comando `identify`)

### Instalación de dependencias

#### Debian/Ubuntu/Linux Mint
```bash
# Instalar fzf (selector interactivo)
sudo apt install fzf

# Instalar feh (visor de imágenes para entorno gráfico)
sudo apt install feh

# Instalar fbida (contiene fbi para visualizar imágenes en TTY)
sudo apt install fbida

# Instalar ImageMagick (para detección de tamaño de imágenes)
sudo apt install imagemagick

# findutils (normalmente ya instalado)
sudo apt install findutils

# Todo en un solo comando:
sudo apt install fzf feh fbida imagemagick findutils
```

#### Arch Linux/Manjaro/EndeavourOS
```bash
# Instalar fzf
sudo pacman -S fzf

# Instalar feh
sudo pacman -S feh

# Instalar fbida (contiene fbi)
sudo pacman -S fbida

# Instalar ImageMagick
sudo pacman -S imagemagick

# findutils (normalmente ya instalado)
sudo pacman -S findutils

# Todo en un solo comando:
sudo pacman -S fzf feh fbida imagemagick findutils
```

#### Fedora/CentOS/RHEL
```bash
# Instalar fzf
sudo dnf install fzf

# Instalar feh
sudo dnf install feh

# Instalar fbida (contiene fbi)
sudo dnf install fbida

# Instalar ImageMagick
sudo dnf install ImageMagick

# findutils (normalmente ya instalado)
sudo dnf install findutils

# Todo en un solo comando:
sudo dnf install fzf feh fbida ImageMagick findutils
```

#### openSUSE
```bash
# Instalar fzf
sudo zypper install fzf

# Instalar feh
sudo zypper install feh

# Instalar fbida (contiene fbi)
sudo zypper install fbida

# Instalar ImageMagick
sudo zypper install ImageMagick

# findutils (normalmente ya instalado)
sudo zypper install findutils

# Todo en un solo comando:
sudo zypper install fzf feh fbida ImageMagick findutils
```

#### Gentoo
```bash
# Instalar fzf
sudo emerge --ask app-shells/fzf

# Instalar feh
sudo emerge --ask media-gfx/feh

# Instalar fbida (contiene fbi)
sudo emerge --ask media-gfx/fbida

# Instalar ImageMagick
sudo emerge --ask media-gfx/imagemagick

# findutils (normalmente ya instalado)
sudo emerge --ask sys-apps/findutils
```

#### Con gestores de paquetes específicos

Con Homebrew (Linux/macOS):
```bash
brew install fzf feh imagemagick findutils
# Nota: fbida no está disponible en Homebrew, necesitarás instalarlo manualmente
```

Con Snap (donde esté disponible):
```bash
sudo snap install fzf
sudo snap install feh
# Nota: no todos los paquetes están disponibles como snaps
```

## Instalación

1. Descarga el script `vimg.sh`:
   ```bash
   curl -o vimg.sh algunos_scripts/tree/main/vimg/vimg.sh
   ```

2. Dale permisos de ejecución:
   ```bash
   chmod +x vimg.sh
   ```

3. Opcional: Haz que esté disponible globalmente en tu sistema:
   ```bash
   sudo cp vimg.sh /usr/local/bin/vimg
   ```

## Uso

### Uso básico

```bash
./vimg.sh
```

Ejecuta el script sin argumentos para mostrar todas las imágenes del directorio actual y luego entrar al modo de navegación con fzf.

### Iniciar con un directorio específico

```bash
./vimg.sh /ruta/a/mis/fotos
```

### Iniciar con una imagen específica

```bash
./vimg.sh /ruta/a/mis/fotos/imagen.jpg
```

El visor comenzará mostrando esta imagen y luego permitirá navegar entre todas las imágenes del directorio.

## Navegación

Una vez dentro del visor, puedes:

- **Ver imágenes**: Selecciona cualquier imagen (marcada con 🖼️) para verla
- **Navegar directorios**: Selecciona cualquier directorio (marcado con 📁) para entrar en él
- **Subir un nivel**: Selecciona la opción "[SUBIR DIRECTORIO]" para ir al directorio padre
- **Salir**: Presiona `Esc` o `Ctrl+C` para salir del programa

### Controles durante la visualización

#### En modo gráfico (feh)

- **Avanzar imagen**: `Espacio` o `→` o `PgDown`
- **Retroceder imagen**: `Backspace` o `←` o `PgUp`
- **Zoom**: `+` para acercar, `-` para alejar
- **Pantalla completa**: `f`
- **Salir**: `q` o `Esc`

Consulta la documentación de feh (`man feh`) para más opciones.

#### En modo TTY (fbi)

- **Avanzar imagen**: `PgDown`
- **Retroceder imagen**: `PgUp`
- **Zoom**: `+` para acercar, `-` para alejar, `a` para ajustar a pantalla
- **Moverse por la imagen**: Usa las teclas de dirección
- **Salir**: `q` o `Esc`

Consulta la documentación de fbi (`man fbi`) para más opciones.

## Personalización

El script incluye opciones de personalización para fzf que puedes modificar editando la sección `fzf_opts` al inicio del archivo. Algunas opciones que puedes personalizar:

- Colores
- Disposición
- Etiquetas de borde
- Símbolos de puntero y marcador

## Formatos soportados

El script soporta los siguientes formatos de imagen:
- JPG/JPEG
- PNG
- GIF
- WEBP
- BMP

Para añadir soporte para más formatos, modifica el patrón en la función `find_images()`.

## Resolución de problemas

### El script muestra "Error: XXX no está instalado"

Asegúrate de instalar todas las dependencias requeridas como se menciona en la sección de dependencias.

### Imágenes distorsionadas en modo TTY

Si las imágenes aparecen distorsionadas en modo TTY, puede ser por las opciones de escalado. El script intenta detectar el tamaño de las imágenes mediante `identify` (ImageMagick). Si no está instalado, prueba a instalarlo o modifica la función `run_fbi()` para ajustar las opciones de fbi.

### Las imágenes no se muestran correctamente en algunos terminales

Algunos terminales tienen limitaciones para mostrar imágenes. Asegúrate de que estás usando un terminal compatible con fbi/feh.

## Contribuir

¡Las contribuciones son bienvenidas! Siente libre de abrir issues o pull requests si encuentras fallos o tienes ideas para mejoras.

## Licencia

Este script se distribuye bajo la licencia [MIT](LICENSE).

---

Desarrollado con ❤️ para facilitar la visualización de imágenes en entornos Linux.

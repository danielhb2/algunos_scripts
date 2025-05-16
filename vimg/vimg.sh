#!/bin/bash
# Script para visualizar imágenes en TTY/entorno gráfico
# Usa fbi para TTY y feh para entorno gráfico
# Nombre: vimg.sh

#
# --- fzf options ---
fzf_opts=(
    "--border"
    "--cycle"
    "--border-label=Ver imágenes"
    "--border-label-pos=0"
    "--ansi"
    "--color=label:#f2ff00,fg:7,bg:#000088,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:#000000,marker:1,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:#000000"
    "--layout=reverse"
    "--highlight-line"
    "--pointer=▶"
    "--marker=+"
)
# --- end fzf options ---
#

# Variable global para el directorio actual
CURRENT_DIR="$(pwd)"
SHOW_IMAGES_FIRST=false

# Comprobar si estamos en un entorno gráfico o TTY
is_graphical_env() {
    # Verificar si hay un servidor X o Wayland ejecutándose
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        return 0  # Entorno gráfico
    else
        return 1  # TTY
    fi
}

# Comprobar dependencias
check_deps() {
    local viewer
    
    if is_graphical_env; then
        viewer="feh"
    else
        viewer="fbi"
    fi
    
    for cmd in fzf "$viewer" find; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: $cmd no está instalado. Por favor instálalo primero."
            exit 1
        fi
    done
}

# Buscar todas las imágenes en el directorio actual
find_images() {
    find -L "$CURRENT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" \) | sort
}

# Función para ejecutar fbi con opciones seguras y control de tamaño
run_fbi() {
    local fbi_options=()
    local img_width img_height term_cols term_lines

    # Obtener el tamaño de la terminal
    term_cols=$(tput cols)
    term_lines=$(tput lines)

    # Comprobar si -nocompress está soportado
    fbi --help 2>&1 | grep -q '^-nocompress'
    if [ $? -eq 0 ]; then
        fbi_options+=("-nocompress")
    fi

    # Obtener el tamaño de la imagen (esto es complejo y puede no ser 100% fiable en todos los casos)
    #  Aquí asumimos que 'identify' de ImageMagick está instalado.  Si no lo está, esto fallará.
    if command -v identify >/dev/null 2>&1; then
        img_width=$(identify -format "%w" "$1")  # Width of the first image
        img_height=$(identify -format "%h" "$1") # Height of the first image

        #  Si la imagen es mayor que la terminal, NO usar -a (autoscale).
        if [[ "$img_width" -gt "$term_cols" || "$img_height" -gt "$term_lines" ]]; then
            #  Dejamos que fbi maneje el clipping (o el usuario haga scroll en la TTY).
            fbi_options+=()  # No añadir -a/-1
        else
            fbi_options+=("-a") #  O -1, prueba ambos.
        fi
    else
        # Si no está instalado identify, siempre intentamos NO usar autoscale.
        fbi_options+=()
    fi
    
    fbi_options+=("$@")  # Agregar los argumentos de la función
    
    tput smcup
    fbi "${fbi_options[@]}"
    tput rmcup
}

# Mostrar todas las imágenes automáticamente
display_all_images() {
    local images=("$@")
    
    if is_graphical_env; then
        # Usar feh en entorno gráfico
        feh --auto-zoom --scale-down "${images[@]}"
    else
        # Usar fbi en TTY
        run_fbi "${images[@]}"
    fi
}

# Mostrar imágenes comenzando por la seleccionada
display_images_from() {
    local start_image="$1"
    local all_images=("${@:2}")  # Obtener todas las imágenes excepto la primera
    
    if is_graphical_env; then
        # Usar feh en entorno gráfico con navegación
        feh --auto-zoom --scale-down --start-at "$start_image" "${all_images[@]}"
    else
        # Usar fbi en TTY
        run_fbi "$start_image" "${all_images[@]}"
    fi
}

# Mostrar menú de navegación de directorios y selección de imágenes con fzf
show_navigation_menu() {
    local image_files="$1"
    local current_path="$CURRENT_DIR"
    
    # Preparar los elementos para el menú
    declare -a menu_items=()
    
    # Opción para ir al directorio padre
    if [ "$current_path" != "/" ]; then
        menu_items+=("📁 [SUBIR DIRECTORIO] $(dirname "$current_path")")
    fi
    
    # Listar subdirectorios
    while IFS= read -r dir; do
        if [ -n "$dir" ]; then
            menu_items+=("📁 [DIRECTORIO] $dir")
        fi
    done < <(find -L "$current_path" -maxdepth 1 -type d ! -path "$current_path" -printf "%p\n" | sort)
    
    # Agregar imágenes al menú
    while IFS= read -r img; do
        if [ -n "$img" ]; then
            menu_items+=("🖼️ $img")
        fi
    done < <(echo -e "$image_files")
    
    # Crear un archivo temporal para el menú
    local temp_menu_file=$(mktemp)
    printf "%s\n" "${menu_items[@]}" > "$temp_menu_file"
    
    # Mostrar el menú con fzf
    local result=$(fzf "${fzf_opts[@]}" \
        --prompt="Directorio actual: $current_path > " \
        --header="Selecciona una imagen o directorio (Esc para salir)" \
        < "$temp_menu_file")
    
    # Limpiar archivo temporal
    rm -f "$temp_menu_file"
    
    echo "$result"
}

# Función principal
main() {
    check_deps
    
    # Verificar si se pasaron parámetros para el directorio inicial
    if [ "$#" -eq 1 ] && [ -d "$1" ]; then
        CURRENT_DIR="$(realpath "$1")"
        SHOW_IMAGES_FIRST=true
    elif [ "$#" -eq 1 ] && [ -f "$1" ]; then
        # Si se pasó un archivo, establecer el directorio como su padre
        CURRENT_DIR="$(dirname "$(realpath "$1")")"
        INITIAL_FILE="$(realpath "$1")"
    fi
    
    # Bucle principal de navegación
    while true; do
        # Buscar todas las imágenes en el directorio actual
        local image_files=$(find_images)
        local image_array=()
        
        if [ -n "$image_files" ]; then
            # Convertir el listado en un array
            mapfile -t image_array <<< "$image_files"
        fi
        
        # Si hay un archivo inicial especificado, mostrarlo primero
        if [ -n "$INITIAL_FILE" ] && [ -f "$INITIAL_FILE" ]; then
            if [ ${#image_array[@]} -gt 0 ]; then
                display_images_from "$INITIAL_FILE" "${image_array[@]}"
            else
                echo "Error: No se encontraron imágenes en el directorio de '$INITIAL_FILE'"
                exit 1
            fi
            unset INITIAL_FILE  # Limpiar la variable para próximas iteraciones
        elif [ ${#image_array[@]} -gt 0 ] && ([ "$#" -eq 0 ] || [ "$SHOW_IMAGES_FIRST" = true ]); then
            # Sin parámetros o con directorio como parámetro y hay imágenes: Mostrar todas las imágenes directamente
            display_all_images "${image_array[@]}"
            # Restablecer la variable
            SHOW_IMAGES_FIRST=false
            # Establecer a empty para que no entre en este caso en la siguiente iteración
            if [ "$#" -eq 0 ]; then
                set -- "dummy"
            fi
        fi
        
        # Convertir array de imágenes a un string para mostrar en el menú
        local image_list=""
        if [ ${#image_array[@]} -gt 0 ]; then
            printf -v image_list "%s\n" "${image_array[@]}"
            image_list="${image_list%\\n}"  # Quitar el último \n
        fi
        
        # Mostrar menú de navegación
        local selected=$(show_navigation_menu "$image_list")
        
        # Si se presiona Esc o Ctrl+C, salir
        if [ -z "$selected" ]; then
            clear
            exit 0
        fi
        
        # Procesar la selección
        if [[ "$selected" == 📁* ]]; then
            # Si se seleccionó un directorio
            if [[ "$selected" == *"[SUBIR DIRECTORIO]"* ]]; then
                # Ir al directorio padre
                CURRENT_DIR="$(dirname "$CURRENT_DIR")"
            else
                # Ir al subdirectorio seleccionado
                CURRENT_DIR="$(echo "$selected" | sed 's|^📁 \[DIRECTORIO\] ||')"
            fi
        elif [[ "$selected" == 🖼️* ]]; then
            # Si se seleccionó una imagen
            local selected_image="$(echo "$selected" | sed 's|^🖼️ ||')"
            
            # Mostrar imágenes comenzando por la seleccionada
            display_images_from "$selected_image" "${image_array[@]}"
        fi
    done
}

# Ejecutar el script con los parámetros recibidos
main "$@"

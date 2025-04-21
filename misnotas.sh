#!/bin/bash
# Directorio base para las notas
NOTAS_DIR="$HOME/mis_notas"
# Crear el directorio si no existe
mkdir -p "$NOTAS_DIR"

# Función para mostrar contenido usando bat o cat
mostrar_contenido() {
    if command -v bat &> /dev/null; then
        bat --style=plain "$1"
    else
        cat "$1"
    fi
}



# Función para mostrar el menú usando fzf
mostrar_menu() {
    opcion=$(printf "Nueva nota\nNueva nota anexa\nEditar nota\nPrevisualizar notas\nAgregar contenido\nEliminar nota\nBuscar texto en notas\nSalir" | \
    fzf --border=rounded  --preview-window=75%:wrap --prompt="Selecciona una opción > " --info=inline --preview-border=rounded  --preview-label='] CONTENIDO ['  --no-multi --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
    
    case $opcion in
        "Nueva nota") nueva_nota "txt" ;;
        "Nueva nota anexa") nueva_nota "anexo" ;;
        "Editar nota") editar_nota ;;
        "Previsualizar notas") previsualizar_notas ;;
        "Agregar contenido") agregar_contenido ;;
        "Eliminar nota") eliminar_nota ;;
        "Buscar texto en notas") buscar_texto ;;
        "Salir") if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
tput setaf 6 bold;echo +------------------------------------------+
echo                  ":                                          :"
echo                  ":               HASTA PRONTO               :"
echo                  ":                                          :"
echo                   +------------------------------------------+
tput sgr0
else
echo "" ; echo ""
tput setaf 6 bold;echo +------------------------------------------+
echo                  ":                                          :"
echo                  ":               HASTA PRONTO               :"
echo                  ":                                          :"
echo                   +------------------------------------------+
tput sgr0
fi; exit 0 ;;
        *) return ;;
    esac
}

# Función para crear una nueva nota
nueva_nota() {
    tipo=$1
    fecha=$(date +%d-%m-%Y)
    if [ "$tipo" = "anexo" ]; then
        nota_path="$NOTAS_DIR/$(date +%Y)/$fecha.anexo"
    else
        nota_path="$NOTAS_DIR/$(date +%Y)/$fecha.txt"
    fi
    
    mkdir -p "$NOTAS_DIR/$(date +%Y)"
    if [[ -f "$nota_path" ]]; then
        respuesta=$(printf "Sí\nNo" | fzf --border=rounded --prompt="Ya existe una nota ${tipo} para hoy. ¿Deseas agregar contenido? > " --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
        if [[ "$respuesta" == "Sí" ]]; then
            agregar_contenido "$nota_path"
        else
            echo "Operación cancelada."
            sleep 1
        fi
    else
        nano "$nota_path"
    fi
}

# Función para editar una nota existente
editar_nota() {
    nota_path=$(encontrar_nota)
    if [[ -n "$nota_path" ]]; then
        nano "$nota_path"
    else
        echo "No se encontró ninguna nota."
        sleep 1
    fi
}

# Función para previsualizar notas
previsualizar_notas() {
    nota_path=$(encontrar_nota)
    if [[ -n "$nota_path" ]]; then
        clear
        mostrar_contenido "$nota_path"
        echo -e "\nPresiona Enter para volver al menú..."
        read
    else
        echo "No se encontró ninguna nota."
        sleep 1
    fi
}

# Función para agregar contenido a una nota existente
agregar_contenido() {
    nota_path=$1
    if [[ -z "$nota_path" ]]; then
        nota_path=$(encontrar_nota)
    fi
    if [[ -n "$nota_path" ]]; then
        echo "Escribe el contenido que deseas agregar (Ctrl+D para finalizar):"
        cat >> "$nota_path"
    else
        echo "No se encontró ninguna nota."
        sleep 1
    fi
}

# Función para eliminar una nota
eliminar_nota() {
    nota_path=$(encontrar_nota)
    if [[ -n "$nota_path" ]]; then
        confirmacion=$(printf "Sí\nNo" | fzf --border=rounded --prompt="¿Estás seguro de que deseas eliminar esta nota? > " --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
        if [[ "$confirmacion" == "Sí" ]]; then
            rm "$nota_path"
            echo "Nota eliminada correctamente."
            sleep 1
        else
            echo "Operación cancelada."
            sleep 1
        fi
    else
        echo "No se encontró ninguna nota."
        sleep 1
    fi
}

# Función para buscar texto en las notas
buscar_texto() {
    echo -n "Introduce el texto que deseas buscar: "
    read texto
    if [[ -z "$texto" ]]; then
        echo "No se introdujo ningún texto."
        sleep 1
        return
    fi
    
    # Buscar el texto solo en archivos .txt y .anexo
    resultados=$(find "$NOTAS_DIR" -type f \( -name "*.txt" -o -name "*.anexo" \) -exec grep -l -i "$texto" {} \;)
    if [[ -z "$resultados" ]]; then
        echo "No se encontraron notas que contengan el texto '$texto'."
        sleep 1
    else
        echo "Notas que contienen el texto '$texto':"
        nota_path=$(echo "$resultados" | fzf --border=rounded --preview-window=75%:wrap --preview-label='] RESULTADO DE LA BÚSQUEDA [' --preview="grep  '$texto' {}" --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
        if [[ -n "$nota_path" ]]; then
            accion=$(printf "Previsualizar nota\nEditar nota\nVolver al menú principal" | \
                    fzf --border=rounded --prompt="¿Qué deseas hacer con la nota seleccionada? > " --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
            case $accion in
                "Previsualizar nota") 
                    clear
                    mostrar_contenido "$nota_path"
                    echo -e "\nPresiona Enter para volver al menú..."
                    read
                    ;;
                "Editar nota") nano "$nota_path" ;;
                *) return ;;
            esac
        else
            echo "No se seleccionó ninguna nota."
            sleep 1
        fi
    fi
}

# Función para encontrar una nota usando fzf
encontrar_nota() {
    local nota_seleccionada
    if command -v bat &> /dev/null; then
        nota_seleccionada=$(find "$NOTAS_DIR" -type f \( -name "*.txt" -o -name "*.anexo" \) -printf "%P\n" | \
        fzf --preview="bat --style=plain  '$NOTAS_DIR/{}'" \
            --header="Usa / para buscar, Enter para seleccionar" \
            --border=rounded \
            --preview-window="right:75%:wrap" --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
        if [[ -n "$nota_seleccionada" ]]; then
            echo "$NOTAS_DIR/$nota_seleccionada"
        fi
    else
        nota_seleccionada=$(find "$NOTAS_DIR" -type f \( -name "*.txt" -o -name "*.anexo" \) -printf "%P\n" | \
        fzf --preview="cat '$NOTAS_DIR/{}'" \
            --header="Usa / para buscar, Enter para seleccionar" \
            --border=rounded \
            --preview-window="right:75%:wrap" --color=fg:7,bg:4,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:1,marker:5,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:0)
        if [[ -n "$nota_seleccionada" ]]; then
            echo "$NOTAS_DIR/$nota_seleccionada"
        fi
    fi
}

# Bucle principal del menú
while true; do
#    clear
    mostrar_menu
    if [[ $? -ne 0 ]]; then
        continue
    fi
done



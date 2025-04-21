#!/bin/bash

# Mostrar selector de paquetes con descripción y archivos
pacman -Slq | fzf \
  --header="Programa a instalar" \
  --preview-label='] DESCRIPCIÓN - DETALLES [' \
  --preview-window=right:75%:wrap \
  --bind "ctrl-x:preview-page-up,ctrl-z:preview-page-down" \
  --bind "ctrl-space:preview-up,space:preview-down" \
  --pointer=▶ \
  --marker=+ \
  --info=right \
  --border \
  --border-label=' [ PFI (Pacman-FZF-Installer) - <TAB> para selección múltiple ] ' \
  --preview-border=rounded \
  --multi \
  --color=label:#f2ff00,fg:7,bg:#000088,hl:2,fg+:15,bg+:2,hl+:14,info:3,prompt:2,pointer:#000000,marker:1,spinner:6,border:7,header:2:bold,preview-fg:7,preview-bg:#000000 \
  --preview 'pacman -Si {1} 2>/dev/null && echo && pacman -Fl {1} 2>/dev/null | awk "{print \$2}"' \
| xargs -ro sudo pacman -S

# Saludo de salida
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
  echo ; echo   # Línea vacía solo en TTY
fi
tput setaf 6 bold
cat <<EOF
+------------------------------------------+
:                                          :
:               HASTA PRONTO               :
:                                          :
+------------------------------------------+
EOF
tput sgr0

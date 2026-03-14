#!/bin/bash
# Script para iniciar automáticamente todo el sistema de simulación

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🚁 SISTEMA DE SIMULACIÓN DE DRON${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

# Verificar que el contenedor existe
if ! docker ps -a | grep -q drone_container; then
    echo -e "${YELLOW}⚠️ Contenedor drone_container no encontrado. Creándolo...${NC}"
    docker run -itd --name drone_container --restart always --network host drone_ros2_jazzy
fi

# Verificar que el contenedor está corriendo
if ! docker ps | grep -q drone_container; then
    echo -e "${YELLOW}⚠️ Contenedor detenido. Iniciándolo...${NC}"
    docker start drone_container
fi

echo -e "${GREEN}✅ Contenedor Docker listo${NC}"
echo ""

# Función para abrir terminales
open_terminal() {
    local title=$1
    local command=$2
    local color=$3
    
    echo -e "${color}📟 Abriendo terminal: $title${NC}"
    gnome-terminal --tab --title="$title" -- bash -c "echo -e '${color}=== $title ===${NC}'; $command; exec bash" 2>/dev/null || \
    xterm -T "$title" -e "echo -e '${color}=== $title ===${NC}'; $command; exec bash" 2>/dev/null || \
    echo -e "${YELLOW}⚠️ No se pudo abrir terminal gráfica. Usa tmux en su lugar.${NC}"
}

echo -e "${YELLOW}Selecciona modo de ejecución:${NC}"
echo "  1) Terminales separadas (gnome-terminal/xterm)"
echo "  2) Tmux (recomendado para SSH)"
echo "  3) Solo comandos (para ejecutar manualmente)"
read -p "Opción [1-3]: " modo

case $modo in
    1)
        echo -e "${CYAN}Abriendo terminales...${NC}"
        
        # Terminal 1: DDS Agent
        open_terminal "DDS Agent" "cd ~/drone_project/Micro-XRCE-DDS-Agent/build && ./MicroXRCEAgent udp4 -p 8888" "${PURPLE}"
        sleep 2
        
        # Terminal 2: PX4
        open_terminal "PX4" "cd ~/drone_project/px4/PX4-Autopilot && HEADLESS=1 make px4_sitl gz_x500" "${BLUE}"
        sleep 5
        
        # Terminal 3: ROS 2 Control
        open_terminal "ROS 2 Control" "docker exec -it drone_container bash -c 'cd /ros2_ws && source install/setup.bash && echo -e \"${GREEN}✅ ROS 2 listo${NC}\" && exec bash'" "${GREEN}"
        sleep 2
        
        # Terminal 4: Monitor
        open_terminal "Monitor" "docker exec -it drone_container bash -c 'cd /ros2_ws && source install/setup.bash && echo -e \"${CYAN}📊 Monitoreo de posición:${NC}\" && ros2 topic echo /fmu/out/vehicle_local_position_v1 | grep -E \"x:|y:|z:\"'" "${CYAN}"
        ;;
        
    2)
        echo -e "${CYAN}Configurando sesión tmux...${NC}"
        tmux new-session -d -s drone_sim -n "DDS Agent"
        tmux send-keys -t drone_sim:DDS "cd ~/drone_project/Micro-XRCE-DDS-Agent/build && ./MicroXRCEAgent udp4 -p 8888" C-m
        
        tmux new-window -t drone_sim -n "PX4"
        tmux send-keys -t drone_sim:PX4 "cd ~/drone_project/px4/PX4-Autopilot && HEADLESS=1 make px4_sitl gz_x500" C-m
        
        tmux new-window -t drone_sim -n "ROS2"
        tmux send-keys -t drone_sim:ROS2 "docker exec -it drone_container bash -c 'cd /ros2_ws && source install/setup.bash && echo \"✅ ROS 2 listo\" && exec bash'" C-m
        
        tmux new-window -t drone_sim -n "Monitor"
        tmux send-keys -t drone_sim:Monitor "docker exec -it drone_container bash -c 'cd /ros2_ws && source install/setup.bash && ros2 topic echo /fmu/out/vehicle_local_position_v1 | grep -E \"x:|y:|z:\"'" C-m
        
        echo -e "${GREEN}✅ Sesión tmux 'drone_sim' creada${NC}"
        echo -e "${YELLOW}Comandos útiles tmux:${NC}"
        echo "  - Adjuntar: tmux attach -t drone_sim"
        echo "  - Navegar: Ctrl+b n (siguiente) / Ctrl+b p (anterior)"
        echo "  - Salir sin cerrar: Ctrl+b d"
        echo "  - Cerrar todo: tmux kill-session -t drone_sim"
        
        # Adjuntar automáticamente
        read -p "¿Adjuntar ahora? (s/n): " attach
        if [[ "$attach" == "s" ]]; then
            tmux attach -t drone_sim
        fi
        ;;
        
    3)
        echo -e "${CYAN}Comandos para ejecutar manualmente:${NC}"
        echo ""
        echo -e "${PURPLE}Terminal 1 - DDS Agent:${NC}"
        echo "  cd ~/drone_project/Micro-XRCE-DDS-Agent/build && ./MicroXRCEAgent udp4 -p 8888"
        echo ""
        echo -e "${BLUE}Terminal 2 - PX4:${NC}"
        echo "  cd ~/drone_project/px4/PX4-Autopilot && HEADLESS=1 make px4_sitl gz_x500"
        echo ""
        echo -e "${GREEN}Terminal 3 - ROS 2 Control:${NC}"
        echo "  docker exec -it drone_container bash"
        echo "  cd /ros2_ws && source install/setup.bash"
        echo "  ros2 run offboard_pkg offboard_control"
        echo ""
        echo -e "${CYAN}Terminal 4 - Monitor:${NC}"
        echo "  docker exec -it drone_container bash"
        echo "  cd /ros2_ws && source install/setup.bash"
        echo "  ros2 topic echo /fmu/out/vehicle_local_position_v1 | grep -E \"x:|y:|z:\""
        ;;
esac

echo ""
echo -e "${GREEN}✅ Sistema iniciado${NC}"

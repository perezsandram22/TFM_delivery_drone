#!/bin/bash

echo "╔═══════════════════════════════════════════════╗"
echo "║  VERIFICACIÓN DE ENTORNO PARA DRONES         ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Ubuntu
echo "1. Verificando Ubuntu..."
ubuntu_version=$(lsb_release -rs)
if [[ "$ubuntu_version" == "24.04" ]]; then
    echo -e "${GREEN}✓ Ubuntu $ubuntu_version${NC}"
else
    echo -e "${YELLOW}⚠ Ubuntu $ubuntu_version (recomendado 24.04)${NC}"
fi

# 2. ROS 2 Jazzy
echo ""
echo "2. Verificando ROS2 Jazzy..."
if [ -f "/opt/ros/jazzy/setup.bash" ]; then
    source /opt/ros/jazzy/setup.bash
    echo -e "${GREEN}✓ ROS2 Jazzy instalado${NC}"
else
    echo -e "${RED}✗ ROS2 Jazzy no encontrado${NC}"
fi

# 3. Gazebo
echo ""
echo "3. Verificando Gazebo..."
if command -v gz &>/dev/null; then
    echo -e "${GREEN}✓ Gazebo instalado${NC}"
else
    echo -e "${RED}✗ Gazebo no encontrado${NC}"
fi

# 4. Git
echo ""
echo "4. Verificando Git..."
if command -v git &>/dev/null; then
    echo -e "${GREEN}✓ Git instalado${NC}"
else
    echo -e "${RED}✗ Git no encontrado${NC}"
fi

# 5. PX4
echo ""
echo "5. Verificando PX4..."
if [ -d "$HOME/PX4-Autopilot" ]; then
    echo -e "${GREEN}✓ PX4 clonado${NC}"
else
    echo -e "${RED}✗ PX4 no encontrado${NC}"
fi

echo ""
echo "✔ Verificación finalizada"
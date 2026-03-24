# TFM: Sistema de Simulación delivery con drone optimizando las rutas

## Cómo iniciar el sistema
```bash
cd ~/drone_project
./scripts/start_all.sh

# En la ventana ROS2 (tmux ventana 2), dentro del contenedor:
cd /ros2_ws
./src/mission/simple_mission.sh

# Visualización en Foxglove
Conecta a ws://130.61.118.51:9090 con tipo Rosbridge.
Añade paneles Plot y 3D.

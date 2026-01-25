import rclpy
from rclpy.node import Node
from px4_msgs.msg import TrajectorySetpoint, VehicleCommand, OffboardControlMode

import time

class DroneController(Node):
    def __init__(self):
        super().__init__('drone_ai_node')
        # Publicadores PX4 para control
        self.command_pub = self.create_publisher(OffboardControlMode,'/fmu/in/offboard_control_mode', 10)
        self.setpoint_pub = self.create_publisher(TrajectorySetpoint, '/fmu/in/trajectory_setpoint', 10)
        self.command_pub = self.create_publisher(VehicleCommand, '/fmu/in/vehicle_command', 10)
                
        # Temporizador para enviar comandos constantes (10Hz)
            self.timer = self.create_timer(0.1, self.timer_callback)
            self.counter = 0
            self.get_logger().info("Offboard takeoff node started")

    def timer_callback(self):
        # Publicar modo OFFBOARD (SIEMPRE)
        offboard_msg = OffboardControlMode()
        offboard_msg.position = True
        offboard_msg.velocity = False
        offboard_msg.acceleration = False
        offboard_msg.attitude = False
        offboard_msg.body_rate = False
        offboard_msg.timestamp = int(self.get_clock().now().nanoseconds / 1000)
        self.offboard_pub.publish(offboard_msg)

        # Enviar setpoint de posición (despegue)
        setpoint = TrajectorySetpoint()
        setpoint.position = [0.0, 0.0, -2.0]  # Z negativa = subir
        setpoint.yaw = 0.0
        setpoint.timestamp = int(self.get_clock().now().nanoseconds / 1000)
        self.setpoint_pub.publish(setpoint)

        # Después de algunos ciclos → OFFBOARD + ARM
        if self.counter == 10:
            self.set_offboard_mode()
            self.arm()

        self.counter += 1


    def set_offboard_mode(self):
        self.send_vehicle_command(
            VehicleCommand.VEHICLE_CMD_DO_SET_MODE,
            1,
            6
        )
        self.get_logger().info("OFFBOARD mode enabled")


    def arm(self):
        self.send_vehicle_command(
            VehicleCommand.VEHICLE_CMD_COMPONENT_ARM_DISARM,
            1
        )
        self.get_logger().info("Vehicle armed")


    def send_vehicle_command(self, command, param1=0.0, param2=0.0):
        msg = VehicleCommand()
        msg.command = command
        msg.param1 = param1
        msg.param2 = param2
        msg.target_system = 1
        msg.target_component = 1
        msg.source_system = 1
        msg.source_component = 1
        msg.from_external = True
        msg.timestamp = int(self.get_clock().now().nanoseconds / 1000)

        self.command_pub.publish(msg)


def main():
    rclpy.init()
    node = OffboardTakeoff()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
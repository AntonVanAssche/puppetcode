#!/usr/bin/env python

import os
import socket
import time
from pathlib import Path

import psutil
import requests
import RPi.GPIO as GPIO


class SensorError(Exception):
    """Base exception for sensor errors."""

    pass


class CPUAccessError(SensorError):
    """Exception for CPU temperature read errors."""

    pass


class NetworkError(SensorError):
    """Exception for network-related errors."""

    pass


class DiskError(SensorError):
    """Exception for disk-related errors."""

    pass


class Sensors:
    def __init__(self, conf):
        self.conf = conf
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(17, GPIO.OUT)
        GPIO.output(17, GPIO.HIGH)

    def get_cpu_temp(self):
        try:
            with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
                temp_c = int(f.read()) / 1000.0
        except (OSError, ValueError) as e:
            raise CPUAccessError(f"Failed to read CPU temperature: {e}") from e

        if self.conf["oled"].get("f-temp", False):
            temp_f = temp_c * 1.8 + 32
            return temp_f

        return temp_c

    def get_uptime(self):
        try:
            uptime_seconds = time.time() - psutil.boot_time()
            # Format as "X days, HH:MM:SS"
            days = int(uptime_seconds // 86400)
            remainder = int(uptime_seconds % 86400)
            time_str = time.strftime("%H:%M:%S", time.gmtime(remainder))
            return {"days": days, "time": time_str}
        except Exception as e:
            raise SensorError(f"Failed to get uptime: {e}") from e

    def get_ip_address(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.settimeout(2)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except OSError as e:
            raise NetworkError(f"Failed to determine IP address: {e}") from e

    def get_wan_ip_address(self):
        try:
            response = requests.get("https://api.ipify.org?format=json")
            response.raise_for_status()
            return response.json().get("ip", "WAN IP not found")
        except requests.RequestException as e:
            raise NetworkError(f"Failed to get WAN IP address: {e}") from e

    def get_net_up(self, interval=1.0):
        try:
            net_io_1 = psutil.net_io_counters()
            time.sleep(interval)
            net_io_2 = psutil.net_io_counters()

            bytes_sent = net_io_2.bytes_sent - net_io_1.bytes_sent
            upload_mbps = (bytes_sent * 8) / (1024 * 1024) / interval

            return upload_mbps
        except (AttributeError, OSError) as e:
            raise SensorError(f"Failed to get upload speed: {e}") from e

    def get_net_down(self, interval=1.0):
        try:
            net_io_1 = psutil.net_io_counters()
            time.sleep(interval)
            net_io_2 = psutil.net_io_counters()

            bytes_recv = net_io_2.bytes_recv - net_io_1.bytes_recv
            download_mbps = (bytes_recv * 8) / (1024 * 1024) / interval

            return download_mbps
        except (AttributeError, OSError) as e:
            raise SensorError(f"Failed to get download speed: {e}") from e

    def get_cpu_load(self):
        try:
            load = psutil.getloadavg()[0]  # 1-minute load average
            return load
        except (AttributeError, OSError) as e:
            raise SensorError(f"Failed to get CPU load: {e}") from e

    def get_memory(self):
        try:
            mem = psutil.virtual_memory()
            used_mb = mem.used // (1024 * 1024)
            total_mb = mem.total // (1024 * 1024)
            return {"used": used_mb, "total": total_mb}
        except (AttributeError, OSError) as e:
            raise SensorError(f"Failed to get memory info: {e}") from e

    def get_disk_usage(self):
        try:
            root = psutil.disk_usage("/")
            used_gb = root.used // (1024**3)
            total_gb = root.total // (1024**3)
            percent = root.percent
            return {"used": used_gb, "total": total_gb, "percent": percent}
        except (AttributeError, OSError) as e:
            raise DiskError(f"Failed to get disk usage: {e}") from e

    def get_blk_devices(self):
        try:
            devices = [d for d in os.listdir("/sys/block") if d.startswith("sd")]
            return devices
        except OSError as e:
            raise DiskError(f"Failed to list block devices: {e}") from e

    def disk_turn_on(self):
        try:
            GPIO.setup(26, GPIO.OUT)
            GPIO.output(26, GPIO.HIGH)
            time.sleep(0.5)
            GPIO.setup(25, GPIO.OUT)
            GPIO.output(25, GPIO.HIGH)
            time.sleep(0.5)
        except RuntimeError as e:
            raise SensorError(f"Failed to turn on disk GPIO pins: {e}") from e

    def disk_turn_off(self):
        try:
            GPIO.output(26, GPIO.LOW)
            time.sleep(0.5)
            GPIO.output(25, GPIO.LOW)
            time.sleep(0.5)
        except RuntimeError as e:
            raise SensorError(f"Failed to turn off disk GPIO pins: {e}") from e

    def get_partition_usage(self, Path: "/"):
        try:
            partition = psutil.disk_partitions(all=False)
            for part in partition:
                if part.mountpoint == Path:
                    usage = psutil.disk_usage(part.mountpoint)
                    used_gb = usage.used // (1024**3)
                    total_gb = usage.total // (1024**3)
                    percent = usage.percent
                    return {"mountpoint": part.mountpoint, "used": used_gb, "total": total_gb, "percent": percent}
        except (AttributeError, OSError) as e:
            raise DiskError(f"Partition {Path} not found") from e

    def get_all(self):
        # Returns dict of all sensor info; errors will raise
        return {
            "cpu_temp": self.get_cpu_temp(),
            "uptime": self.get_uptime(),
            "ip": self.get_ip_address(),
            "wan_ip": self.get_wan_ip_address(),
            "upload_speed": self.get_net_up(),
            "download_speed": self.get_net_down(),
            "cpu_load": self.get_cpu_load(),
            "memory": self.get_memory(),
            "disk": self.get_disk_usage(),
            "blk_devices": self.get_blk_devices(),
            "disk_usage": self.get_partition_usage("/"),
        }


if __name__ == "__main__":
    from collections import defaultdict

    conf = defaultdict(dict)
    conf["oled"]["f-temp"] = False  # Toggle for Fahrenheit

    sensors = Sensors(conf)
    try:
        info = sensors.get_all()
        for k, v in info.items():
            print(f"{k}: {v}")
    except SensorError as e:
        print(f"Sensor error: {e}")

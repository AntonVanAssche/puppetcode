#!/usr/bin/env python

from configparser import ConfigParser, NoOptionError, NoSectionError
from pathlib import Path
from typing import Any


class ConfigError(Exception):
    pass


class Config:
    def __init__(
        self, config_file: Path = Path("/home/anton/Projects/Personal/puppetcode/bin/rockpi-sata/etc/rockpi-sata.conf")
    ):
        self._config_file = config_file.expanduser().resolve()
        self._parser = ConfigParser()

        if not self._config_file.exists():
            raise ConfigError(f"Configuration file not found at: {self._config_file}")

        try:
            self._parser.read(self._config_file)
        except Exception as e:
            raise ConfigError(f"Failed to parse config: {e}") from e

    def get(self, section: str, key: str, fallback: Any = None, cast: type = str) -> Any:
        try:
            if cast == bool:
                value = self._parser.getboolean(section, key, fallback=None)
            elif cast == int:
                value = self._parser.getint(section, key, fallback=None)
            elif cast == float:
                value = self._parser.getfloat(section, key, fallback=None)
            else:
                value = self._parser.get(section, key, fallback=None)

            if value is None:
                return fallback

            return value
        except (NoOptionError, NoSectionError, ValueError):
            if fallback is not None:
                return fallback
            raise ConfigError(f"Missing or invalid config: [{section}] {key}")

    def set(self, section: str, key: str, value: Any):
        if not self._parser.has_section(section):
            self._parser.add_section(section)
        self._parser.set(section, key, str(value))
        with self._config_file.open("w", encoding="utf-8") as f:
            self._parser.write(f)

    @property
    def fan_thresholds(self) -> dict[int, int]:
        return {
            self.get("fan", "threshold1", 25, float): 0,
            self.get("fan", "threshold2", 40, float): 50,
            self.get("fan", "threshold3", 50, float): 75,
            self.get("fan", "threshold4", 60, float): 100,
        }

    @property
    def key_bindings(self) -> dict[str, str]:
        return {
            "click": self.get("key", "click", "slider"),
            "twice": self.get("key", "twice", "switch"),
            "press": self.get("key", "press", "none"),
        }

    @property
    def key_timing(self) -> dict[str, float]:
        return {"twice": self.get("time", "twice", 0.7, float), "press": self.get("time", "press", 1.8, float)}

    @property
    def slider_enabled(self) -> bool:
        return self.get("slider", "enable", True, bool)

    @property
    def slider_interval(self) -> float:
        return self.get("slider", "time", 10.0, float)

    @property
    def oled_rotate(self) -> bool:
        return self.get("oled", "rotate", False, bool)

    @property
    def show_temp_fahrenheit(self) -> bool:
        return self.get("oled", "f-temp", False, bool)

    @property
    def config_file(self) -> Path:
        return self._config_file


config = Config()

if config.slider_enabled:
    print(f"Slider will change every {config.slider_interval}s")

print(f"Fan thresholds: {config.fan_thresholds}")
print(f"Key bindings: {config.key_bindings}")
print(f"Key timing: {config.key_timing}")
print(f"Slider enabled: {config.slider_enabled}")
print(f"Slider interval: {config.slider_interval}s")
print(f"OLED rotate: {config.oled_rotate}")
print(f"Show temperature in Fahrenheit: {config.show_temp_fahrenheit}")
print(f"Configuration file path: {config.config_file}")

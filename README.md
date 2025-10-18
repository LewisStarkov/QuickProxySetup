# 🧱 Dante SOCKS5 Proxy Installer

Quick script to install and configure **Dante SOCKS5 proxy with authentication**.  
Works on **Ubuntu / Debian (20.04+)**.

---

## 🇬🇧 English

### ⚙️ Install
```bash
curl -sSL https://raw.githubusercontent.com/<your_username>/<your_repo>/main/setup.sh | sudo bash

Then enter:
	•	Username
	•	Password
	•	Port (default: 1080)

⸻

🧪 Test

curl -x socks5://USER:PASS@SERVER_IP:PORT -4 https://ip.hetzner.com

Logs: /var/log/socks.log
Manage: sudo systemctl restart danted

⸻

🇷🇺 Русский

⚙️ Установка

curl -sSL https://raw.githubusercontent.com/<your_username>/<your_repo>/main/setup.sh | sudo bash

Далее введи:
	•	Логин
	•	Пароль
	•	Порт (по умолчанию 1080)

⸻

🧪 Проверка

curl -x socks5://USER:PASS@SERVER_IP:PORT -4 https://ip.hetzner.com

Логи: /var/log/socks.log
Перезапуск: sudo systemctl restart danted

⸻

Supported OS: Ubuntu / Debian 20.04+

#!/bin/sh

# Check if run as root (exit if so)
[ "$(id -u)" -eq 0 ] && echo "Run as a regular user, not root." && exit 1

# Check for sudo and passwordless access (exit if not)
command -v sudo >/dev/null 2>&1 || echo "sudo is required." && exit 1
sudo apt update >/dev/null 2>&1 || {
  echo "No passwordless sudo access. Configure sudo or use root password (not recommended)."
  read -s -p "Root password (use with caution): " root_password
  echo ""
  expect -c "spawn sudo apt update; expect \"Password:\"; send \"$root_password\\r\"; interact" >/dev/null 2>&1
  [ $? -ne 0 ] && echo "Incorrect password or sudo issue." && exit 1
  export SUDO_ASKPASS=1
  export SUDO_PASSWORD="$root_password"
}

# Install xvfb (if not installed)
dpkg -s xvfb >/dev/null 2>&1 || sudo apt install -y xvfb

# Start Xvfb (background)
Xvfb :99 & export DISPLAY=:99

# Add Xvfb/DISPLAY to .profile (if not already there)
grep -q "Xvfb :99 &" ~/.profile || echo "Xvfb :99 &" >> ~/.profile
grep -q "export DISPLAY=:99" ~/.profile || echo "export DISPLAY=:99" >> ~/.profile
source ~/.profile

# Open firewall ports (if not open)
sudo firewall-cmd --list-ports | grep -q "8081/tcp" && sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --list-ports | grep -q "8082/tcp" && sudo firewall-cmd --permanent --add-port=8082/tcp
sudo firewall-cmd --reload

# Disable webproxy (suppress errors)
sudo systemctl disable webproxy 2>/dev/null

# Install Hamclock (if not installed)
command -v hamclock >/dev/null 2>&1 || {
  cd || exit 1 # Change directory, exit if fails
  [ -f install-hc-rpi ] || curl -O https://www.clearskyinstitute.com/ham/HamClock/install-hc-rpi
  chmod +x install-hc-rpi
  ./install-hc-rpi
}

# Run Hamclock (background)
hamclock &

# Get IP address (multiple methods, fallback)
ip_address=$(ip a | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)
[ -z "$ip_address" ] && ip_address=$(hostname -I | awk '{print $1}')
[ -z "$ip_address" ] && ip_address=$(ifconfig wlan0 | grep "inet addr" | awk '{print $2}' | cut -d: -f2)
[ -z "$ip_address" ] && ip_address=$(ifconfig eth0 | grep "inet addr" | awk '{print $2}' | cut -d: -f2)

# Handle missing IP
[ -z "$ip_address" ] && echo "Could not determine IP." && exit 1

# Print instructions with IP
echo "Hamclock running. Access via:"
echo "http://$ip_address:8081/live.html (read/write)"
echo "http://$ip_address:8082/live.html (read-only)"
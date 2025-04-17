#!/bin/sh

# Check if run as root (exit if so)
[ "$(id -u)" -eq 0 ] && echo "Run as a regular user, not root." && exit 1

# Check for sudo
command -v sudo >/dev/null 2>&1 || {
  echo "sudo is required."
  exit 1
}

# Check and install expect if needed for passworded sudo
command -v expect >/dev/null 2>&1 || {
  echo "expect is required for passworded sudo. Attempting to install..."
  sudo apt update
  sudo apt install -y expect
  if [ $? -ne 0 ]; then
    echo "Failed to install expect. Please install it manually or ensure passwordless sudo."
    exit 1
  fi
}

# Check for passwordless sudo
sudo apt update >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "No passwordless sudo access. Attempting with password via expect."
  read -s -p "Sudo password: " root_password
  echo ""
  expect -c "
    spawn sudo apt update
    expect \"Password:\"
    send \"$root_password\\r\"
    interact
  " >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Incorrect password or sudo issue."
    exit 1
  fi
  export SUDO_ASKPASS=1
  export SUDO_PASSWORD="$root_password"
fi

# Install xvfb (if not installed)
dpkg -s xvfb >/dev/null 2>&1 || {
  echo "Installing xvfb..."
  sudo apt install -y xvfb
  if [ $? -ne 0 ]; then
    echo "Failed to install xvfb."
    exit 1
  fi
}

# Start Xvfb (background)
Xvfb :99 &
export DISPLAY=:99

# Add Xvfb/DISPLAY to .profile (if not already there)
grep -q "Xvfb :99 &" ~/.profile || echo "Xvfb :99 &" >> ~/.profile
grep -q "export DISPLAY=:99" ~/.profile || echo "export DISPLAY=:99" >> ~/.profile

# Open firewall ports
if command -v ufw >/dev/null 2>&1; then
  echo "Using ufw to open ports."
  sudo ufw allow 8081/tcp
  sudo ufw allow 8082/tcp
elif command -v firewall-cmd >/dev/null 2>&1; then
  echo "Using firewalld to open ports."
  sudo firewall-cmd --permanent --add-port=8081/tcp
  sudo firewall-cmd --permanent --add-port=8082/tcp
  sudo firewall-cmd --reload
else
  echo "No known firewall management tool found (ufw or firewalld). Please open ports 8081 and 8082 manually."
fi

# Disable webproxy (suppress errors)
sudo systemctl disable webproxy 2>/dev/null

# Install Hamclock (if not installed)
command -v hamclock >/dev/null 2>&1 || {
  echo "Installing Hamclock..."
  cd || exit 1 # Change directory, exit if fails
  if [ ! -f install-hc-rpi ]; then
    curl -O https://www.clearskyinstitute.com/ham/HamClock/install-hc-rpi
    if [ $? -ne 0 ]; then
      echo "Failed to download install-hc-rpi."
      exit 1
    fi
  fi
  chmod +x install-hc-rpi
  ./install-hc-rpi
  if [ $? -ne 0 ]; then
    echo "Hamclock installation failed."
    exit 1
  fi
}

# Run Hamclock (background)
echo "Starting Hamclock..."
hamclock &

# Get IP address (more robust)
ip_address=$(ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)
if [ -z "$ip_address" ]; then
  ip_address=$(hostname -I | awk '{print $1}')
fi
if [ -z "$ip_address" ]; then
  # Fallback to older methods (less reliable)
  ip_address=$(ifconfig wlan0 2>/dev/null | grep "inet addr" | awk '{print $2}' | cut -d: -f2)
fi
if [ -z "$ip_address" ]; then
  ip_address=$(ifconfig eth0 2>/dev/null | grep "inet addr" | awk '{print $2}' | cut -d: -f2)
fi

# Handle missing IP
if [ -z "$ip_address" ]; then
  echo "Could not determine IP address. Please check your network configuration."
  exit 1
fi

# Print instructions with IP
echo "Hamclock running. Access via:"
echo "http://$ip_address:8081/live.html (read/write)"
echo "http://$ip_address:8082/live.html (read-only)"

exit 0

# install_hamclock

This script installs **HamClock** on a Debian-based system.

## 📋 Requirements

- A Debian-based Linux distribution
- Internet access
- The script must be run as a **regular user** (not root)
- `sudo` access (you’ll be prompted for your password)

## 🛠 Installation Steps

1. **Open a terminal** and go to your home directory:
   ```bash
   cd ~
   ```

2. **Download the installation script**:
   ```bash
   wget https://raw.githubusercontent.com/hardenedpenguin/install_hamclock/refs/heads/main/install_hamclock.sh
   ```

3. **Make the script executable**:
   ```bash
   chmod +x install_hamclock.sh
   ```

4. **Run the script**:
   ```bash
   ./install_hamclock.sh
   ```

## 🧾 Notes

- The script will install all necessary dependencies and clone the HamClock source.
- It will compile and install HamClock in your system.
- You may be prompted for your password during the process if `sudo` is needed.

## 🛰️ About HamClock

HamClock is a desktop companion for amateur radio operators. It displays useful information like propagation data, UTC clock, solar data, satellite tracking, and more.

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

## 🔄 Reverse Proxy Setup (Apache2)

To access HamClock through Apache2 as a reverse proxy, follow these steps:

### 1. Enable Required Apache Modules

```bash
sudo a2enmod proxy proxy_wstunnel proxy_http
sudo systemctl restart apache2
```

### 2. Create Virtual Host Configuration

Create a new configuration file `/etc/apache2/sites-available/hamclock.conf`:

```apache
<VirtualHost *:80>
    ServerName localhost
    
    ProxyPass /hamclock/live.html http://127.0.0.1:8081/live.html
    ProxyPass /hamclock/favicon.ico http://127.0.0.1:8081/favicon.ico
    ProxyPass /hamclock/live-ws ws://127.0.0.1:8081/live-ws
</VirtualHost>
```

### 3. Enable the Site and Restart Apache

```bash
sudo a2ensite hamclock.conf
sudo systemctl reload apache2
```

### 4. Access HamClock

After configuration, you can access HamClock at:
- `http://localhost/hamclock/live.html`

**Note:** Make sure HamClock is running on port 8081 before accessing through the reverse proxy.

## 🛰️ About HamClock

HamClock is a desktop companion for amateur radio operators. It displays useful information like propagation data, UTC clock, solar data, satellite tracking, and more.

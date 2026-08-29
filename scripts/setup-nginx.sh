#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="/usr/share/nginx/html"

install_nginx() {
  if command -v nginx >/dev/null 2>&1; then
    echo "nginx is already installed"
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y nginx
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y nginx
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y nginx
    WEB_ROOT="/var/www/html"
  else
    echo "Unsupported OS: could not find dnf, yum, or apt-get"
    exit 1
  fi
}

install_nginx

sudo mkdir -p "$WEB_ROOT"
sudo cp /tmp/index.html "$WEB_ROOT/index.html"
sudo chmod 644 "$WEB_ROOT/index.html"

if id nginx >/dev/null 2>&1; then
  sudo chown -R nginx:nginx "$WEB_ROOT"
elif id www-data >/dev/null 2>&1; then
  sudo chown -R www-data:www-data "$WEB_ROOT"
fi

sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager

echo "Deployment complete. Site is live at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || hostname -I | awk '{print $1}')"

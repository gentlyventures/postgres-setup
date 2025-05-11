#!/usr/bin/env bash
set -e

# 1. Install Docker (if not already present)
if ! command -v docker &> /dev/null; then
  echo "Docker not found: installing Docker CE..."
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  echo "Adding $USER to docker group (you may need to log out/in)..."
  sudo usermod -aG docker "$USER"
else
  echo "Docker already installed"
fi

# 2. Clone or update this repo
REPO_URL="https://github.com/<your-username>/postgres-setup.git"
if [ ! -d postgres-setup ]; then
  echo "Cloning postgres-setup..."
  git clone "$REPO_URL"
fi
cd postgres-setup

# 3. Copy example env if needed
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Copied .env.example → .env (edit .env if you wish)"
fi

# 4. Launch Postgres
echo "Starting PostgreSQL container..."
docker compose up -d

echo "✅ Done. Postgres is running on localhost:5432"

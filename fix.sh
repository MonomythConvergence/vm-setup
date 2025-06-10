#!/bin/bash
set -e

echo "=== DOCKER COMPOSE IN SHARED FOLDER SOLUTION ==="

# 1. Configure shared folder permissions
echo "1. Fixing shared folder permissions..."
sudo mkdir -p /media/sf_api
sudo chown -R $USER:vboxsf /media/sf_api
sudo chmod -R 775 /media/sf_api
find /media/sf_api -type d -exec sudo chmod g+s {} \;

# 2. Configure Docker for shared folder
echo "2. Configuring Docker..."
docker run --rm -v /media/sf_api:/target alpine \
    sh -c "chown -R $USER:$USER /target"

# 3. Create docker-compose override for permission fix
echo "3. Creating permission fix compose file..."
cat <<EOF > /media/sf_api/docker-compose.override.yml
version: '3.8'
services:
  app:
    user: "$(id -u):$(id -g)"
    volumes:
      - ./:/app
EOF

# 4. Run docker-compose with guaranteed permissions
echo "4. Running docker-compose up --build..."
cd /media/sf_api
docker-compose -f docker-compose.yml -f docker-compose.override.yml up --build

echo "=== COMPLETED SUCCESSFULLY ==="

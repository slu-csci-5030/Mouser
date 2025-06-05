#!/bin/bash
set -e

# 1. Clonning the repos
[ -d "rerum_server_nodejs" ] || git clone https://github.com/CenterForDigitalHumanities/rerum_server_nodejs.git
[ -d "TinyNode" ] || git clone https://github.com/CenterForDigitalHumanities/TinyNode.git

# 2. Create .env if not available
if [ ! -f "rerum_server_nodejs/.env" ]; then
    cat > rerum_server_nodejs/.env <<EOF
RERUM_BASE=localhost
RERUM_PREFIX=localhost/v1/
RERUM_API_VERSION=1.0.0
RERUM_ID_PREFIX=localhost/v1/id/
RERUM_AGENT_CLAIM=localhost/agent
RERUM_CONTEXT=localhost/v1/context.json
RERUM_API_DOC=localhost/v1/API.html
MONGO_CONNECTION_STRING=mongodb://mongodb:27017/rerum
MONGODBNAME=rerum
DOWN=false
ISSUER=http://localhost:3000/
JWT_SECRET=dev-only-secret
READONLY=false
PORT=3001
EOF
    echo ".env created for RERUM API"
fi

# 3. Create docker-compose.yml if not available
if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yml" ]; then
    cat > docker-compose.yml <<EOF
services:
  mongodb:
    image: mongo:6.0
    container_name: rerum-mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

  rerum-api:
    build:
      context: ./rerum_server_nodejs
    container_name: rerumapi
    ports:
      - "3001:3001"
    depends_on:
      - mongodb
      - tiny-node
    environment:
      - TINYNODE_URL=http://tinynode:3002
    env_file:
      - ./rerum_server_nodejs/.env

  tiny-node:
    build:
      context: ./TinyNode
    container_name: tinynode
    ports:
      - "3002:3002"
    depends_on:
      - mongodb
    environment:
      - MONGO_URI=mongodb://mongodb:27017/tinynode

  mongo-express:
    image: mongo-express
    container_name: mongo-express
    ports:
      - "8081:8081"
    environment:
      - ME_CONFIG_MONGODB_SERVER=mongodb
      - ME_CONFIG_BASICAUTH_USERNAME=
      - ME_CONFIG_BASICAUTH_PASSWORD=
    depends_on:
      - mongodb

volumes:
  mongo-data:
EOF
    echo "docker-compose.yml created."
fi

# 4. Build and run the project
docker compose up --build

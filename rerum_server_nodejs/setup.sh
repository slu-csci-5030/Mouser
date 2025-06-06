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
MONGO_CONNECTION_STRING=mongodb://root:example@mongo:27017/rerum?authSource=admin
MONGODBNAME=rerum
MONGODBCOLLECTION=alpha
DOWN=false
ISSUER=http://localhost:3000/
JWT_SECRET=dev-only-secret
READONLY=false
AUDIENCE=local-dev
PORT=3001
EOF
    echo ".env created for RERUM API"
fi

# 3. Create docker-compose.yml if not available
if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yml" ]; then
    cat > docker-compose.yml <<EOF
services:
  rerum:
    build: ./rerum_server_nodejs
    ports: 
      - "3001:3001"
    depends_on:
      - localauth0
      - mongo

  mongo:
    image: mongo
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example

  mongo-express:
    image: mongo-express
    restart: always
    ports:
      - 8081:8081
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
      ME_CONFIG_MONGODB_URL: mongodb://root:example@mongo:27017/
      ME_CONFIG_BASICAUTH: false

  localauth0:
    image: public.ecr.aws/primaassicurazioni/localauth0:0.8.2
    healthcheck:
      test: ["CMD", "/localauth0", "healthcheck"]
    ports:
      - "3002:3002"
    environment:
      - AUTH0_DOMAIN=local_rerum.auth0.com 
      - AUTH0_CLIENT_ID=rerum      
      - AUTH0_CLIENT_SECRET=rerum 
      - AUTH0_CALLBACK_URL=http://localhost:3001/callback 
    restart: "no"
EOF
    echo "docker-compose.yml created."
fi

# 4. Build and run the project
docker compose up --build

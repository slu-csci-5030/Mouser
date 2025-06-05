FROM node:lts-alpine3.22

WORKDIR /app/

COPY . .

RUN npm install

EXPOSE 3001:3001

CMD ["npm", "start"]
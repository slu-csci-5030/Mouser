FROM node:lts-alpine3.22

WORKDIR /app/

COPY . .

RUN npm install

EXPOSE 3002:3002

CMD ["npm", "start"]
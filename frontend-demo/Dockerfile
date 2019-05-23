FROM node:12-alpine

COPY ./frontend-demo/package.json /app/package.json
COPY ./frontend-demo/package-lock.json /app/package-lock.json
WORKDIR /app
RUN npm ci

COPY ./frontend-demo/ /app/

EXPOSE 3000
EXPOSE 3001

CMD ["npm", "start"]
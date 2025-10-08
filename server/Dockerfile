FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . ./
RUN npm run build

EXPOSE 2567
ENV NODE_ENV=production
CMD ["node", "build/index.js"]

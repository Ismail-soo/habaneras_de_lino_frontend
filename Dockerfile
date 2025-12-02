FROM node:18-alpine as dependencies

WORKDIR /usr/app

COPY package.json package-lock.json ./

RUN npm install

FROM node:18-alpine as builder_step

WORKDIR /usr/app

RUN apk add --no-cache tzdata
ENV TZ=America/New_York

COPY . .

COPY --from=dependencies /usr/app/node_modules ./node_modules

RUN npm run build

FROM node:18-alpine

WORKDIR /usr/app

RUN apk add --no-cache tzdata vim
ENV TZ=America/New_York
ENV NODE_ENV=production

COPY --from=builder_step /usr/app/package.json ./package.json
COPY --from=builder_step /usr/app/node_modules ./node_modules
COPY --from=builder_step /usr/app/.next ./.next
COPY --from=builder_step /usr/app/public ./public

EXPOSE 8080

CMD ["npx", "next", "start"]
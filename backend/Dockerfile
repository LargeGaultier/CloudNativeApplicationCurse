FROM node:20-alpine3.18 AS build

WORKDIR /app

RUN apk add --no-cache openssl1.1-compat

COPY package*.json ./
RUN npm ci

COPY . .
RUN npx prisma generate --schema=src/prisma/schema.prisma
RUN npm prune --omit=dev

FROM node:20-alpine3.18

WORKDIR /app

RUN apk add --no-cache openssl1.1-compat postgresql-client

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/package*.json ./
COPY --from=build /app/src/prisma ./src/prisma
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]

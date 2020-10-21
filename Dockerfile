ARG NODE_VERSION=14.10.0

###
# STAGE 1: Base
###
FROM node:$NODE_VERSION-buster-slim as base

ENV NODE_PATH=/app
WORKDIR $NODE_PATH

###
# STAGE 2: Build
###
FROM base as build

# https://medium.com/@szpytfire/create-react-app-refused-to-execute-inline-script-ea0301dea192
ENV INLINE_RUNTIME_CHUNK=false

WORKDIR $NODE_PATH

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

RUN npm run build

###
# STAGE 3: Production
###
FROM node:$NODE_VERSION-buster-slim

ENV NODE_PATH=/app
ENV PORT=3000
ENV NODE_ENV="production"

WORKDIR $NODE_PATH
COPY --from=build $NODE_PATH/build ./build
COPY --from=build $NODE_PATH/node_modules ./node_modules
COPY --from=build $NODE_PATH/server ./server
COPY --from=build $NODE_PATH/package.json .
COPY --from=build $NODE_PATH/package-lock.json .

RUN npm prune --production

EXPOSE $PORT
CMD ["node", "server"]

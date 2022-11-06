FROM debian:bullseye as builder

ARG NODE_VERSION=16.13.2
ARG YARN_VERSION=1.22.17

RUN apt-get update; apt install -y curl
RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME /root/.volta
ENV PATH /root/.volta/bin:$PATH
RUN volta install node@${NODE_VERSION} yarn@${YARN_VERSION}

#######################################################################

EXPOSE 80

#######################################################################

RUN mkdir /app
WORKDIR /app

ENV NODE_ENV production

COPY . .

RUN yarn install && yarn run build
FROM debian:bullseye

LABEL fly_launch_runtime="nodejs"

COPY --from=builder /root/.volta /root/.volta
COPY --from=builder /app /app

WORKDIR /app
ENV NODE_ENV production
ENV PATH /root/.volta/bin:$PATH

CMD [ "yarn", "run", "start" ]

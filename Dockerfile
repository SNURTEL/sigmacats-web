FROM debian:bookworm-slim AS build-env

RUN apt-get update
RUN apt-get install -y curl git unzip

WORKDIR /app/

ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.16.2
ARG APP=/code

RUN git clone --depth=1 --branch $FLUTTER_VERSION https://github.com/flutter/flutter.git $FLUTTER_SDK
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v

RUN mkdir $APP
COPY app $APP
WORKDIR $APP
RUN flutter clean
RUN flutter pub get
COPY /app/.env.sample $APP/.env
RUN flutter build web

COPY nginx.conf $APP/nginx.conf


FROM nginx:1.25.2-alpine

RUN rm /etc/nginx/nginx.conf
COPY --from=build-env /code/nginx.conf /etc/nginx/nginx.conf
COPY --from=build-env /code/build/web /usr/share/nginx/html
COPY --from=build-env /code/.env /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["nginx-debug", "-g", "daemon off;"]

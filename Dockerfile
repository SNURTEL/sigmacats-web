# Environemnt to install flutter and build web
FROM debian:bookworm-slim AS build-env

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git unzip

WORKDIR /app/


# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.16.2
ARG APP=/code

#clone flutter
RUN git clone --depth=1 --branch $FLUTTER_VERSION https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# doctor to see if all was installes ok
RUN flutter doctor -v

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY app $APP
COPY nginx.conf $APP/nginx.conf
# stup new folder as the working directory
WORKDIR $APP
# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter clean
RUN flutter pub get
RUN flutter build web

COPY /app/.env.sample $APP/.env


# use nginx to deploy
FROM nginx:1.25.2-alpine

# copy the info of the builded web app to nginx
RUN rm /etc/nginx/nginx.conf
COPY --from=build-env /code/nginx.conf /etc/nginx/nginx.conf
COPY --from=build-env /code/build/web /usr/share/nginx/html
COPY --from=build-env /code/.env /usr/share/nginx/html

# Expose and run nginx
EXPOSE 80
ENTRYPOINT ["nginx-debug", "-g", "daemon off;"]

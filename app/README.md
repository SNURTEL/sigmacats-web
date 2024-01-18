## Quickstart guide

### Prerequisites

- You will need Dart & Flutter to run the app. Check the installation guide [here](https://docs.flutter.dev/get-started/install.) Dart SDK should be installed along with Flutter SDK.
- If you are using Android Studio, you may need to manually setup SDK paths. Find the Flutter SDK install path by `flutter doctor -v` and set it as **both** Dart and Flutter SDK path in IDE settings.
- Before running the app, you will need to copy `.env.sample` to `.env`. You may want to configure backend URL and upload port in the envfile.

### Run the app using Chrome debug server

```shell
flutter run -d chrome 
```

You can use `--web-port=<PORT>` to specify debug server port.


### Make a release build

```shell
flutter build web
```

build results will be written to `app/build/web`.

### Run in container

```shell
docker build -t sigma-web .
docker run sigma-web
```

Nginx will be used as a web server.
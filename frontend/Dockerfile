# Build context is the repository root (see docker-compose.build.yml).
#
# The Flutter app is built for the web and served by nginx, which also forwards /api/ to the API
# container - so the browser talks to one address and needs no CORS or public-host setting.

# --- Flutter SDK, pinned to the version the app is developed with ------------------------------
# (installed from the Flutter repository at that tag rather than taken from a prebuilt image, which
# lag behind and would not satisfy the app's Dart SDK requirement)
FROM debian:12-slim AS build
ARG FLUTTER_VERSION=3.47.5
RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"
# Running as root inside a build container: tell Flutter that is fine.
ENV FLUTTER_ALLOW_ROOT=true
RUN git config --global --add safe.directory /flutter \
    && flutter config --no-analytics --enable-web \
    && flutter precache --web

# --- the app ------------------------------------------------------------------------------------
WORKDIR /app
COPY frontend/idmanager_app/pubspec.yaml frontend/idmanager_app/pubspec.lock ./
RUN flutter pub get
COPY frontend/idmanager_app/ ./
# Where the app finds the API: a path on the same address it is served from (nginx forwards it).
ARG API_BASE_URL=/api
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# --- what is served -----------------------------------------------------------------------------
FROM nginx:1.27-alpine AS runtime
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

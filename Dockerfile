# syntax=docker/dockerfile:1.9

# Define build arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Ruby image to use for base image, change with [--build-arg RUBY_VERSION="3.4.x"]
# renovate: datasource=docker depName=docker.io/ruby
ARG RUBY_VERSION="3.4.1"

# Node version to use in base image, change with [--build-arg NODE_MAJOR_VERSION="20"]
# renovate: datasource=node-version depName=node
ARG NODE_MAJOR_VERSION="22"

# Debian image to use for base image, change with [--build-arg DEBIAN_VERSION="bookworm"]
ARG DEBIAN_VERSION="bookworm"

# Node base image
FROM docker.io/node:${NODE_MAJOR_VERSION}-${DEBIAN_VERSION}-slim AS node

# Ruby base image
FROM docker.io/ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION} AS ruby

# Mastodon version and metadata
ARG MASTODON_VERSION_PRERELEASE=""
ARG MASTODON_VERSION_METADATA=""
ARG SOURCE_COMMIT=""

# Rails and Ruby configuration
ARG RAILS_SERVE_STATIC_FILES="true"
ARG RUBY_YJIT_ENABLE="1"
ARG TZ="Etc/UTC"
ARG UID="991"
ARG GID="991"

# Environment variables
ENV \
  MASTODON_VERSION_PRERELEASE="${MASTODON_VERSION_PRERELEASE}" \
  MASTODON_VERSION_METADATA="${MASTODON_VERSION_METADATA}" \
  SOURCE_COMMIT="${SOURCE_COMMIT}" \
  RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES} \
  RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE} \
  TZ=${TZ} \
  BIND="0.0.0.0" \
  NODE_ENV="production" \
  RAILS_ENV="production" \
  DEBIAN_FRONTEND="noninteractive" \
  PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin" \
  MALLOC_CONF="narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0" \
  MASTODON_USE_LIBVIPS=true \
  MASTODON_SIDEKIQ_READY_FILENAME=sidekiq_process_has_started_and_will_begin_processing_jobs

# Set shell for RUN commands
SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]

# Print target platform for debugging
RUN echo "Target platform is $TARGETPLATFORM"

# Create mastodon user and set up directories
RUN \
  rm -f /etc/apt/apt.conf.d/docker-clean; \
  echo "${TZ}" > /etc/localtime; \
  groupadd -g "${GID}" mastodon; \
  useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon; \
  ln -s /opt/mastodon /mastodon;

# Set working directory
WORKDIR /opt/mastodon

# Install system dependencies
RUN \
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  apt-get update && apt-get dist-upgrade -yq && \
  apt-get install -y --no-install-recommends \
  curl \
  file \
  libjemalloc2 \
  patchelf \
  procps \
  unzip \
  tini \
  tzdata \
  wget && \
  patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby && \
  apt-get purge -y patchelf;

#install aws cli 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip
RUN ./aws/install && aws --version

# Build stage for dependencies
FROM ruby AS build

# Copy package files
COPY package.json yarn.lock .yarnrc.yml /opt/mastodon/
COPY .yarn /opt/mastodon/.yarn

# Copy Node binaries and libraries
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /usr/local/lib /usr/local/lib

# Install build tools and dependencies
RUN \
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  cmake \
  git \
  libgdbm-dev \
  libglib2.0-dev \
  libgmp-dev \
  libicu-dev \
  libidn-dev \
  libpq-dev \
  libssl-dev \
  libtool \
  libyaml-dev \
  meson \
  nasm \
  pkg-config \
  shared-mime-info \
  xz-utils \
  libcgif-dev \
  libexif-dev \
  libexpat1-dev \
  libgirepository1.0-dev \
  libheif-dev \
  libimagequant-dev \
  libjpeg62-turbo-dev \
  liblcms2-dev \
  liborc-dev \
  libspng-dev \
  libtiff-dev \
  libwebp-dev \
  libdav1d-dev \
  liblzma-dev \
  libmp3lame-dev \
  libopus-dev \
  libsnappy-dev \
  libvorbis-dev \
  libvpx-dev \
  libx264-dev \
  libx265-dev;

# Configure Corepack
RUN \
  rm /usr/local/bin/yarn*; \
  corepack enable; \
  corepack prepare --activate;

# Build libvips
FROM build AS libvips
ARG VIPS_VERSION=8.16.0
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

WORKDIR /usr/local/libvips/src
ADD ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz /usr/local/libvips/src/
RUN tar xf vips-${VIPS_VERSION}.tar.xz;

WORKDIR /usr/local/libvips/src/vips-${VIPS_VERSION}
RUN \
  meson setup build --prefix /usr/local/libvips --libdir=lib -Ddeprecated=false -Dintrospection=disabled -Dmodules=disabled -Dexamples=false; \
  cd build; \
  ninja; \
  ninja install;

# Build ffmpeg
FROM build AS ffmpeg
ARG FFMPEG_VERSION=7.1
ARG FFMPEG_URL=https://ffmpeg.org/releases

WORKDIR /usr/local/ffmpeg/src
ADD ${FFMPEG_URL}/ffmpeg-${FFMPEG_VERSION}.tar.xz /usr/local/ffmpeg/src/
RUN tar xf ffmpeg-${FFMPEG_VERSION}.tar.xz;

WORKDIR /usr/local/ffmpeg/src/ffmpeg-${FFMPEG_VERSION}
RUN \
  ./configure \
  --prefix=/usr/local/ffmpeg \
  --toolchain=hardened \
  --disable-debug \
  --disable-devices \
  --disable-doc \
  --disable-ffplay \
  --disable-network \
  --disable-static \
  --enable-ffmpeg \
  --enable-ffprobe \
  --enable-gpl \
  --enable-libdav1d \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsnappy \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libx264 \
  --enable-libx265 \
  --enable-shared \
  --enable-version3; \
  make -j$(nproc); \
  make install;

# Install Ruby gems
FROM build AS bundler
COPY Gemfile* /opt/mastodon/

RUN \
  --mount=type=cache,id=gem-cache-${TARGETPLATFORM},target=/usr/local/bundle/cache/,sharing=locked \
  bundle config set --global frozen "true"; \
  bundle config set --global cache_all "false"; \
  bundle config set --local without "development test"; \
  bundle config set silence_root_warning "true"; \
  bundle install -j"$(nproc)";

# Install Node packages
FROM build AS yarn
COPY package.json yarn.lock .yarnrc.yml /opt/mastodon/
COPY streaming/package.json /opt/mastodon/streaming/
COPY .yarn /opt/mastodon/.yarn

RUN \
  --mount=type=cache,id=corepack-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/corepack,sharing=locked \
  --mount=type=cache,id=yarn-cache-${TARGETPLATFORM},target=/usr/local/share/.cache/yarn,sharing=locked \
  yarn workspaces focus --production @mastodon/mastodon;

# Precompile assets
FROM build AS precompiler
COPY . /opt/mastodon/
COPY --from=yarn /opt/mastodon /opt/mastodon/
COPY --from=bundler /opt/mastodon /opt/mastodon/
COPY --from=bundler /usr/local/bundle/ /usr/local/bundle/
COPY --from=libvips /usr/local/libvips/bin /usr/local/bin
COPY --from=libvips /usr/local/libvips/lib /usr/local/lib

#precompile and remove tmp 
RUN ldconfig && \
  SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile && \
  rm -fr /opt/mastodon/tmp

# Final Mastodon image
FROM ruby AS mastodon
ARG TARGETPLATFORM

# Install runtime dependencies
RUN \
  --mount=type=cache,id=apt-cache-${TARGETPLATFORM},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=apt-lib-${TARGETPLATFORM},target=/var/lib/apt,sharing=locked \
  apt-get update && apt-get install -y --no-install-recommends \
  libexpat1 \
  libglib2.0-0 \
  libicu72 \
  libidn12 \
  libpq5 \
  libreadline8 \
  libssl3 \
  libyaml-0-2 \
  libcgif0 \
  libexif12 \
  libheif1 \
  libimagequant0 \
  libjpeg62-turbo \
  liblcms2-2 \
  liborc-0.4-0 \
  libspng0 \
  libtiff6 \
  libwebp7 \
  libwebpdemux2 \
  libwebpmux3 \
  libdav1d6 \
  libmp3lame0 \
  libopencore-amrnb0 \
  libopencore-amrwb0 \
  libopus0 \
  libsnappy1v5 \
  libtheora0 \
  libvorbis0a \
  libvorbisenc2 \
  libvorbisfile3 \
  libvpx7 \
  libx264-164 \
  libx265-199;

# Copy application files and precompiled assets
COPY . /opt/mastodon/
COPY --from=precompiler /opt/mastodon/public/packs /opt/mastodon/public/packs
COPY --from=precompiler /opt/mastodon/public/assets /opt/mastodon/public/assets
COPY --from=bundler /usr/local/bundle/ /usr/local/bundle/
COPY --from=libvips /usr/local/libvips/bin /usr/local/bin
COPY --from=libvips /usr/local/libvips/lib /usr/local/lib
COPY --from=ffmpeg /usr/local/ffmpeg/bin /usr/local/bin
COPY --from=ffmpeg /usr/local/ffmpeg/lib /usr/local/lib

# Verify media processors
RUN \
  ldconfig; \
  vips -v; \
  ffmpeg -version; \
  ffprobe -version;

# Precompile bootsnap code
RUN bundle exec bootsnap precompile --gemfile app/ lib/;

# Set up system volume and permissions
RUN \
  mkdir -p /opt/mastodon/public/system; \
  chown mastodon:mastodon /opt/mastodon/public/system; \
  chown -R mastodon:mastodon /opt/mastodon/tmp;\
  chown -R mastodon:mastodon /opt/mastodon/config;

# Set Mastodon user and expose ports
USER mastodon
EXPOSE 3000 4000
ENTRYPOINT ["/usr/bin/tini", "--"]
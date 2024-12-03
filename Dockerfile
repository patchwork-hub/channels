# syntax=docker/dockerfile:1.9

ARG TARGETPLATFORM=${TARGETPLATFORM}
ARG BUILDPLATFORM=${BUILDPLATFORM}
ARG RUBY_VERSION="3.3.4"
ARG NODE_MAJOR_VERSION="20"
ARG DEBIAN_VERSION="bookworm"

# Base stage with common dependencies
FROM docker.io/debian:${DEBIAN_VERSION}-slim AS base
ARG TZ="Etc/UTC"
ARG UID="991"
ARG GID="991"

ENV TZ=${TZ} \
    DEBIAN_FRONTEND="noninteractive" \
    PATH="${PATH}:/opt/ruby/bin:/opt/mastodon/bin" \
    RAILS_ENV="production" \
    NODE_ENV="production" \
    MALLOC_CONF="narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo "${TZ}" > /etc/localtime && \
    groupadd -g "${GID}" mastodon && \
    useradd -l -u "${UID}" -g "${GID}" -m -d /opt/mastodon mastodon && \
    ln -s /opt/mastodon /mastodon

# Common build dependencies
FROM base AS build-deps
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget file build-essential git \
    libssl-dev libpq-dev libicu-dev \
    autoconf automake libtool pkg-config \
    ca-certificates gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Node.js stage
FROM node:${NODE_MAJOR_VERSION}-${DEBIAN_VERSION}-slim AS node
RUN npm install -g corepack yarn

# Ruby stage
FROM ruby:${RUBY_VERSION}-slim-${DEBIAN_VERSION} AS ruby
RUN gem update --system && \
    gem install bundler:2.5.3

# Dependency installation stage
FROM build-deps AS deps
WORKDIR /opt/mastodon

# Copy only dependency files first
COPY Gemfile* package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY streaming/package.json ./streaming/

# Install Ruby dependencies
RUN --mount=type=cache,target=/usr/local/bundle/cache,sharing=locked \
    bundle config set --local without 'development test' && \
    bundle install -j"$(nproc)" && \
    bundle clean

# Install Node.js dependencies
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn,sharing=locked \
    corepack enable && \
    yarn install --frozen-lockfile --production

# Compilation stage for native extensions
FROM deps AS native-build
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    libvips-dev libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Final image
FROM base AS final
COPY --from=native-build /usr/local/bundle /usr/local/bundle
COPY --from=deps /opt/mastodon /opt/mastodon
COPY . /opt/mastodon

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile && \
    chown -R mastodon:mastodon /opt/mastodon

USER mastodon
WORKDIR /opt/mastodon

EXPOSE 3000
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION:-2.6.6}-alpine AS dev

RUN apk update \
  && apk upgrade \
  && apk add --update \
    tzdata \
    git \
    bash \
    linux-headers \
    build-base \
    postgresql-dev \
    postgresql-client \
    && rm -rf /var/cache/apk/*

WORKDIR /usr/src/app

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

RUN gem install bundler -v 2.1.4

# TODO: Add production stage

FROM dev AS release

COPY Gemfile Gemfile.lock tapy.gemspec ./

COPY lib/tapy/version.rb lib/tapy/version.rb

RUN bundle install --jobs 2 --retry 1

COPY . .

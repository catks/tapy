FROM ruby:{{ruby | default: "2.7.2"}}-alpine AS dev

RUN apk update \
  && apk upgrade \
  && apk add --update \
    tzdata \
    linux-headers \
    build-base \
{%- if postgres %}
    postgresql-dev  \
    postgresql-client \
{%- endif %}
    && rm -rf /var/cache/apk/*

WORKDIR /usr/src/app
{% if bundler %}
RUN gem install bundler -v {{ bundler }}
{% endif %}
# TODO: Add production stage

FROM dev AS release

COPY Gemfile Gemfile.lock{% if gemspec%} {{gemspec}}{% endif %} ./

RUN bundle install --jobs 2 --retry 1

COPY . .

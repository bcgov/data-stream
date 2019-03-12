FROM ruby:2.5.3-slim

RUN apt-get update -qq && \
    apt-get install -y nano build-essential libpq-dev node.js curl && \
    gem install bundler

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app
COPY . /app

RUN \
	bundle update rake && \
	bundle exec rake RAILS_ENV=production SECRET_KEY_BASE=AnySecretKey assets:precompile && \
	bundle install

RUN bundle update redis

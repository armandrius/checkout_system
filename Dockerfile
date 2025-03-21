FROM ruby:3.4-slim

RUN apt-get update && apt-get install -y build-essential
RUN apt-get install --no-install-recommends -y libyaml-dev


ENV RUBY_YJIT_ENABLE=1
ENV APP_HOME=/ruby-app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY . $APP_HOME
RUN bundle install --jobs 20 --retry 5

RUN chmod +x $APP_HOME/bin/checkout_system
RUN chmod +x $APP_HOME/bin/shop

FROM ruby:2.5-slim

RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev

ENV APP_HOME=/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

RUN bundle install

COPY . $APP_HOME

ENV PORT=3000
ENV SEED=peer1,peer2
ENV HOSTNAME=peer
ENV RACK_ENV=development

EXPOSE ${PORT}

CMD bundle exec puma -p ${PORT}

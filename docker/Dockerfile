FROM ruby:2.7

ADD ./Gemfile /app/Gemfile
ADD ./Gemfile.lock /app/Gemfile.lock
WORKDIR /app

RUN gem install bundler
RUN bundle install

CMD bundle exec request_repeater

FROM ruby:2.5.1
MAINTAINER Tom Hipkin <tomh@dxw.com>

RUN apt-get update -qq

ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

COPY . $APP_HOME

EXPOSE 5000
CMD ["bundle", "exec", "puma", "-p", "5000"]

FROM ruby:alpine
MAINTAINER an_x an_xiaoqiang@find_me_at.slack
RUN adduser -S ubuntu
USER ubuntu
RUN apk update && apk add --upgrade build-base postgresql-dev yarn nodejs
WORKDIR /myapp
ADD . /myapp
RUN bundle install --without development test
EXPOSE 3000

FROM ruby:alpine
MAINTAINER an_x an_xiaoqiang@find_me_at.slack
RUN apk update && apk add --upgrade build-base postgresql-dev yarn nodejs
WORKDIR /myapp
ADD . /myapp
ENV RAILS_ENV production
RUN bundle install --without development test && rails assets:precompile
EXPOSE 3000

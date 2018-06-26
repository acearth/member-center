FROM ruby:alpine
RUN apk update && apk add --upgrade build-base postgresql-dev yarn nodejs
WORKDIR /myapp
ADD . /myapp
RUN bundle install --without development test
EXPOSE 3000

FROM ruby:alpine
RUN apk update && apk add --upgrade yarn nodejs 
#RUN apt update && apt install -y apt-transport-https
#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
	    #curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	    #echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	    #apt update -qq && apt install -y build-essential libpq-dev nodejs yarn
WORKDIR /myapp
ADD . /myapp
RUN bundle install
EXPOSE 3000

FROM ruby:2.5.9
RUN apt-get update && apt-get install -y nodejs && apt-get install -y vim
WORKDIR /app
COPY Gemfile* .
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]


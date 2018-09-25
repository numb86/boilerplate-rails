#!/bin/bash

read -p 'Please enter your project name: ' project_name
while [ "$project_name" = "" ]
do
  read -p 'Please enter your project name: ' project_name
done

container_name="${project_name}_container"
db_name="${project_name}_db"

cat <<__END_OF_MESSAGE__ > Dockerfile
FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /${project_name}
WORKDIR /${project_name}
COPY Gemfile /${project_name}/Gemfile
COPY Gemfile.lock /${project_name}/Gemfile.lock
RUN bundle install
COPY . /${project_name}

__END_OF_MESSAGE__

cat <<__END_OF_MESSAGE__ > docker-compose.yml
version: '3'
services:
  ${db_name}:
    image: postgres
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
  ${container_name}:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/${project_name}
    ports:
      - "3000:3000"
    depends_on:
      - ${db_name}

__END_OF_MESSAGE__

docker-compose run ${container_name} rails new . --skip-turbolinks --force --database=postgresql
docker-compose build

cat <<__END_OF_MESSAGE__ > config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: ${db_name}
  username: postgres
  password:
  pool: 5

development:
  <<: *default
  database: ${project_name}_development


test:
  <<: *default
  database: ${project_name}_test

__END_OF_MESSAGE__

docker-compose run ${container_name} rake db:create

cat <<__END_OF_MESSAGE__ > config/application.rb
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ${project_name^}
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.test_framework false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

__END_OF_MESSAGE__

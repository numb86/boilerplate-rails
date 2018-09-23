Require Docker and Docker Compose.

1. clone
2. bash init.sh
3. docker-compose up

I referred to [this page](https://docs.docker.com/compose/rails/).

### Rebuild the application

If you make changes to the Gemfile or the Compose file to try out some different
configurations, you need to rebuild. Some changes require only
`docker-compose up --build`, but a full rebuild requires a re-run of
`docker-compose run web bundle install` to sync changes in the `Gemfile.lock` to
the host, followed by `docker-compose up --build`.

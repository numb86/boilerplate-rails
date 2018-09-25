I referred to [this page](https://docs.docker.com/compose/rails/).

Require Docker and Docker Compose.
And, you should update bash to over v4.

1. clone
2. bash init.sh
3. docker-compose up

When you enter project name as `foo`, `YOUR_CONTAINER_NAME` is `foo_container`.
Similarly `YOUR_DB_NAME` is `foo_db`.

For example case you start `rails console`,

```
$ docker-compose exec foo_container bundle exec rails c
```

### Rebuild the application

If you make changes to the Gemfile or the Compose file to try out some different
configurations, you need to rebuild. Some changes require only
`docker-compose up --build`, but a full rebuild requires a re-run of
`docker-compose run YOUR_CONTAINER_NAME bundle install` to sync changes in the `Gemfile.lock` to
the host, followed by `docker-compose up --build`.

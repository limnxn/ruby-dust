# RubyDust

_"Tracing trends in games — one glimmer at a time."_

RubyDust is a game trend analysis toolkit,  
written in Ruby, for those who seek patterns in the stardust of data.

Like fragments of meteor trails,  
each insight glows briefly — but tells a story worth studying.

## MySQL

### Migration

```bash
$ docker compose exec alpine ruby activerecord_migration.rb
```

### Backup

```bash
$ docker compose exec mysql sh -c 'mysqldump -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE > /var/db/$(date +%y%m%d)_$MYSQL_DATABASE.sql'
```

## Cron

```bash
$ docker compose exec alpine crontab jobs/scraping_job.sh
```

```bash
$ docker compose exec alpine crontab -l
```

```bash
$ docker compose exec alpine crond -f
```

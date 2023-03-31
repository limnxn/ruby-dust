# Gametrend

## Introduction

Visualize the sales ranking of social games on Google Play and DMM GAMES.

## Database

### Migration

```bash
$ docker-compose exec alpine ruby activerecord_migration.rb
```

### Backup

```bash
$ docker-compose exec mysql sh -c 'mysqldump -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE > /var/db/$(date +%y%m%d)_$MYSQL_DATABASE.sql'
```

## Crontab

### Add

```bash
$ docker-compose exec alpine crontab jobs/scraping_job.sh
```

### List

```bash
$ docker-compose exec alpine crontab -l
```

### Run

```bash
$ docker-compose exec alpine crond -f
```

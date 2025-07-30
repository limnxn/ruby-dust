# RubyDust

_"Tracing trends in games — one glimmer at a time."_

RubyDust is a game trend analysis toolkit,  
written in Ruby, for those who seek patterns in the stardust of data.

Like fragments of meteor trails,  
each insight glows briefly — but tells a story worth studying.

---

## ⚙️ Database Operations

### 🔄 Run Migration

Apply schema changes using ActiveRecord:

```bash
$ docker compose exec alpine ruby activerecord_migration.rb
```

### 💾 Backup Database

Save a snapshot of the current MySQL database:

```bash
$ docker compose exec mysql sh -c 'mysqldump -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE > /var/db/$(date +%y%m%d)_$MYSQL_DATABASE.sql'
```

## ⏲️ Scheduled Jobs (Cron)

### 📅 Register Cron Job

Set up the scraping job in crontab:

```bash
$ docker compose exec alpine crontab jobs/scraping_job.sh
```

### 🔍 View Cron Jobs

List all scheduled cron jobs:

```bash
$ docker compose exec alpine crontab -l
```

### 🚀 Start Cron Daemon

Begin running cron tasks in foreground:

```bash
$ docker compose exec alpine crond -f
```

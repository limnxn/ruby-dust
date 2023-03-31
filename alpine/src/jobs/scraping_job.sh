#!/bin/bash

0 12 * * * ruby /app/activerecord_migration.rb; ruby /app/crawler_dmmgames.rb; ruby /app/crawler_googleplay.rb; docker exec mysql_gametrend sh -c 'mysqldump -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE > /var/db/$(date +%y%m%d)_$MYSQL_DATABASE.sql'
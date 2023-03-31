#!/bin/bash

ruby /app/activerecord_migration.rb
ruby /app/crawler_dmmgames.rb
ruby /app/crawler_googleplay.rb
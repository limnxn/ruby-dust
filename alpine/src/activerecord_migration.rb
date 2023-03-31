require "active_record"
require "/app/activerecord_base.rb"

return if ActiveRecord::Base.connection.table_exists?(:dmmgames)
ActiveRecord::Migration.create_table :dmmgames do |t|
  t.integer :rank
  t.integer :game_id
  t.string :name
  t.text :description
  t.string :genre
  t.string :film_rating
  t.string :device
  t.string :sort
  t.string :category
  t.string :site_url
  t.string :icon
  t.datetime :created_at
  t.datetime :updated_at
end

return if ActiveRecord::Base.connection.table_exists?(:googleplay)
ActiveRecord::Migration.create_table :googleplay do |t|
  t.integer :rank
  t.string :name
  t.string :star_rating
  t.string :icon
  t.string :company
  t.datetime :created_at
  t.datetime :updated_at
end

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  host: "mysql_gametrend",
  database: "gametrend",
  username: "test",
  password: "passw0rd",
  charset: "utf8mb4",
  encoding: "utf8mb4",
  collation: "utf8mb4_general_ci"
)

ActiveRecord.default_timezone = :local

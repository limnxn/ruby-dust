require "selenium-webdriver"
require "open-uri"
require "uri"
require "json"
require "jsonpath"
require "rmagick"
require "active_record"
require "/app/activerecord_base.rb"
require "/app/openuri_config.rb"

class DmmGames < ActiveRecord::Base
  DEFAULT_OPTIONS = {
    host: {
      general: "games.dmm.com",
      r18: "games.dmm.co.jp"
    },
    device: {
      desktop: "pc",
      mobile: "sp"
    },
    sort: {
      new: "new",
      popular: "popular",
      start: "start"
    },
    app: "/app",
    resource: "list",
    date: Time.new.strftime("%y%m%d")
  }

  attr_reader :options, :results_parameter, :results_url, :results_type, :results_value, :results_data
  self.table_name = "dmmgames"

  def initialize(*)
    super
    @options = DEFAULT_OPTIONS
    @results_parameter, @results_url, @results_type = [], [], []
    @results_value = {}
    @results_data = Hash.new { |h, k| h[k] = {} }
  end

  def build
    puts "DMM GAMES"
    puts "---------"
    create_parameter
    create_url
    create_type
    puts "Starting scraping"
    scraping
    puts "Creating directories"
    create_dir("#{@options[:app]}/downloads/#{@options[:date]}")
    puts "Downloading files"
    download_thumbnail("#{@options[:app]}/downloads/#{@options[:date]}")
    puts "Inserting rows"
    insert_data
    puts "Finished insert"
  end

  def download_thumbnail(directory)
    regex_appname = '(?<=\/\/)(?!games)(.*?)(?=\/|$)|(?<=detail\/)(.*)(?=\/)'
    @results_data.each do |key, value|
      value.first.second.size.times do |index|
        URI.open(@results_data[key][:thumbnail][index]) do |response|
          brand = @results_data[key][:thumbnail][index].match(".+dmm.com.*$") ? "dmm" : "fanza"
          file = "#{directory}/dmmgames/#{@options[:date]}_#{brand}_#{@results_data[key][:link][index].match(regex_appname).to_a.first}"
          image = Magick::ImageList.new(File.open(response, "r+b"))
          image.write("#{file}.webp")
        end
      end
    end
  end

  def create_dir(directory)
    Dir.mkdir(directory) unless Dir.exists?(directory)
    Dir.mkdir("#{directory}/dmmgames") unless Dir.exists?("#{directory}/dmmgames")
  end

  def create_parameter
    @options[:device].each_value { |device| @options[:sort].each_value { |sort| @results_parameter << "#{device}?sort=#{sort}" } }
    return @results_parameter
  end

  def create_url
    @options[:host].each_value { |host| @results_parameter.each { |parameter| @results_url << "https://#{host}/#{@options[:resource]}/#{parameter}" } }
    return @results_url
  end

  def create_type
    @results_url.each do |url|
      url = url.gsub("https://#{@options[:host][:general]}/list/", "General_")
      url = url.gsub("https://#{@options[:host][:r18]}/list/", "R18_")
      url = url.gsub("?sort=", "_")
      url = url.upcase
      @results_type << url
    end
    return @results_type
  end

  # 2022/08/19 Successed
  def scraping
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get("https://games.dmm.co.jp/")
    driver.manage.add_cookie(name: "age_check_done", value: "1", domain: ".dmm.co.jp")
    driver.navigate.refresh

    @results_value.store(:url, @results_url)
    @results_value.store(:type, @results_type)
    start_time = Time.now

    @results_value.first.second.size.times do |index|
      driver.navigate.to(@results_value[:url][index])
      driver.find_element(:xpath, "//button[contains(text(), '表示')]").click
      nextdata = driver.find_element(:xpath, '//*[@id="__NEXT_DATA__"]')
      jsondata = JSON.parse(nextdata.attribute("innerHTML"))
      @results_data[@results_value[:type][index].intern][:gameId] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].gameId").on(jsondata)
      @results_data[@results_value[:type][index].intern][:name] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].name").on(jsondata)
      @results_data[@results_value[:type][index].intern][:description] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].description").on(jsondata)
      @results_data[@results_value[:type][index].intern][:genre] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].genre").on(jsondata)
      @results_data[@results_value[:type][index].intern][:type] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].type").on(jsondata)
      @results_data[@results_value[:type][index].intern][:link] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].link").on(jsondata)
      @results_data[@results_value[:type][index].intern][:thumbnail] = JsonPath.new("$.props.pageProps.*[?(@.idHash!=null)].thumbnail").on(jsondata)
      puts "=> # (#{index + 1}\/#{@results_value.first.second.size}) Scraping #{@results_value[:url][index]} #{(Time.now - start_time).round(1)}s"
    end

    driver.quit
  end

  def insert_data
    start_time = Time.now
    @results_data.each do |key, value|
      value.first.second.size.times do |index|
        DmmGames.create(
          rank: index,
          game_id: @results_data[key][:gameId][index],
          name: @results_data[key][:name][index],
          description: @results_data[key][:description][index],
          genre: @results_data[key][:genre][index],
          film_rating: key.to_s.match("(GENERAL|R18)").to_a.first,
          device: key.to_s.match("(PC|SP)").to_a.first,
          sort: key.to_s.match("(NEW|POPULAR|START)").to_a.first,
          category: @results_data[key][:type][index],
          site_url: @results_data[key][:link][index],
          icon: @results_data[key][:thumbnail][index]
        )
      end
      puts "=> # [#{key}] #{(Time.now - start_time).round(1)}s"
    end
  end
end

dmmGames = DmmGames.new
dmmGames.build

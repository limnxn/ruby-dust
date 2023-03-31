require "selenium-webdriver"
require "open-uri"
require "uri"
require "rmagick"
require "active_record"
require "/app/activerecord_base.rb"
require "/app/openuri_config.rb"

class GooglePlay < ActiveRecord::Base
  DEFAULT_OPTIONS = {
    url: "https://play.google.com/store/apps/collection/topgrossing?hl=ja&gl=JP",
    xpath: {
      app_id: '//div[@role="listitem"]/div/div/a',
      app_icon: '//div[@role="listitem"]/div/div/a/div[1]/img',
      app_name: '//div[@role="listitem"]/div/div/a/div[2]/div[@title]/div',
      star_rating: '//div[@role="listitem"]/div/div/a/div[2]/div[2]/div[1]',
      co_name: "//h1/following-sibling::div/div[1]/a"
    },
    app: "/app",
    date: Time.new.strftime("%y%m%d")
  }

  attr_reader :options, :results_data
  self.table_name = "googleplay"

  def initialize(*)
    super
    @options = DEFAULT_OPTIONS
    @results_data = {}
  end

  def build
    puts "Google Play"
    puts "-----------"
    puts "Starting scraping"
    scraping
    puts "Creating directories"
    create_dir("#{@options[:app]}/downloads/#{@options[:date]}")
    puts "Downloading files"
    download_icon("#{@options[:app]}/downloads/#{@options[:date]}")
    puts "Inserting rows"
    insert_data
    puts "Finished insert"
  end

  def download_icon(directory)
    @results_data[:app_icon].zip(@results_data[:app_id]) do |app_icon, app_id|
      URI.open(app_icon) do |response|
        image = Magick::ImageList.new(File.open(response, "r+b"))
        image.write("#{directory}/googleplay/#{@options[:date]}_#{app_id}.webp")
      end
    end
  end

  def create_dir(directory)
    Dir.mkdir(directory) unless Dir.exists?(directory)
    Dir.mkdir("#{directory}/googleplay") unless Dir.exists?("#{directory}/googleplay")
  end

  # 2022/08/19 Successed
  def scraping
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    driver = Selenium::WebDriver.for :chrome, options: options
    driver.navigate.to(@options[:url])

    10.times do
      sleep(1)
      driver.execute_script("window.scroll(0,1000000);")
    end

    results_app_id, results_app_name, results_app_icon, results_star_rating, results_co_name = [], [], [], [], []
    driver.find_elements(:xpath, @options[:xpath][:app_id]).each { |element| results_app_id << element["href"].match('(?<=id\=)(.*)').to_a.first }
    driver.find_elements(:xpath, @options[:xpath][:app_name]).each { |element| results_app_name << element.text }
    driver.find_elements(:xpath, @options[:xpath][:app_icon]).each { |element| results_app_icon << element["src"] }
    driver.find_elements(:xpath, @options[:xpath][:star_rating]).each { |element| results_star_rating << (element.text).match('(^\d)(.*)(\d)').to_a.first }

    start_time = Time.now
    results_app_link = []
    driver.find_elements(:xpath, @options[:xpath][:app_id]).each { |element| results_app_link << element["href"] }
    results_app_link.size.times do |index|
      driver.navigate.to(results_app_link[index])
      results_co_name << driver.find_element(:xpath, @options[:xpath][:co_name]).text
      puts "=> # (#{index + 1}\/#{results_app_link.size}) Pushing #{results_app_link[index]} #{(Time.now - start_time).round(1)}s"
    end

    @results_data.store(:app_id, results_app_id)
    @results_data.store(:app_name, results_app_name)
    @results_data.store(:app_icon, results_app_icon)
    @results_data.store(:star_rating, results_star_rating)
    @results_data.store(:co_name, results_co_name)

    driver.quit
  end

  def insert_data
    start_time = Time.now
    results_data = @results_data.first.second.size
    results_data.times do |index|
      GooglePlay.create(
        rank: index,
        name: @results_data[:app_name][index],
        star_rating: @results_data[:star_rating][index],
        icon: @results_data[:app_icon][index],
        company: @results_data[:co_name][index]
      )
      puts "=> # (#{index + 1}\/#{results_data}) Inserting #{@results_data[:app_name][index]} #{(Time.now - start_time).round(1)}s"
    end
  end
end

googlePlay = GooglePlay.new
googlePlay.build

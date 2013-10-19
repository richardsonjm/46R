require_relative './environment.rb'

scrape = MountainScraper.new
mountains = scrape.call

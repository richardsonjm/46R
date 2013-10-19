require_relative './environment.rb'

scrape = Scrape.new
mountains = scrape.populate
binding.pry
# students = scrape.call

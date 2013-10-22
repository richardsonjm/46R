require_relative './environment.rb'

# new_db = Scrape.new
# new_db.call

cli = CLIMountain.new(Mountain.all, Hike.all)
cli.call
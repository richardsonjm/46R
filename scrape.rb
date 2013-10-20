require_relative './environment'

# class MountainScraper

#   def initialize
#     @mt_index_scrape = mt_list(Nokogiri::HTML(open(ADK)))
#   end

#   def mt_list(mt_index_scrape)
#     mt_index_scrape.css(".lists").collect {|mt| mt.content}
#   end

# end

class HikeScraper
  attr_accessor :hike_page

  def initialize
    @hike_page = Nokogiri::HTML(open(HIKE))  
  end

  def get_hike_url
    hike_url = self.hike_page.css('.odd .guide-preview-content .title a').collect{|hike| hike.attr('href')}
    hike_url << self.hike_page.css('.odd .guide-preview-content .title a').collect{|hike| hike.attr('href')}
    hike_url.flatten
  end

  def get_hike_deets
    self.hike_page.css(".container-body .meta").collect{|deets| deets.content.strip.gsub! /\t\t\t\t\n\t\t\t\t\t\t/, " "}.collect{|deets| deets.split}
  end

  def get_hike_difficulty
    difficulty = []
    i = 0
    while i < 23
      difficulty << get_hike_deets[i][0]
      i += 1 
    end
    difficulty
  end

  def get_hike_miles
    length = []
    i = 0
    while i < 23
      length << get_hike_deets[i][1].to_f
      i += 1
    end
    length
  end

  def get_hike_time
    time = []
    i = 0
    while i < 23
      time << (get_hike_deets[i][3] + "-" + get_hike_deets[i][4])
      i += 1
    end
    time
  end

  def get_hike_desc
    desc = []
    i = 7
    while i < 375
      desc << self.hike_page.css(".container-body").children.children.children.children[i].text
      i += 16
    end
    desc
  end

end




# class Scrape
#   def call
#     mt = MountainScraper.new
#     mt.
#     mt_index_page = Nokogiri::HTML(open(ADK))
#     mt_list = get_mt_index(mt_index_page)
#     hike_page = Nokogiri::HTML(open(HIKE))  
#     binding.pry
#   end

#   def populate
#     i=0
#     while i < 138
#       mt = Mountain.new
#       mt.rank = get_mt_index[i].to_i
#       mt.name = get_mt_index[i+=1]
#       mt.elevation = get_mt_index[i+=1].to_i
#       mt.save
#       @mountains << mt
#       i+=1
#     end
#       mt = Mountain.new
#       mt.rank = 0 
#       mt.name = get_mt_index[138]
#       mt.elevation = get_mt_index[139]
#       @mountains << mt
#       mt.save
#     @mountains
#   end
# end




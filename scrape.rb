require_relative './environment'

class MountainScraper
  attr_accessor :mt_index, :mountains

  def initialize
    @mt_index = Nokogiri::HTML(open(ADK))
    @mountains = []
  end

  def mt_list
    self.mt_index.css(".lists").collect {|mt| mt.content}
  end

  def populate
    i=0
    while i < 138
      mt = Mountain.new
      mt.rank = mt_list[i].to_i
      mt.name = mt_list[i+=1]
      mt.elevation = mt_list[i+=1].to_i
      mt.save
      @mountains << mt
      i+=1
    end
    mt = Mountain.new
    mt.rank = 0
    mt.name = mt_list[138]
    mt.elevation = mt_list[139]
    mt.save
    @mountains << mt    
  end
end


class HikeScraper
  attr_accessor :hike_page

  def initialize
    @hike_page = Nokogiri::HTML(open(HIKE)) 
    @hikes = [] 
  end

  def get_hike_name
    self.hike_page.css('.container-body').children.children.children.css('.title a').collect{|hike| hike.content}
  end

  def get_hike_url
    self.hike_page.css('.container-body').children.children.children.css('.title a').collect{|hike| "http://www.everytrail.com" + hike.attr('href')}
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



class Scrape

  def call
    mt_scrape = MountainScraper.new
    mt_scrape.populate
    hikes = HikeScraper.new
    i = 0
    while i < 23
      hk = Hike.new
      hk.hike_name = hikes.get_hike_name[i]
      hk.hike_url = hikes.get_hike_url[i]
      hk.hike_diff = hikes.get_hike_difficulty[i]
      hk.hike_miles = hikes.get_hike_miles[i]
      hk.hike_time = hikes.get_hike_time[i]
      hk.hike_desc = hikes.get_hike_desc[i]
      hk.save
      mt_scrape.mountains.each do |mountain|
        if hk.hike_desc.include?(mountain.name.split[0]) || hk.hike_url.include?(mountain.name.split[0].downcase)
          mountain.hike_id = hk.id
          mountain.save
        elsif mountain.name == "Macomb" || mountain.name == "Hough" || mountain.name == "South Dix" || mountain.name == "East Dix"
          mountain.hike_id = 20 
          mountain.save
        elsif mountain.name == "TableTop"
          mountain.hike_id = 19 
          mountain.save
        elsif mountain.name == "MacNaughton*"
          mountain.hike_id = 8 
          mountain.save
        elsif mountain.name == "Upper Wolf Jaw"
          mountain.hike_id = 6 
          mountain.save
        end
      end
      i += 1
    end
  end
end




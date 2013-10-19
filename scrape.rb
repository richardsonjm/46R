require_relative './environment'

class MountainScraper

  attr_accessor :list

  def initialize
    @mountains = []
  end

  
  def call
    mt_index_page = Nokogiri::HTML(open(ADK))
    mt_list = get_mt_index(mt_index_page)
    hike_page = Nokogiri::HTML(open(HIKE))  
    binding.pry
  end

  def get_mt_index(mt_index_page)
    mt_index_page.css(".lists").collect {|mt| mt.content}
  end

  def parse_hike_url(hike_page)
    hike_url = hike_page.css('.odd .guide-preview-content .title a').collect{|hike| hike.attr('href')}
    hike_url << hike_page.css('.odd .guide-preview-content .title a').collect{|hike| hike.attr('href')}
    hike_url
  end

  def populate
    i=0
    while i < 138
      mt = Mountain.new
      mt.rank = get_mt_index[i].to_i
      mt.name = get_mt_index[i+=1]
      mt.elevation = get_mt_index[i+=1].to_i
      mt.save
      @mountains << mt
      i+=1
    end
      mt = Mountain.new
      mt.rank = 0 
      mt.name = get_mt_index[138]
      mt.elevation = get_mt_index[139]
      @mountains << mt
      mt.save
    @mountains
  end
end

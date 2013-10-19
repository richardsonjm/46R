require_relative './environment'

class Scrape

  attr_accessor :list

  def initialize
    @scrape = Nokogiri::HTML(open(URL))
    @list = @scrape.css(".lists").collect {|mt| mt.content}
    @mountains = []
  end

  def populate
    i=0
    while i < 138
      mt = Mountain.new
      mt.rank = self.list[i].to_i
      mt.name = self.list[i+=1]
      mt.elevation = self.list[i+=1].to_i
      mt.save
      @mountains << mt
      i+=1
    end
      mt = Mountain.new
      mt.rank = 0 
      mt.name = self.list[138]
      mt.elevation = self.list[139]
      @mountains << mt
      mt.save
    @mountains
  end
end

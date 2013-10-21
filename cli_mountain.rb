class CLIMountain
  attr_reader :mountains

  APPROVED_COMMANDS = [:browse, :show, :help, :exit]

  def initialize(mountains)
    @mountains = mountains
    @on = true
  end

  def on?
    @on
  end

  def call
    puts "#{self.mountains.size} mountains loaded."
    choice = ''
    while on?
      while !APPROVED_COMMANDS.include?(choice)
        puts "Type command (browse, show, help, or exit):"
        choice = gets.chomp.strip.downcase.to_sym
      end

    # "send" invokes method called. http://www.ruby-doc.org/core-2.0.0/Object.html#method-i-send
      self.send(choice)
      choice = ''
    end
  end

  def browse
    Mountain.all.each do |m|
      puts "#{m.rank} #{m.name}"
    end
  end

  def help
    puts "Instructions. Type:"
    puts "-------------------------"
    puts "'help' to see this list of commands"
    puts "'browse' to list the mountains you can view"
    puts "'show mountain name or id' to see a mountain's info"
    puts "'exit' to exit."
    puts "-------------------------"
    puts 
  end

  def show
    print "Enter mountain rank or ANY PART of mountain name: "
    search = gets.chomp.strip.downcase
    if search.to_i.to_s == search     # if user enters rank
      display(Mountain.find(search.to_i))
    else
      display(Mountain.find_by_name(search))
    end
  end

  def makeArray(mountain)
    mountain.is_a?(Array) ? mountain : [mountain]
  end

  def display(mountain)
    puts "Mountain(s)"
    puts "---------------------"
    sarray = makeArray(mountain)
    if sarray.size == 0
      puts "No mountains found."
    else 
      sarray.each do |m|
        puts "Name: #{m.name}"
        puts "Rank: #{m.rank}"
        puts "Elevation: #{m.elevation}"
      end
    end
  end

  def exit
    puts "Goodbye"
    @on = false
  end
end

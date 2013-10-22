class Mountain
  
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY AUTOINCREMENT",
    :rank => "INTEGER",
    :name => "TEXT",
    :elevation => "INTEGER",
    :hike_id => "INTEGER"
  }

  def self.attributes
    ATTRIBUTES.keys
  end

  def self.attributes_hash
    ATTRIBUTES
  end

  def self.attributes_for_db
    ATTRIBUTES.keys.reject{|k| k == :id}
  end

  attr_accessor *attributes_for_db

  attr_reader :id

  def initialize(id = nil)
    @id = id
    @saved = !id.nil?
  end

  @@db = SQLite3::Database.new('forty_sixer.db')

  self.attributes.each do |attribute_name|
    define_singleton_method("find_by_#{attribute_name}") do |attr_value|
      sql = "SELECT * FROM mountains WHERE #{attribute_name} = ?"
      results = @@db.execute sql, attr_value
      self.mountains_from_rows(results)
    end
  end 

  def self.mountains_from_rows(results)
    results.collect do |row|
      Mountain.new_with_row(row)
    end
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.columns_for_create
    self.attributes_hash.collect{|k,v| "#{k} #{v}"}.join(",")
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS #{self.table_name} (#{self.columns_for_create});"
    @@db.execute(sql);
  end
  create_table

  # def new_record?
  #   !saved?
  # end

  def saved?
    @saved
  end

  def self.count
    sql = "SELECT COUNT(*) FROM #{self.table_name};"
    results = @@db.execute(sql).flatten.first
  end

  def get_id
    cmd = "SELECT MAX(id) FROM #{self.class.table_name}"
    @id = @@db.execute(cmd).flatten[0]
  end

  def self.column_names
    self.attributes_for_db.join(",")
  end

  def self.question_marks_for_insert
    "#{(["?"]*self.attributes_for_db.size).join(",")}"
  end

  def self.insert_sql
    "INSERT INTO #{self.table_name} (#{self.column_names}) VALUES (#{self.question_marks_for_insert})"
  end

  def attributes
    self.class.attributes.collect do |attribute|
      self.send(attribute)
    end
  end

  def attributes_for_insert
    self.attributes[1..-1]
  end

  def insert
    insertsql = self.class.insert_sql
    insertvals = self.attributes_for_insert
    # intervals2 = intervals.collect do |val|
    #   val.is_a?(Array) ? val.join(', ') : val
    # end
    @@db.execute(insertsql, insertvals)
    get_id
    @saved = true
  end

  def self.sql_for_update
    self.attributes_for_db.collect {|attribute| "#{attribute} = ?"}.join(",")
  end

  def attribuetes_for_update
    [self.attributes_for_insert, self.id].flatten
  end

  def update
    cmd = "UPDATE #{self.class.table_name} SET #{self.class.sql_for_update} WHERE id = ?"
    @@db.execute(cmd, self.attribuetes_for_update)
    @saved = true
  end

  def save
    if @saved
      update
    else #if Mountain.find_by_name(self.name).size == 0
      insert
    end
  end

  def self.drop_table
    sql = "DROP TABLE #{self.table_name};"
    @@db.execute sql
  end

  def self.reset_all
    self.drop_table
    self.create_table
  end

  def self.all
    sql = "SELECT * FROM #{self.table_name};"
    results = @@db.execute sql
    self.mountains_from_rows(results)
  end

  # def self.hike_n_mountain
  #   sql = "SELECT * FROM mountains JOIN hikes ON hikes.id = mountain.hike_id;"
  #   @@db.execute sql
  # end

  def ==(other_mountain)
    self.id == other_mountain.id
  end

  def self.mountains_from_rows(results)
    results.collect do |row|
      Mountain.new_with_row(row)
    end
  end

  def self.find(id)
    Mountain.find_by_id(id).first
  end 

  def self.find_by_name(searchname)
    Mountain.all.select {|mountain| mountain.name.downcase.include?(searchname.downcase.strip.squeeze(' '))}
  end

  def delete
    sql = "DELETE FROM #{self.class.table_name} WHERE id = ?"
    @@db.execute sql ,self.id
  end

  def self.load(id)
    cmd = "SELECT * FROM #{self.table_name} WHERE ID = ?"
    result = @@db.execute(cmd, id)
    Mountain.new_with_row(result.flatten)
  end

  def self.new_with_row(row)
    Mountain.new(row[0]).tap do |s|
      self.attributes_for_db.each_with_index do |attribute, i|
        s.send("#{attribute}=", row[i+1])
      end
    end
  end

  # def url
  #   self.name.downcase.gsub(/\s|'/,'-') + '.html'
  # end

  # def urlpic
  #   self.name.downcase.gsub(/\s|'/,'_')
  # end

end

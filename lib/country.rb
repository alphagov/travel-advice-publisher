class Country
  
  attr_reader :name, :slug

  def initialize(attrs)
    @name = attrs[:name]
    @slug = attrs[:slug]
  end

  def self.all
    @@countries ||= data.map{ |d| Country.new(d) }
  end

  def self.data
    YAML.load(File.open(data_path))    
  end

  def self.data_path
    File.join(Rails.root, "lib", "data", "countries.yml")
  end
end

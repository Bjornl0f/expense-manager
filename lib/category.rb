class Category
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_s
    @name
  end

  def valid?
    !@name.nil? && !@name.strip.empty?
  end

  def ==(other)
    return false unless other.is_a?(Category)
    @name == other.name
  end
end
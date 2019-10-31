module ClassMethods
  attr_accessor :ids, :alls

  def klass
    self
  end

  def all
    ObjectSpace.each_object(self).to_a
  end

  def find(id:)
    all.select { |instance| instance.id == id }&.first
  end
end

module InstanceMethods
  attr_accessor :id

  @@ids ||= 0
  @alls ||= []

  def initialize
    @@ids += 1
    self.id = @@ids
    # self.class.ids += 1
    # self.id = klass.ids
    # klass.all << self
  end

  def to_s
    "#{self.class} #{id}"
  end
end



class Car
  include InstanceMethods
  extend ClassMethods
end

class Bicycle
  include InstanceMethods
  extend ClassMethods
end

GC.start

first_car = Car.new
second_car = Car.new
third_car = Car.new
puts "first_car.id: #{first_car.id}" #=> 1
puts "third_car.id: #{third_car.id}" #=> 3
puts Car.all, Car.find(id: 3)
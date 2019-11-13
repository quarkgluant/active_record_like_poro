module ClassMethods

  def ids
    @ids ||= 0
  end

  def ids=(number)
    @ids = number
  end

  def new_id
    self.ids = (ids + 1)
  end

  def all
    ObjectSpace.each_object(self).to_a
  end

  def find(id:)
    all.select { |instance| instance.id == id }&.first
  end

  def make_attr_finders
    new.public_methods(all = false).each do |meth|
      # puts "method: #{meth}"
      unless meth.to_s.end_with? "="
        self.class.class_eval do
          define_method "find_by_#{meth}" do |arg|
            # puts "find_by_#{meth} appelée avec #{arg}"
            return self.all.select { |instance| instance.send(meth) == arg }
          end
        end
      end
    end
  end

  def self.extended(base)
    puts "#{self} (ClassMethods) a été inclus/étendu dans #{base}"
    base.make_attr_finders
  end
end

module InstanceMethods
  def self.included(base)
    puts "#{self} (InstanceMethods) a été inclus dans #{base}"
    base.make_attr_finders
  end
  attr_accessor :id

  # @@ids ||= 0

  def initialize
    # @@ids += 1
    klass = self.class
    # self.id = @@ids
    self.id = klass.send :new_id
  end

  def to_s
    "#{self.class} #{id}"
  end

end

class Car
  extend ClassMethods
  include InstanceMethods

  # attr_accessor :color, :nb_portes
  attr_accessor :id, :color, :nb_portes

  def motor
    %w[diesel gazoline electric].sample
  end
end

# class Bicycle
#   attr_accessor :color, :derailleur
#   include InstanceMethods
#   extend ClassMethods
# end

GC.start

first_car = Car.new
second_car = Car.new
third_car = Car.new
puts "first_car.id: #{first_car.id}" #=> 1
puts "third_car.id: #{third_car.id}" #=> 3
puts "Car.all: #{Car.all}"
puts "Car.find(id: 3): #{Car.find(id: 3)}"
Car.make_attr_finders
puts "Car.find_by_motor('electric'): #{Car.find_by_motor('electric')}"
puts "Car.find_by_id(3): #{Car.find_by_id(3)}"

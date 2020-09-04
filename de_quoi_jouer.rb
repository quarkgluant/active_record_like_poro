module ClassMethods
  # ce module sera "inclus" avec extend, donc
  # toutes les méthodes de ce module seront des méthodes de classe

  # les 2 méthodes ci-dessous, équivalentes à attr_accessor mais "de classe"
  # l'idée est d'utiliser non pas des variables de classe (@@ids) mais des
  # variables d'instances de classe (à ne pas confondre avec les variables d'instance)
  # puisque une classe est aussi un objet en Ruby
  def ids
    @ids ||= 0
  end

  def ids=(number)
    @ids = number
  end

  def new_id
    self.ids = (ids + 1)
  end

  # la méthode all, au lieu d'utiliser une variable de classe telle @@all, dans
  # laquelle on mettrai chaque nouvel instance de Car lors de l'instantiation dans la
  # méthode initialize de Car, utilise ObjectSpace#each_object
  def all
    ObjectSpace.each_object(self).to_a
  end

  def find(id:)
    all.select { |instance| instance.id == id }&.first
  end

  # cette méthode génère dynamiquement les méthodes find_by_TRUC
  def make_attr_finders
    new.public_methods(all = false).each do |meth|
      next if meth.to_s.end_with? "="
      define_singleton_method "find_by_#{meth}" do |arg|
        self.all.select { |instance| instance.send(meth) == arg }
      end
    end
  end

  def self.extended(base)
    puts "#{self} (ClassMethods) a été inclus/étendu dans #{base}"
    puts base.is_a? String
    puts "base.public_methods(all = false): #{base.public_methods(all = false)}"
    puts "base.respond_to? make_attr_finders: #{base.respond_to? :make_attr_finders}"
    # base.send :make_attr_finders
    # puts "base.metaclass: #{base.metaclass}"
    # base.instance_eval do
    #   base.make_attr_finders
    # end
    # eval "#{base}.make_attr_finders"
  end
end

module InstanceMethods
  def self.included(base)
    puts "#{self} (InstanceMethods) a été inclus dans #{base}"
    # si on décommente la ligne suivante, on est toujours obligé de faire Car.make_attr_finders
    # mais en plus, les id commence à 1 au lieu de 0 si l'appel est fait avant les premières instanciations
    # base.make_attr_finders
    # base.send :make_attr_finders
    puts "base.respond_to? make_attr_finders: #{base.respond_to? :make_attr_finders}"
  end

  # attr_accessor :id

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

# GC.start

first_car = Car.new
second_car = Car.new
third_car = Car.new
puts "first_car.id: #{first_car.id}" #=> 1
puts "third_car.id: #{third_car.id}" #=> 3
puts "Car.all: #{Car.all}" #=> [#<Car:0x00000000013f3210 @id=1>, #<Car:0x00000000013f37b0 @id=3>, #<Car:0x00000000013f38a0 @id=2>]
puts "Car.find(id: 3): #{Car.find(id: 3)}" #=>  Car 3
Car.make_attr_finders
puts "Car.find_by_motor('electric'): #{Car.find_by_motor('electric')}"
puts "Car.find_by_id(3): #{Car.find_by_id(3)}" #=>[#<Car:0x000000000200ab70 @id=3>]
# puts first_car.methods(regular=true)

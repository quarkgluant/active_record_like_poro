## Un problème très simple (ou comment faire du rails sans Rails) !

imaginez que vous travaillez avec des PORO (Plain Old Ruby Object) comme ceci :
```ruby
class Car
end
class Bicycle
end
```

Le but du kata est de mimer le comportement d'ActiveRecord sur 2 points:
* créer une méthode `:id` qui permette, pour chaque nouvel objet instancié à
partir de ces classes de lui donner un id unique  
* Plus dur: créer une méthode `:find` telle qu'on puisse l'utiliser ainsi :
```ruby
class Car
  def initialize(super_arguments_super_utiles_ou_rien)
    # ...
  end
# ...
end

class Bicycle
  def initialize(super_arguments_super_utiles_ou_rien)
    # ...
  end
  # ...
end
first_car = Car.new(super_arguments_super_utiles_ou_rien)
second_car = Car.new(super_arguments_super_utiles_ou_rien)
third_car = Car.new(super_arguments_super_utiles_ou_rien)
first_car.id #=> 1
third_car.id #=> 3

Car.find(id: 3) #=> #<Car:0x0000000003bbd458 @id=3>
# ou
Bicycle.find(id: 2)
```
Bien entendu, ~~si vous-même ou l'un des membres de votre équipe était capturé, le Département d'Etat nierait toute 
implication~~ on fait du ~~Canada-~~DRY (ouh-là là je suis en forme dis-donc !), donc pas question de définir ces 2 méthodes 
dans chaque classe, on ne les définit qu'**une seule fois**, par exemple dans un (ou 2) module(s) que vous importerez de
la bonne manière, pour avoir une méthode d'instance (:id) ou une méthode de classe (:find)

Bon, ça c'est fait, alors on continue à faire du ActiveRecord like, maintenant vous allez implémentez les 
[dynamic finders](https://guides.rubyonrails.org/active_record_querying.html#dynamic-finders)  
```ruby
class Car
  def initialize(super_arguments_super_utiles_ou_rien)
    # ...
  end

  def motor
    %w(diesel gazoline electric).sample
    # ...
  end
# ...
end

class Bicycle
  def initialize(super_arguments_super_utiles_ou_rien)
    # ...
  end

  def derailleur
    # ...
  end
  # ...
end
first_car = Car.new(super_arguments_super_utiles_ou_rien)
second_car = Car.new(super_arguments_super_utiles_ou_rien)
third_car = Car.new(super_arguments_super_utiles_ou_rien)


Car.find_by_motor('diesel') #=> [#<Car:0x0000000003bbd458 @id=3>]
```

Bien entendu, vous ne devez **pas** coder en dur ces méthodes de recherche, elles doivent etre créer dynamiquement
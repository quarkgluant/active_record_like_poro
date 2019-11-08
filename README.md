## Un problème très simple (ou comment faire du rails sans Rails) !

imaginez que vous travaillez avec des PORO (Plain Old Ruby Object) comme ceci :
```ruby
class Car
end
class Bicycle
end
```

Le but du kata est de mimer le comportement d'ActiveRecord sur plusieurs points:
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
dans chaque classe, on ne les définit qu'**une seule fois**, par exemple dans un (ou 2 ! spoiler...) module(s) que vous 
importerez de la bonne manière, pour avoir une méthode d'instance (:id) ou une méthode de classe (:find)  
<details>
  <summary>A ne lire qu'après avoir cherché pendant au moins 5 heures :-)</summary>
  
  * pour commencer, vous pouvez coder ces méthodes directement dans la classe Car, on verra après pour les mettre dans des modules  
    * il y a plusieurs façons de procéder, mais commencez avec des variables de classe (mais si vous connaissez, 
     les @@nom_variable)
    * Maintenant, refactorisez en [virant les variables de classes](https://kakesa.net/blog/ruby-pourquoi-eviter-les-variables-de-classes/)
    pour les ids
    * pour la méthode `Car.all` demandez à votre oracle préférer comment connaître toutes les instances d'une classe OU 
    consulter la [doc](https://ruby-doc.org/core-2.6.5/ObjectSpace.html), vu qu'il n'y a que 6 méthodes, trouver la bonne 
    ne devrait pas être trop dur !
    * YAPUKA extraire toutes vos belles méthodes pour les mettre dans des modules, un pour les méthodes d'instances, un 
    autre pour celles de classe et de les importer correctement grâce à **2** méthodes, une pour chacun des modules, que 
    vous trouverez [ici](https://ruby-doc.org/core-2.6.5/Module.html)
</details>  

* Bon, ça c'est fait, alors on continue à faire du ActiveRecord like, maintenant vous allez implémentez les 
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
Pour simplifier, on considérera que toutes les méthodes d'instance concernent des attributs, par exemple on n'aura pas 
ce genre de méthode
```ruby
class Bicycle
  # ...
  def calcul_developpement(rayon_roue, nb_pignons_roue, nb_pignons_pedalier)
  end 
end
end

```
Bien entendu, vous ne devez **pas** coder en dur ces méthodes de recherche, elles doivent etre créer dynamiquement !  

Pour ce faire vous allez avoir besoin de :
* tout d'abord, il vous faut retrouver les méthodes définies sur chaque classe. Heureusement votre meilleur ami est là 
pour vous aider la [doc officielle de Ruby](https://ruby-doc.org/core-2.6.5/Module.html) ! A vous de regarder quelle
méthode ferait cela.  
* maintenant qu'on a les noms des méthodes d'instances, on va itérer dessus, en définissant dynamiquement
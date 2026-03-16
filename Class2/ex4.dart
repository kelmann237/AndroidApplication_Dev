// Abstract base class
abstract class Animal {
  final String name;
  final int legs;

  Animal(this.name, this.legs);

  String makeSound(); // abstract method

  @override
  String toString() => "$name (legs: $legs)";
}

// Concrete subclass: Dog
class Dog extends Animal {
  Dog(String name) : super(name, 4);

  @override
  String makeSound() => "Woof!";
}

// Concrete subclass: Cat
class Cat extends Animal {
  Cat(String name) : super(name, 4);

  @override
  String makeSound() => "Meow!";
}

void main() {
  final List<Animal> animals = [
    Dog("Buddy"),
    Cat("Whiskers"),
  ];

  for (var animal in animals) {
    print("${animal.name} says ${animal.makeSound()}");
  }
}
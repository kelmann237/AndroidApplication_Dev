// Interface (abstract class in Dart)
abstract interface class Drawable {
  void draw();
}

// Circle implementing Drawable
class Circle implements Drawable {
  final int radius;
  Circle(this.radius);

  @override
  void draw() {
    print(" *** ");
    print("*   *");
    print(" *** ");
    print("Circle with radius $radius");
  }
}

// Square implementing Drawable
class Square implements Drawable {
  final int side;
  Square(this.side);

  @override
  void draw() {
    final row = "*" * side;
    print(row);
    for (var i = 0; i < side - 2; i++) {
      print("*${"  " * (side - 1)}*");
    }
    print(row);
    print("Square with side $side");
  }
}

void main() {
  final List<Drawable> shapes = [
    Circle(5),
    Square(4),
  ];

  for (var shape in shapes) {
    shape.draw();
    print(""); // blank line between shapes
  }
}
```


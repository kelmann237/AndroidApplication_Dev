void main() {
  final List<int?> numbers = [1, null, 3, null, 5, 6, null, 8];

  // Step by step
  final nonNulls = numbers.whereType<int>().toList();     // 1. filter nulls
  final doubled  = nonNulls.map((n) => n * 2).toList();   // 2. double each
  final total    = doubled.reduce((a, b) => a + b);        // 3. sum
  print("Sum: $total");

  // One-liner
  final result = numbers
      .whereType<int>()
      .map((n) => n * 2)
      .reduce((a, b) => a + b);
  print("One-liner: $result");
}
```

**Output:**
```
Sum: 46
One-liner: 46
String describeTemperature(int? temp) {
  if (temp == null) return "No data";
  if (temp <= 0)  return "Freezing";
  if (temp <= 15) return "Cold";
  if (temp <= 25) return "Mild";
  if (temp <= 35) return "Warm";
  if (temp <= 45) return "Hot";
  return "Extreme";
}

void main() {
  final List<int?> temperatures = [-5, 10, 20, 30, 40, 50, null, 0, 25];

  for (var temp in temperatures) {
    print("$temp => ${describeTemperature(temp)}");
  }
}
```

**Output:**
```
-5 => Freezing
10 => Cold
20 => Mild
30 => Warm
40 => Hot
50 => Extreme
null => No data
0 => Freezing
25 => Mild
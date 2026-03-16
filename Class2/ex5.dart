// Sealed class (Dart 3.0+)
sealed class NetworkState {}

class Loading extends NetworkState {}

class Success extends NetworkState {
  final String data;
  Success(this.data);
}

class Error extends NetworkState {
  final String message;
  Error(this.message);
}

// Handler using exhaustive switch (pattern matching, Dart 3.0+)
void handleState(NetworkState state) {
  switch (state) {
    case Loading():
      print("Loading...");
    case Success(data: final d):
      print("Success: $d");
    case Error(message: final m):
      print("Error: $m");
  }
}

void main() {
  final states = [
    Loading(),
    Success("User data loaded"),
    Error("Network timeout"),
  ];

  for (var state in states) {
    handleState(state);
  }
}
```

**Output:**
```
Loading...
Success: User data loaded
Error: Network timeout
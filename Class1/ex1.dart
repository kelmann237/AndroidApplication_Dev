class User {
  final String name;
  final String? email;
  User(this.name, this.email);
}

void main() {
  final users = [
    User("Alex", "alex@example.com"),
    User("Blake", null),
    User("Casey", "casey@work.com"),
  ];

  int count = 0;

  for (var user in users) {
    if (user.email != null) {
      print(user.email!.toUpperCase());
      count++;
    } else {
      print("${user.name} has no email");
    }
  }

  print("Total users with valid emails: $count");
}
```

**Output:**
```
ALEX@EXAMPLE.COM
Blake has no email
CASEY@WORK.COM
Total users with valid emails: 2
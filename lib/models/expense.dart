class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  // siapa pemilik expense (username)
  final String owner;

  // daftar username yang ikut berbagi expense ini
  final List<String> sharedWith;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.owner,
    this.sharedWith = const [],
  });

  // Getter tampilan
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  String get formattedDate => '${date.day}/${date.month}/${date.year}';

  // Convert ke JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "amount": amount,
        "category": category,
        "date": date.toIso8601String(),
        "description": description,
        "owner": owner,
        "sharedWith": sharedWith,
      };

  // Convert dari JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["id"],
      title: json["title"],
      amount: (json["amount"] as num).toDouble(),
      category: json["category"],
      date: DateTime.parse(json["date"]),
      description: json["description"],
      owner: json["owner"] ?? '',
      sharedWith: (json["sharedWith"] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

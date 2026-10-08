class Gadget {
  const Gadget({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageAsset;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'description': description,
    'imageAsset': imageAsset,
  };

  factory Gadget.fromJson(Map<String, dynamic> json) => Gadget(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String,
    imageAsset: json['imageAsset'] as String,
  );
}

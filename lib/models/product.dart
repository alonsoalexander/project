// Maps the Product interface from CartContext.tsx and products.ts

class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String image; // emoji string, same as React project
  final String unit;
  final double? organicPrice;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.unit,
    this.organicPrice,
  });

  bool get hasOrganic => organicPrice != null;
}

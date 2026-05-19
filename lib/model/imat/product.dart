// ignore_for_file: constant_identifier_names

enum ProductCategory {
  POD,
  BREAD,
  BERRY,
  CITRUS_FRUIT,
  HOT_DRINKS,
  COLD_DRINKS,
  EXOTIC_FRUIT,
  FISH,
  VEGETABLE_FRUIT,
  CABBAGE,
  MEAT,
  DAIRIES,
  MELONS,
  FLOUR_SUGAR_SALT,
  NUTS_AND_SEEDS,
  PASTA,
  POTATO_RICE,
  ROOT_VEGETABLE,
  FRUIT,
  SWEET,
  HERB,
  UNDEFINED,
}

class Product {
  int productId;
  ProductCategory category;
  String name;
  bool isEcological;
  double price;
  String unit;
  String imageName;

  Product(
    this.productId,
    this.category,
    this.name,
    this.isEcological,
    this.price,
    this.unit,
    this.imageName,
  );

  Product.fromJson(Map<String, dynamic> json)
    : productId = json[_idKey],
      category = _category(json[_catKey]),
      name = json[_nameKey],
      isEcological = json[_ecoKey],
      price = (json[_priceKey] as num).toDouble(),
      unit = json[_unitKey],
      imageName = json[_imageKey];

  Map<String, dynamic> toJson() => {
    _idKey: productId,
    _catKey: category.name,
    _nameKey: name,
    'isEcological': isEcological,
    _priceKey: price,
    _unitKey: unit,
    _imageKey: imageName,
  };

  static const _idKey = 'productId';
  static const _catKey = 'category';
  static const _nameKey = 'name';
  static const _ecoKey = 'ecological';
  static const _priceKey = 'price';
  static const _unitKey = 'unit';
  static const _imageKey = 'imageName';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return productId == (other as Product).productId;
  }

  @override
  int get hashCode => productId.hashCode;
}

ProductCategory _category(String cat) {
  return ProductCategory.values.firstWhere(
    (e) => e.name == cat,
    orElse: () => ProductCategory.UNDEFINED,
  );
}

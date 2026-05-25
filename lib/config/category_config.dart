import 'package:imat/model/imat/product.dart';

/// Grupperade kategorier som visas i menyn.
const Map<String, List<ProductCategory>> kCategoryGroups = {
  'Frukt & Grönt': [
    ProductCategory.FRUIT,
    ProductCategory.BERRY,
    ProductCategory.CITRUS_FRUIT,
    ProductCategory.EXOTIC_FRUIT,
    ProductCategory.MELONS,
    ProductCategory.VEGETABLE_FRUIT,
    ProductCategory.ROOT_VEGETABLE,
    ProductCategory.CABBAGE,
    ProductCategory.HERB,
  ],
  'Mejeri & Bröd': [
    ProductCategory.DAIRIES,
    ProductCategory.BREAD,
  ],
  'Kött & Fisk': [
    ProductCategory.MEAT,
    ProductCategory.FISH,
  ],
  'Skafferi': [
    ProductCategory.PASTA,
    ProductCategory.POTATO_RICE,
    ProductCategory.FLOUR_SUGAR_SALT,
    ProductCategory.NUTS_AND_SEEDS,
    ProductCategory.POD,
    ProductCategory.SWEET,
  ],
  'Dryck': [
    ProductCategory.HOT_DRINKS,
    ProductCategory.COLD_DRINKS,
  ],
};

/// Returnerar gruppnamnet för en produktkategori.
String categoryLabel(ProductCategory cat) {
  for (final entry in kCategoryGroups.entries) {
    if (entry.value.contains(cat)) return entry.key;
  }
  return cat.name;
}

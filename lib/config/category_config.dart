import 'package:imat/model/imat/product.dart';

// ─── Kategori-konfiguration ───────────────────────────────────────────────────
//
// Här redigerar du vilka kategorier som visas i appen och i vilken ordning.
//
// ► Lägg till en kategori:  lägg till en rad i kShownCategories
// ► Ta bort en kategori:    kommentera bort eller ta bort raden
// ► Byt ordning:            flytta raden uppåt/nedåt i listan
// ► Byt visningsnamn:       ändra värdet i kCategoryLabels
//
// Kategorierna hämtas från serverns API. Om en kategori har 0 produkter
// visas den inte automatiskt av ProductsScreen.

/// Vilka kategorier som visas i menyn, i önskad ordning.
/// Kommentera bort en rad för att dölja den kategorin.
const List<ProductCategory> kShownCategories = [
  ProductCategory.FRUIT,
  ProductCategory.BERRY,
  ProductCategory.CITRUS_FRUIT,
  ProductCategory.EXOTIC_FRUIT,
  ProductCategory.MELONS,
  ProductCategory.VEGETABLE_FRUIT,
  ProductCategory.ROOT_VEGETABLE,
  ProductCategory.CABBAGE,
  ProductCategory.HERB,
  ProductCategory.MEAT,
  ProductCategory.FISH,
  ProductCategory.DAIRIES,
  ProductCategory.BREAD,
  ProductCategory.PASTA,
  ProductCategory.POTATO_RICE,
  ProductCategory.FLOUR_SUGAR_SALT,
  ProductCategory.NUTS_AND_SEEDS,
  ProductCategory.POD,
  ProductCategory.HOT_DRINKS,
  ProductCategory.COLD_DRINKS,
  ProductCategory.SWEET,
  // ProductCategory.UNDEFINED,  // dölj "övrigt" — avkommentera vid behov
];

/// Svenska visningsnamn för varje kategori.
const Map<ProductCategory, String> kCategoryLabels = {
  ProductCategory.POD: 'Baljväxter',
  ProductCategory.BREAD: 'Bröd & Bageri',
  ProductCategory.BERRY: 'Bär',
  ProductCategory.CITRUS_FRUIT: 'Citrusfrukter',
  ProductCategory.HOT_DRINKS: 'Varma drycker',
  ProductCategory.COLD_DRINKS: 'Kalla drycker',
  ProductCategory.EXOTIC_FRUIT: 'Exotiska frukter',
  ProductCategory.FISH: 'Fisk & Skaldjur',
  ProductCategory.VEGETABLE_FRUIT: 'Grönsaksfrukter',
  ProductCategory.CABBAGE: 'Kål',
  ProductCategory.MEAT: 'Kött',
  ProductCategory.DAIRIES: 'Mejeri',
  ProductCategory.MELONS: 'Meloner',
  ProductCategory.FLOUR_SUGAR_SALT: 'Mjöl, Socker & Salt',
  ProductCategory.NUTS_AND_SEEDS: 'Nötter & Frön',
  ProductCategory.PASTA: 'Pasta',
  ProductCategory.POTATO_RICE: 'Potatis & Ris',
  ProductCategory.ROOT_VEGETABLE: 'Rotfrukter',
  ProductCategory.FRUIT: 'Frukt',
  ProductCategory.SWEET: 'Godis & Sötsaker',
  ProductCategory.HERB: 'Örter & Kryddor',
  ProductCategory.UNDEFINED: 'Övrigt',
};

/// Hjälpfunktion: returnerar det svenska namnet för en kategori.
String categoryLabel(ProductCategory cat) =>
    kCategoryLabels[cat] ?? cat.name;

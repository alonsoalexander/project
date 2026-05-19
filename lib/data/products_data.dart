import '../models/product.dart';

// Direct port of src/app/data/products.ts — same 20 products, same emoji images

const List<String> categories = [
  'Alla',
  'Frukt & Grönt',
  'Mejeri & Bröd',
  'Kött & Fisk',
  'Skafferi',
  'Dryck',
];

const List<Product> products = [
  Product(id: 1,  name: 'Bananer',      price: 18,  category: 'Frukt & Grönt', image: '🍌', unit: 'kg',   organicPrice: 24),
  Product(id: 2,  name: 'Äpplen',       price: 25,  category: 'Frukt & Grönt', image: '🍎', unit: 'kg',   organicPrice: 32),
  Product(id: 3,  name: 'Tomater',      price: 30,  category: 'Frukt & Grönt', image: '🍅', unit: 'kg',   organicPrice: 38),
  Product(id: 4,  name: 'Gurka',        price: 15,  category: 'Frukt & Grönt', image: '🥒', unit: 'st',   organicPrice: 20),
  Product(id: 5,  name: 'Morötter',     price: 20,  category: 'Frukt & Grönt', image: '🥕', unit: 'kg',   organicPrice: 26),
  Product(id: 6,  name: 'Bröd',         price: 32,  category: 'Mejeri & Bröd', image: '🍞', unit: 'st',   organicPrice: 42),
  Product(id: 7,  name: 'Mjölk',        price: 14,  category: 'Mejeri & Bröd', image: '🥛', unit: 'l',    organicPrice: 19),
  Product(id: 8,  name: 'Ost',          price: 65,  category: 'Mejeri & Bröd', image: '🧀', unit: 'st',   organicPrice: 82),
  Product(id: 9,  name: 'Smör',         price: 48,  category: 'Mejeri & Bröd', image: '🧈', unit: 'st',   organicPrice: 62),
  Product(id: 10, name: 'Yoghurt',      price: 18,  category: 'Mejeri & Bröd', image: '🥛', unit: 'st',   organicPrice: 24),
  Product(id: 11, name: 'Kycklingfilé', price: 89,  category: 'Kött & Fisk',   image: '🍗', unit: 'kg',   organicPrice: 115),
  Product(id: 12, name: 'Lax',          price: 159, category: 'Kött & Fisk',   image: '🐟', unit: 'kg',   organicPrice: 195),
  Product(id: 13, name: 'Köttfärs',     price: 75,  category: 'Kött & Fisk',   image: '🥩', unit: 'kg',   organicPrice: 95),
  Product(id: 14, name: 'Bacon',        price: 55,  category: 'Kött & Fisk',   image: '🥓', unit: 'st',   organicPrice: 72),
  Product(id: 15, name: 'Ägg',          price: 38,  category: 'Mejeri & Bröd', image: '🥚', unit: 'förp', organicPrice: 52),
  Product(id: 16, name: 'Pasta',        price: 22,  category: 'Skafferi',      image: '🍝', unit: 'st',   organicPrice: 28),
  Product(id: 17, name: 'Ris',          price: 28,  category: 'Skafferi',      image: '🍚', unit: 'kg',   organicPrice: 36),
  Product(id: 18, name: 'Tomatpuré',    price: 15,  category: 'Skafferi',      image: '🥫', unit: 'st',   organicPrice: 20),
  Product(id: 19, name: 'Olivolja',     price: 68,  category: 'Skafferi',      image: '🫒', unit: 'st',   organicPrice: 88),
  Product(id: 20, name: 'Juice',        price: 24,  category: 'Dryck',         image: '🧃', unit: 'l',    organicPrice: 32),
];

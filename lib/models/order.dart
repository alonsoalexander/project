import 'cart_item.dart';
import 'user_data.dart';

// Maps the Order interface from CartContext.tsx

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  final UserData userData;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.userData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'userData': userData.toJson(),
      };
}

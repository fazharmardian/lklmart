import 'package:lks_2025/data/models/item.dart';

class CartItem {
  final Item item;
  int quantity;
  double get totalPrice => item.price * quantity;

  CartItem({
    required this.item,
    this.quantity = 1,
  });
}
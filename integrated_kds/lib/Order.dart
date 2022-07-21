import 'dart:ui';
import 'package:integrated_kds/Item.dart';

class Order {
  Order(this.orderNumber, this.quantity, this.bumped, this.items, this.color);

  int orderNumber;
  int quantity;
  bool bumped;
  List<Item> items;
  Color color;
}

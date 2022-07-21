import 'dart:math';

class Item {
  Item(this.name, this.modifiers, this.checked, this.orderBumped,
      this.orderNumber, this.routingGroup, this.key);

  String name;
  List<Object?> modifiers;
  bool checked;
  bool orderBumped;
  int orderNumber;
  String routingGroup;
  String key;

  Item.def()
      : name = "",
        modifiers = [],
        checked = false,
        orderBumped = false,
        orderNumber = 0,
        routingGroup = "",
        key = "0";

  // }

  static List<String> items = [
    "Börger",
    "Pizza",
    "Ramen",
    "Spaghetti",
    "Ice Cream",
    "Chicken"
  ];

  static List<String> routingGroups = ["Dinners", "Drinks", "Lunches"];

  static List<List<String>> modifiersList = [
    ["Mod1", "Mod2", "Mod3"],
    ["Mod4", "Mod5", "Mod6"]
  ];

  static Item generateRandomOrder() {
    Random rand = Random();
    int orderNumber = rand.nextInt(100);
    String name = items[rand.nextInt(items.length)];
    String routingGroup = routingGroups[rand.nextInt(routingGroups.length)];
    List<String> modifiers = modifiersList[rand.nextInt(modifiersList.length)];

    //when order is created it should be active
    bool orderBumped = false;
    bool checked = false;

    return Item(
      name,
      modifiers,
      checked,
      orderBumped,
      orderNumber,
      routingGroup,
      "0",
    );
  }

  static Map<String, dynamic> generateRandomOrderAsMap() {
    Random rand = new Random();
    int orderNumber = rand.nextInt(1000);
    String name = items[rand.nextInt(items.length)];
    String routingGroup = routingGroups[rand.nextInt(routingGroups.length)];
    List<String> modifiers = modifiersList[rand.nextInt(modifiersList.length)];
    //when order is created it should be active
    bool checked = false;
    bool orderBumped = false;

    Map<String, dynamic> map = {
      "name": name,
      "modifiers": [],
      "checked": checked,
      "orderBumped": orderBumped,
      "orderNumber": orderNumber,
      "routingGroup": routingGroup,
    };
    return map;
  }

  static Map<String, dynamic> convertItemToMap(Item item) {
    Map<String, dynamic> map = {
      "name": item.name,
      "modifiers": item.modifiers,
      "checked": item.checked,
      "orderBumped": item.orderBumped,
      "orderNumber": item.orderNumber,
      "routingGroup": item.routingGroup,
    };
    return map;
  }
}

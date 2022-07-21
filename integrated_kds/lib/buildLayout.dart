import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:integrated_kds/menuBar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Item.dart';
import 'Order.dart';

List<Order> orders = <Order>[];
final controller = ScrollController();

class layout extends StatefulWidget {
  bool bumpState = false;
  String group = "";

  layout({Key? key, required this.bumpState, required this.group})
      : super(key: key);

  @override
  State<layout> createState() => _layoutState();
}

class _layoutState extends State<layout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildOrders(),
    );
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref();
  Widget buildOrders() {
    String path = "Merchant/Store1/Items";
    // print(widget.group);
    // print(widget.bumpState);
    return StreamBuilder(
        stream: ref.child(path).onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, Item> items = <String, Item>{};
          if (snapshot.data!.snapshot.value != null) {
            var snap = snapshot.data!.snapshot.value as Map;
            if (snap != null) {
              snap.forEach(
                (key, value) {
                  int orderNumber = value["orderNumber"];
                  String name = value["name"];
                  String routingGroup = value["routingGroup"];
                  List<Object?> modifiers = value["modifiers"];
                  // print(key);
                  // print(routingGroup);
                  bool checked = value["checked"];
                  bool orderBumped = value["orderBumped"];
                  if (bumpState == orderBumped &&
                      widget.group == routingGroup) {
                    Item item = Item(name, modifiers, checked, orderBumped,
                        orderNumber, routingGroup, key);
                    items[key] = item;
                  }
                },
              );
            }
          }

          Map<int, Order> orderMap = {};
          items.forEach((key, value) {
            print(value.name);

            Order? order = orderMap[value.orderNumber];
            if (order == null) {
              // create the order
              List<Item> orderItems = [value];
              order =
                  Order(value.orderNumber, 1, false, orderItems, Colors.blue);
              orderMap[value.orderNumber] = order;
            } else {
              order.bumped = value.orderBumped;
              bool exists = false;
              int itemIndex = -1;
              for (int i = 0; i < order.items.length; i++) {
                if (order.items[i].key == key) {
                  exists = true;
                  itemIndex = i;
                }
              }
              if (exists)
                order.items[itemIndex] = value;
              else
                order.items.add(value);
            }
          });

          orders = [];
          orderMap.forEach((key, value) {
            orders.add(value);
          });

          return buildGridView();
        });
  }

  Widget buildGridView() => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: .75,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        padding: const EdgeInsets.all(4),
        controller: controller,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return buildNumber(orders[index], ref, "Merchant/Store1/Items");
        },
      );
  Widget buildNumber(Order randOrder, DatabaseReference ref, String path) =>
      Container(
        color: Colors.white,
        width: double.infinity,
        height: 350,
        //padding: EdgeInsets.all(5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisSize: MainAxisSize.max,
            //mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(62, 86, 109, 0.32),
                    border: Border.all(
                        color: const Color.fromRGBO(62, 86, 109, 0.32),
                        width: 1.5)),
                //height of info box
                height: 55,
                // width: 700,
                child: GestureDetector(
                  onTap: () {
                    print("hi");
                    randOrder.bumped = !randOrder.bumped;
                    setState(() {
                      for (int i = 0; i < randOrder.items.length; i++) {
                        print(
                            "the index is ${i} and the order is ${randOrder.items[i]}");
                        String key = randOrder.items[i].key;
                        ref
                            .child(path + "/" + key)
                            .update({"orderBumped": randOrder.bumped});
                      }
                    });

                    // _changeBumped(randOrder);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer_sharp,
                                    size: 15,
                                    color: Color.fromRGBO(82, 82, 82, 1)),
                                Text(
                                  //clock countdown
                                  '18:43',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      textStyle: const TextStyle(
                                          color:
                                              Color.fromRGBO(82, 82, 82, 1))),
                                ),
                              ],
                            ),
                            Text(
                              //order number
                              'Order: ${randOrder.orderNumber.toString()}',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  textStyle: const TextStyle(
                                      color: Color.fromRGBO(82, 82, 82, 1))),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.notification_add_outlined,
                                    size: 15,
                                    color: Color.fromRGBO(82, 82, 82, 1)),
                                Text(
                                  'Dine In',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      textStyle: const TextStyle(
                                          color:
                                              Color.fromRGBO(82, 82, 82, 1))),
                                ),
                              ],
                            ),
                            Text(
                              'User: Nathan',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  textStyle: const TextStyle(
                                      color: Color.fromRGBO(82, 82, 82, 1))),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                //eventually want to have random color here
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),

                  child: Column(children: <Widget>[
                    for (int i = 0; i < randOrder.items.length; i++)
                      Container(
                        decoration: BoxDecoration(
                            color: (randOrder.items[i].checked)
                                ? const Color(0xffEFEFF0)
                                : Colors.white,
                            border: const Border(
                                bottom: BorderSide(
                                    width: 1.5, color: Color(0xffEFEFF0)))),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      randOrder.items[i].name,
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
                                    ),
                                    Checkbox(
                                      //changes checkbox background
                                      activeColor: const Color(0xffEFEFF0),
                                      //just changes checkmarl color
                                      checkColor: Colors.green,
                                      value: randOrder.items[i].checked,
                                      onChanged: (bool? value) {
                                        setState(
                                          () {
                                            randOrder.items[i].checked = value!;
                                            String key = randOrder.items[i].key;
                                            ref.child(path + "/" + key).update({
                                              "checked":
                                                  randOrder.items[i].checked
                                            });
                                            if (randOrder.items[i].checked) {
                                              bool allChecked = true;
                                              for (int k = 0;
                                                  k < randOrder.items.length;
                                                  k++) {
                                                if (randOrder
                                                        .items[k].checked ==
                                                    false) {
                                                  allChecked = false;
                                                }
                                              }
                                              if (allChecked) {
                                                // _changeBumped(randOrder);
                                                for (int i = 0;
                                                    i < randOrder.items.length;
                                                    i++) {
                                                  String key =
                                                      randOrder.items[i].key;
                                                  ref
                                                      .child(path + "/" + key)
                                                      .update({
                                                    "orderBumped": true
                                                  });
                                                }
                                              }
                                            }
                                          },
                                        );
                                      },
                                    ), //Checkb
                                  ]),
                              Column(
                                children: <Widget>[
                                  // Spacer(),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 0)),
                                  for (int j = 0;
                                      j < randOrder.items[i].modifiers.length;
                                      j++)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        child: Text(
                                          '          ${randOrder.items[i].modifiers[j]}',
                                          style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                  ]),

                  // Row(
                  //
                ), //Column
                //SizedBox
              ), //Padding
            ]),
      );
}

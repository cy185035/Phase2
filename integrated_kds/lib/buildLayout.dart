import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:integrated_kds/menuBar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Item.dart';
import 'Order.dart';

List<Order> orders = <Order>[];
final controller = ScrollController();
String path = "Merchant/Store1/Orders";
late Item item;

String twoDigits(int n) => n.toString().padLeft(2, '0');

class layout extends StatefulWidget {
  bool bumpState = false;
  String group = "";

  layout({Key? key, required this.bumpState, required this.group})
      : super(key: key);

  @override
  State<layout> createState() => _layoutState();
}

class _layoutState extends State<layout> {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  Timer? timer;
  Duration duration = Duration();
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      setState(() {});
    });
    super.initState();

    startTimer();
  }

  @override
  void dispose() {
    // timer?.cancel();

    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = 1;
    // UNCOMMENT TO ADD TIMER FUNCTIONALITY
    // setState(() {
    //   final seconds = duration.inSeconds + addSeconds;
    //   duration = Duration(seconds: seconds);
    //   dateTime = DateTime.now();
    // });
  }

  @override
  Widget build(BuildContext context) {
    print("building");
    return Scaffold(
      body: buildOrders(),
    );
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Widget buildOrders() {
    return StreamBuilder(
        stream: ref.child(path).onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("LOADING...");
            return const Center(child: CircularProgressIndicator());
          }

          orders = [];
          if (snapshot.data!.snapshot.value != null) {
            var snap = snapshot.data!.snapshot.value as Map;
            // print(snap);
            if (snap != null) {
              snap.forEach(
                (key, value) {
                  int orderNumber = value["orderNumber"];
                  bool bumped = value["bumped"];
                  int time = value["time"];
                  List<Item> items = <Item>[];

                  value["items"].forEach((itemObject) {
                    if (itemObject["routingGroup"] == widget.group) {
                      items.add(Item(
                          itemObject["name"],
                          itemObject["modifiers"],
                          itemObject["checked"],
                          itemObject["bumped"],
                          itemObject["orderNumber"],
                          itemObject["routingGroup"],
                          key));
                    }
                  });

                  if (bumpState == bumped) {
                    if (items.isNotEmpty) {
                      // print(items[0].name);
                      Order order = Order(
                          orderNumber, bumped, items, Colors.grey, time, key);
                      orders.add(order);
                    }
                  }
                },
              );
            }
          }
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
          return buildNumber(orders, index, ref, path);
        },
      );

  Widget buildNumber(
      List<Order> orders, int index, DatabaseReference ref, String path) {
    if (orders.isEmpty) {
      return Container();
    }
    Order randOrder = orders[index];
    Duration duration = dateTime
        .difference(DateTime.fromMillisecondsSinceEpoch(randOrder.time * 1000));

    return Container(
      color: Colors.white,
      width: double.infinity,
      height: 350,
      //padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                randOrder.bumped = !randOrder.bumped;
                setState(() {
                  String key = (randOrder).key;
                  ref.child("$path/$key").update({"bumped": randOrder.bumped});
                  orders.remove(randOrder);
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
                                size: 15, color: Color.fromRGBO(82, 82, 82, 1)),
                            Text(
                              //clock countdown
                              '${twoDigits(duration.inMinutes.remainder(60))} : ${twoDigits(duration.inSeconds.remainder(60))}',
                              // '${dr}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  textStyle: const TextStyle(
                                      color: Color.fromRGBO(82, 82, 82, 1))),
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
                                size: 15, color: Color.fromRGBO(82, 82, 82, 1)),
                            Text(
                              'Dine In',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  textStyle: const TextStyle(
                                      color: Color.fromRGBO(82, 82, 82, 1))),
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

              child: Column(
                children: <Widget>[
                  for (int i = 0; i < randOrder.items.length; i++)
                    Container(
                      decoration: BoxDecoration(
                          color: ((randOrder.items[i]).checked)
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  (randOrder.items[i]).name,
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                Checkbox(
                                  //changes checkbox background
                                  activeColor: const Color(0xffEFEFF0),
                                  //just changes checkmarl color
                                  checkColor: Colors.green,
                                  value: (randOrder.items[i]).checked,
                                  onChanged: (bool? value) {
                                    print(value);
                                    setState(
                                      () {
                                        (randOrder.items[i]).checked = value!;
                                        String key = (randOrder).key;
                                        ref
                                            .child("$path/$key/items/$i")
                                            .update({
                                          "checked":
                                              (randOrder.items[i]).checked
                                        });
                                        if ((randOrder.items[i]).checked) {
                                          bool allChecked = true;
                                          for (int k = 0;
                                              k < randOrder.items.length;
                                              k++) {
                                            if ((randOrder.items[k]).checked ==
                                                false) {
                                              allChecked = false;
                                              break;
                                            }
                                          }
                                          if (allChecked) {
                                            // _changeBumped(randOrder);
                                            String key = (randOrder).key;
                                            ref
                                                .child("$path/$key")
                                                .update({"bumped": true});
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                // Spacer(),
                                const Padding(
                                    padding: EdgeInsets.only(left: 0)),
                                for (int j = 0;
                                    j < (randOrder.items[i]).modifiers.length;
                                    j++)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      child: Text(
                                        '          ${(randOrder.items[i]).modifiers[j]}',
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
                ],
              ),

              // Row
            ), //Column
            //SizedBox
          ), //Padding
        ],
      ),
    );
  }
}

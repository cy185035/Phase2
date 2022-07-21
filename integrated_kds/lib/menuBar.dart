import 'package:flutter/material.dart';
import 'buildLayout.dart';

bool bumpState = false;
List<String> groups = ['Dinners', 'Drinks', 'Lunches'];
String dropDownValue = groups[0];

class myAppBar extends StatefulWidget with PreferredSizeWidget {
  String title = "";

  myAppBar({Key? key, required this.title}) : super(key: key);

  @override
  State<myAppBar> createState() => _myAppBarState();
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _myAppBarState extends State<myAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            const Padding(padding: EdgeInsets.only(left: 20)),
            const Text(
              'Kitchen',
              style: TextStyle(color: Colors.black),
            ),
            const Padding(padding: EdgeInsets.only(left: 20)),
            GestureDetector(
              onTap: () {
                if (!bumpState) {
                  bumpState = true;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: myAppBar(title: "Bumped"),
                        body: layout(
                          bumpState: bumpState,
                          group: dropDownValue.toString(),
                        ),
                        bottomNavigationBar: MyBottomBar(),
                      ),
                    ),
                  );
                } else {
                  bumpState = false;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: myAppBar(title: "Active"),
                        body: layout(
                          bumpState: bumpState,
                          group: dropDownValue.toString(),
                        ),
                        bottomNavigationBar: MyBottomBar(),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const Padding(padding: const EdgeInsets.only(left: 20)),
            Text(
              "Orders: ${orders.length}",
              style: TextStyle(color: Colors.black),
            ),
            const Padding(padding: const EdgeInsets.only(left: 200)),
            Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "9:08",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      "pm",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        centerTitle: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.format_list_bulleted_outlined,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.cloud_outlined,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: DropdownButton<String>(
                items: groups.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropDownValue,
                onChanged: (e) {
                  setState(() {
                    dropDownValue = e!;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: myAppBar(title: widget.title),
                        body: layout(
                          bumpState: bumpState,
                          group: dropDownValue.toString(),
                        ),
                        bottomNavigationBar: MyBottomBar(),
                      ),
                    ),
                  );
                },
              ))
        ]);
  }
}

class MyBottomBar extends BottomAppBar {
  MyBottomBar()
      : super(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.arrow_left_sharp,
                color: Colors.white,
                size: 35,
              ),
              Icon(
                Icons.circle,
                color: Colors.white,
                size: 15,
              ),
              Icon(
                Icons.square,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        );
}

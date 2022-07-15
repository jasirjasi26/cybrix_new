// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllProductPage extends StatefulWidget {
  AllProductPage({Key key, this.back}) : super(key: key);

  final bool back;

  @override
  AllProductPageState createState() => AllProductPageState();
}

class AllProductPageState extends State<AllProductPage> {
  var name=TextEditingController();
  DatabaseReference items;
  List<String> names = [];
  List<String> id = [];
  List<String> unit = [];
  List<String> salerate = [];
  List<String> purchaserate = [];
  List<String> stock = [];

  Future<void> getCustomerId(String a) async {
    setState(() {
      names.clear();
      id.clear();
      unit.clear();
      salerate.clear();
      purchaserate.clear();
      stock.clear();
    });

    await items.once().then((DataSnapshot snapshot) {
      List<dynamic> values = snapshot.value;
      for (int i = 0; i < values.length; i++) {
        if (values[i] != null) {
          if(values[i]['ItemName'].toString().toLowerCase().contains(name.text.toLowerCase())) {
            setState(() {
              names.add(values[i]['ItemName'].toString());
              id.add(values[i]['ItemID'].toString());
              unit.add(values[i]['SaleUnit'].toString());
              salerate.add(values[i]['RateAndStock'][values[i]['SaleUnit']
                  .toString()]['Rate'].toString());
              purchaserate.add(values[i]['RateAndStock'][values[i]['SaleUnit']
                  .toString()]['PurchaseRate'].toString());
              stock.add(values[i]['RateAndStock'][values[i]['SaleUnit']
                  .toString()]['Stock'][int.parse(User.vanNo)].toString());
            });
          }

        }
      }
    });
  }

  void initState() {
    // TODO: implement initState

    items = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database)
        .child("Items");

    getCustomerId("1");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: WillPopScope(
        onWillPop: () async {
          return widget.back;
        },
        child: ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            searchRow(),
            SizedBox(
              height: 10,
            ),
            homeData()
          ],
        ),
      ),
    );
  }

  searchRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left:15.0,right: 15),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: const Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(6, 3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: TextFormField(
                   controller: name,
                  onChanged: getCustomerId,
                  decoration: InputDecoration(
                hintText: 'Enter product name here',
                //filled: true,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 5, top: 15, right: 15),
                filled: false,
                isDense: false,
                prefixIcon: Icon(
                  Icons.search,
                  size: 25.0,
                  color: Colors.grey,
                ),
              )),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 8.0, right: 8),
          //   child: Column(
          //     children: [
          //       Spacer(),
          //       Container(
          //           height: 25,
          //           width: 25,
          //           child: Image.asset(
          //             "assets/images/filter.png",
          //             fit: BoxFit.scaleDown,
          //             //    color: Colors.white
          //           )),
          //       Spacer(),
          //       Text("Filter")
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 8.0, right: 8),
          //   child: Column(
          //     children: [
          //       Spacer(),
          //       Container(
          //           height: 30,
          //           width: 30,
          //           child: Image.asset(
          //             "assets/images/scan.png",
          //             fit: BoxFit.scaleDown,
          //             //    color: Colors.white
          //           )),
          //       Spacer(),
          //       Text("Scan")
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  homeData() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GridView.builder(
            itemCount: names.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                height: 180,
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  children: [
                    Card(
                      child: Container(
                          height: MediaQuery.of(context).size.width / 3 - 30,
                          width: MediaQuery.of(context).size.width / 3 - 30,
                          child: Image.asset(
                            "assets/images/cybrix logo.png",
                            fit: BoxFit.scaleDown,
                            //    color: Colors.white
                          )),
                    ),
                    Container(
                      height: 80,
                      child: Column(
                        children: [
                          Text(
                            names[index],
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 10,
                              color: const Color(0xff182d66),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Code: '+id[index],
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 8,
                                  color: const Color(0xff182d66),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 8,
                                    color: const Color(0xff182d66),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Unit: '+unit[index]+'\nIn Stock: '+stock[index],
                                    ),
                                  ],
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 8,
                                    color: const Color(0xff182d66),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sale Rate: ',
                                    ),
                                    TextSpan(
                                      text: salerate[index],
                                      style: TextStyle(
                                        color: const Color(0xff388e3c),
                                      ),
                                    ),
                                  ],
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 8,
                                    color: const Color(0xff182d66),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Purchase Rate:',
                                    ),
                                    TextSpan(
                                      text: purchaserate[index],
                                      style: TextStyle(
                                        color: const Color(0xff388e3c),
                                      ),
                                    ),
                                  ],
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      centerTitle: false,
      title: Text("Products"),
      elevation: 1.0,
      titleSpacing: 0,
      toolbarHeight: 70,
    );
  }
}

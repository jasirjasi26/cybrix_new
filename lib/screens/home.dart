// @dart=2.9
import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cybrix/data/getVouchers.dart';
import 'package:cybrix/data/refresh.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/reciept_portal.dart';
import 'package:cybrix/screens/returns/sales_returns.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import '../ui_elements/main_drawer.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'orders.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseReference reference;
  DatabaseReference items;
  String today = DateTime.now().year.toString() +
      "-" +
      DateTime.now().month.toString() +
      "-" +
      DateTime.now().day.toString();
  int todaysPending = 0;
  int todaysOrders = 0;
  double totalSales = 0;
  double totalStocks = 0;
  DatabaseReference names;
  List<String> _locations = []; // Opt
  DatabaseReference types; // Opt
  List<double> data = [];
  String selected = "day";

  getDetails() async {
    String db=User.database;
    String url =
         "https://cybrixproject1-default-rtdb.firebaseio.com/Companies/$db/DefaultSettings/Decimal.json";


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var json=jsonDecode(response.body);
      setState(() {
        User.decimals= int.parse(json['Sales']);
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt("decimal",User.decimals);

      print(User.decimals);
    } else {
      print("Failed");
    }
  }

  getChart(String select) async {
    setState(() {
      data.clear();
    });

    if (selected == "day") {
      await reference
          .child("SalesReport")
          .child(today)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          setState(() {
            data.add(double.parse(values["GrandAmount"]));
          });
        });
      });

    } else if (selected == "week") {
      for (int i = 0; i < 7; i++) {
        DateTime a = DateTime.now().subtract(new Duration(days: i));
        String c = a.year.toString() +
            "-" +
            a.month.toString() +
            "-" +
            a.day.toString();

        double value = 0;
        await reference
            .child("SalesReport")
            .child(c)
            .once()
            .then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          if (values != null) {
            values.forEach((key, values) {
              setState(() {
                value = value + double.parse(values["GrandAmount"]);
              });
            });
          }
        });

        setState(() {
          data.add(value);
        });
      }
    }

    else if (selected == "month") {
      for (int i = 0; i < 30; i++) {
        DateTime a = DateTime.now().subtract(new Duration(days: i));
        String c = a.year.toString() +
            "-" +
            a.month.toString() +
            "-" +
            a.day.toString();

        double value = 0;
        await reference
            .child("SalesReport")
            .child(c)
            .once()
            .then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          if (values != null) {
            values.forEach((key, values) {
              setState(() {
                value = value + double.parse(values["GrandAmount"]);
              });
            });
          }
        });

        setState(() {
          data.add(value);
        });
      }
    }
  }

  Future<void> getSalesTypes() async {
    await types.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        _locations.add(values["Name"].toString());
      });
    });
  }




  Future<void> getOrders() async {
    setState(() {
      totalSales = 0;
      todaysPending = 0;
      totalStocks = 0;
      todaysOrders = 0;
    });

    await reference.child("Stocks").once().then((DataSnapshot snapshot) {
      List<dynamic> values = snapshot.value;
      if (snapshot.value != null) {
        for (int i = 0; i < values.length; i++) {
          if (values[i] != null) {
            setState(() {
              totalStocks =
                  totalStocks + double.parse(values[i]['Stock']['All']);
            });
          }
        }
      }
    });

    await reference
        .child("Order")
        .child(today)
        .child(User.vanNo)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null) {
        if (values.length > 0) {
          setState(() {
            todaysPending = values.length;
          });
        }
      }
    });

    await reference
        .child("Bills")
        .child(today)
        .child(User.vanNo)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null) {
        if (values.length > 0) {
          setState(() {
            todaysOrders = values.length + todaysPending;
          });
        }
      } else {
        setState(() {
          todaysOrders = todaysPending;
        });
      }
    });

    await reference
        .child("SalesReport")
        .child(today)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() {
          totalSales = totalSales + double.parse(values["GrandAmount"]);
        });
      });
    });

  }

  void initState() {
    // TODO: implement initState
    getDetails();
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);

    types = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database)
        .child("SalesTypes");

    names = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database)
        .child("Customers");
    items = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database)
        .child("Items");

    GetVouchers().getVouchers();
    getChart("day");
    getOrders();
    getSalesTypes();
    Refresh().refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MainDrawer(),
      appBar: buildAppBar(context),
      body: WillPopScope(
        onWillPop: () async {
          // You can do some work here.
          // Returning true allows the pop to happen, returning false prevents it.
          return false;
        },
        child: RefreshIndicator(
          onRefresh: getOrders,
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              homeBox(),
              SizedBox(
                height: 20,
              ),
              diffBox(),
              SizedBox(
                height: 20,
              ),
              overViewBox()
            ],
          ),
        ),
      ),
    );
  }

  homeBox() {
    return Column(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.37,
                    width: MediaQuery.of(context).size.width * 0.37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -2.47),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xffeeedf3),
                          const Color(0xff845cfd)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x29000000),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(9999.0, 9999.0)),
                                  color: const Color(0xffffffff),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x29000000),
                                      offset: Offset(6, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                        "assets/images/sale.png",
                                        fit: BoxFit.scaleDown,
                                        //    color: Colors.white
                                      )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                totalSales.toStringAsFixed(User.decimals),
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 22,
                                  color: const Color(0xffffffff),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Total Sales',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 15,
                                  color: const Color(0xffffffff),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     'Tap to view',
                            //     style: TextStyle(
                            //       fontFamily: 'Segoe UI',
                            //       fontSize: 10,
                            //       color: const Color(0xffffffff),
                            //     ),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.37,
                    width: MediaQuery.of(context).size.width * 0.37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -2.47),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xfff3ceef),
                          const Color(0xfffa4de7)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x29000000),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(9999.0, 9999.0)),
                                  color: const Color(0xffffffff),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x29000000),
                                      offset: Offset(6, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                        "assets/images/pending.png",
                                        fit: BoxFit.scaleDown,
                                        //    color: Colors.white
                                      )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                todaysPending.toString(),
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 22,
                                  color: const Color(0xffffffff),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Pending Orders',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 15,
                                  color: const Color(0xffffffff),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     'Tap to view',
                            //     style: TextStyle(
                            //       fontFamily: 'Segoe UI',
                            //       fontSize: 10,
                            //       color: const Color(0xffffffff),
                            //     ),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.37,
                    width: MediaQuery.of(context).size.width * 0.37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -2.47),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xffddebf0),
                          const Color(0xff22bef1)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x29000000),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(9999.0, 9999.0)),
                                  color: const Color(0xffffffff),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x29000000),
                                      offset: Offset(6, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                        "assets/images/in_stock.png",
                                        fit: BoxFit.scaleDown,
                                        //    color: Colors.white
                                      )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                totalStocks.toStringAsFixed(0),
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 22,
                                  color: const Color(0xffffffff),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Available Stock',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 15,
                                  color: const Color(0xffffffff),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     'Tap to view',
                            //     style: TextStyle(
                            //       fontFamily: 'Segoe UI',
                            //       fontSize: 10,
                            //       color: const Color(0xffffffff),
                            //     ),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.37,
                    width: MediaQuery.of(context).size.width * 0.37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -2.47),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xfffae7cb),
                          const Color(0xfff9a936)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x29000000),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(9999.0, 9999.0)),
                                  color: const Color(0xffffffff),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x29000000),
                                      offset: Offset(6, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                        "assets/images/order_now.png",
                                        fit: BoxFit.scaleDown,
                                        //    color: Colors.white
                                      )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                todaysOrders.toString(),
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 22,
                                  color: const Color(0xffffffff),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Todays Order',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 15,
                                  color: const Color(0xffffffff),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     'Tap to view',
                            //     style: TextStyle(
                            //       fontFamily: 'Segoe UI',
                            //       fontSize: 10,
                            //       color: const Color(0xffffffff),
                            //     ),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  diffBox() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = "day";
                  });
                  getChart(selected);
                },
                child: Container(
                    width: 80,
                    height: 25,
                    decoration: BoxDecoration(
                      color: selected == "day"
                          ? Colors.blue[900]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: Text(
                      "Day",
                      style: TextStyle(
                          color: selected == "day" ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w900),
                    ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = "week";
                  });
                  getChart(selected);
                },
                child: Container(
                    width: 80,
                    height: 25,
                    decoration: BoxDecoration(
                      color: selected == "week"
                          ? Colors.blue[900]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: Text(
                      "Week",
                      style: TextStyle(
                          color:
                              selected == "week" ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w900),
                    ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = "month";
                  });
                  getChart(selected);
                },
                child: Container(
                    width: 80,
                    height: 25,
                    decoration: BoxDecoration(
                      color: selected == "month"
                          ? Colors.blue[900]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: Text(
                      "Month",
                      style: TextStyle(
                          color:
                              selected == "month" ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w900),
                    ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = "year";
                  });
                  getChart(selected);
                },
                child: Container(
                    width: 80,
                    height: 25,
                    decoration: BoxDecoration(
                      color: selected == "year"
                          ? Colors.blue[900]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: Text(
                      "Year",
                      style: TextStyle(
                          color:
                              selected == "year" ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w900),
                    ))),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              // image: DecorationImage(
              //   image: AssetImage('assets/images/chart.png'),
              //   fit: BoxFit.cover,
              // ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(6, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: data.length > 0
                  ? SfSparkLineChart(
                      color: Colors.blueGrey,
                      width: 5,
                      axisLineColor: Colors.white,
                      //Enable the trackball
                      trackball: SparkChartTrackball(
                          activationMode: SparkChartActivationMode.tap),
                      //Enable marker
                      marker: SparkChartMarker(
                          displayMode: SparkChartMarkerDisplayMode.all),
                      //Enable data label
                      labelDisplayMode: SparkChartLabelDisplayMode.all,
                      data: data)
                  : Center(
                      child: Text("No data..."),
                    ),
            ))
      ],
    );
  }

  overViewBox() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 30,
              height: 50,
            ),
            Text(
              'Overview',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 22,
                color: const Color(0xff5b5b5b),
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return OrdersPage();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(6, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Color(0xffcfbfff),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x29000000),
                              offset: Offset(6, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/images/order_list.png',
                            color: Colors.black,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      " Order List",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5),
                  child: Row(
                    children: [
                      Text(
                        "Tap to view",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Spacer(),
                      // Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(15.0),
                      //       color: Colors.green,
                      //     ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(
                      //           left: 10.0, right: 10, top: 3, bottom: 3),
                      //       child: Center(
                      //         child: Text(
                      //           todaysPending.toString(),
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 14),
                      //         ),
                      //       ),
                      //     )),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ReturnsPage();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(6, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Color(0xcfa8ebab),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x29000000),
                              offset: Offset(6, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/images/sales_return.png',
                            color: Colors.black,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      " Sales Return",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5),
                  child: Row(
                    children: [
                      Text(
                        "Tap to view",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Spacer(),
                      // Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(15.0),
                      //       color: Colors.green,
                      //     ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(
                      //           left: 10.0, right: 10, top: 3, bottom: 3),
                      //       child: Center(
                      //         child: Text(
                      //           "256",
                      //           style:
                      //               TextStyle(color: Colors.white, fontSize: 16),
                      //         ),
                      //       ),
                      //     )),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return RecieptPortal();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(6, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Color(0xfff5ddbb),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x29000000),
                              offset: Offset(6, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/images/reciept_portal.png',
                            color: Colors.black,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      " Receipt Portal",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5),
                  child: Row(
                    children: [
                      Text(
                        "Tap to view",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Spacer(),
                      // Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(15.0),
                      //       color: Colors.green,
                      //     ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(
                      //           left: 10.0, right: 10, top: 3, bottom: 3),
                      //       child: Center(
                      //         child: Text(
                      //           "256",
                      //           style:
                      //               TextStyle(color: Colors.white, fontSize: 16),
                      //         ),
                      //       ),
                      //     )),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Container(
            height: 20,
            width: 40,
            child: Image.asset(
              'assets/images/person.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Center(
            child: Text(
          User.name.toString(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        )),
        SizedBox(
          width: 15,
        ),
      ],
      leading: Container(
        child: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState.openDrawer();
          },
          child: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              child: Container(
                child: Image.asset(
                  'assets/images/homebox.png',
                  height: 30,
                  width: 30,
                  //color: MyTheme.dark_grey,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
      elevation: 1.0,
      titleSpacing: 0,
      toolbarHeight: 70,
    );
  }
}

// @dart=2.9
import 'dart:convert';
import 'package:adobe_xd/page_link.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cybrix/data/getCustomerDetails.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/all_products.dart';
import 'package:cybrix/screens/home.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:textfield_search/textfield_search.dart';
import '../models/saletypes.dart';
import '../screens/newOrderPage.dart';

class BottomBar extends StatefulWidget {
  @override
  BottomBarState createState() => BottomBarState();
}


class BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  List<String> _locations = []; // Option 2
  String _selectedLocation="[None]"; // Opt
  final _children = [MyHomePage(), AllProductPage(), Container(), Container()];
  DatabaseReference types;
  DatabaseReference names;
  DatabaseReference reference;
  String label = "Enter Customer Name";

  void onTapped(int i) {
    if (i != 3) {
      setState(() {
        _currentIndex = i;
      });
    }
  }

  Future<void> authenticate(String text) async {

    var isCacheExist = await APICacheManager().isAPICacheKeyExist("customers");

    if (!isCacheExist) {
      await names.once().then((DataSnapshot snapshot) async {
        Map<dynamic, dynamic> values = snapshot.value;
        APICacheDBModel cacheDBModel =
        new APICacheDBModel(key: "customers", syncData: jsonEncode(values));
        await APICacheManager().addCacheData(cacheDBModel);
        var cacheData = await APICacheManager().getCacheData("customers");

        jsonDecode(cacheData.syncData).forEach((key, values) {
          if (text == values["Name"]) {
            GetCustomerDetails().getCustomerId(text).whenComplete(() => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return NewOrderPage(customerName: text,refNo: "0",salesType: _selectedLocation,);
                  }))
            });
          } else {
            if (text == values["CustomerCode"]) {
              GetCustomerDetails().getCustomerId(text).whenComplete(() => {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) {
              return NewOrderPage(customerName: text,refNo: "0",salesType: _selectedLocation,);
              }))
              });

            }
          }
        });
      });
    }else{
      var cacheData = await APICacheManager().getCacheData("customers");

      jsonDecode(cacheData.syncData).forEach((key, values) {
        if (text == values["Name"]) {
          GetCustomerDetails().getCustomerId(text).whenComplete(() => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return NewOrderPage(customerName: text,refNo: "0",salesType: _selectedLocation,);
                }))
          });
        } else {
          if (text == values["CustomerCode"]) {
            GetCustomerDetails().getCustomerId(text).whenComplete(() => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return NewOrderPage(customerName: text,refNo: "0",salesType: _selectedLocation,);
                  }))
            });
          }
        }
      });
    }


  }

  Future<List> getNames(String input) async {
    List _list = new List();

    var isCacheExist = await APICacheManager().isAPICacheKeyExist("customers");

    if (await DataConnectionChecker().hasConnection) {
      await names.once().then((DataSnapshot snapshot) async {
        Map<dynamic, dynamic> values = snapshot.value;
        APICacheDBModel cacheDBModel =
        new APICacheDBModel(key: "customers", syncData: jsonEncode(values));
        await APICacheManager().addCacheData(cacheDBModel);
        var cacheData = await APICacheManager().getCacheData("customers");

        jsonDecode(cacheData.syncData).forEach((key, values) {
          if(values['Name'].toString().toLowerCase().contains(input.toLowerCase())){
            _list.add(values['Name'].toString());
          }
          if(values['CustomerCode'].toString().toLowerCase().contains(input.toLowerCase())){
            _list.add(values['CustomerCode'].toString());
          }
        });
      });
    }else{
      var cacheData = await APICacheManager().getCacheData("customers");

      jsonDecode(cacheData.syncData).forEach((key, values) {
        if(values['Name'].toString().toLowerCase().contains(input.toLowerCase())){
          _list.add(values['Name'].toString());
        }
        if(values['CustomerCode'].toString().toLowerCase().contains(input.toLowerCase())){
          _list.add(values['CustomerCode'].toString());
        }
      });
    }
    return _list;
  }


  Future<void> getSalesTypes() async {

    if(await DataConnectionChecker().hasConnection){
      await types.once().then((DataSnapshot snapshot) async {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          _locations.add(values["Name"].toString());
        });


        APICacheDBModel cacheDBModel =
        new APICacheDBModel(key: "salestypes", syncData: jsonEncode(snapshot.value));
        await APICacheManager().addCacheData(cacheDBModel);
      });
    }
    else{
        var cacheData = await APICacheManager().getCacheData("salestypes");
        jsonDecode(cacheData.syncData).forEach((key, values) {
          _locations.add(values["Name"].toString());
        });
    }
  }


  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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

    getSalesTypes();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _children[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          showBookingDialog();
        },
        child: Container(
          width: 80,
          height: 80,
          child: Stack(
            children: <Widget>[
              Pinned.fromPins(
                Pin(start: 0.0, end: 0.0),
                Pin(start: 0.0, end: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                    gradient: LinearGradient(
                      begin: Alignment(-2.74, -2.92),
                      end: Alignment(0.73, 0.78),
                      colors: [
                        const Color(0xffffffff),
                        const Color(0xff1f3877)
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
                ),
              ),
              Pinned.fromPins(
                Pin(size: 18.6, middle: 0.4153),
                Pin(size: 24.2, middle: 0.3096),
                child:
                    // Adobe XD layer: 'surface1' (group)
                    Stack(
                  children: <Widget>[
                    Pinned.fromPins(
                      Pin(start: 0.0, end: 0.0),
                      Pin(start: 0.0, end: 0.0),
                      child: Image.asset(
                        'assets/images/new.png',
                        //color: Colors.blue,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ],
                ),
              ),
              Pinned.fromPins(
                Pin(size: 16.0, middle: 0.6667),
                Pin(size: 16.0, middle: 0.5926),
                child: Stack(
                  children: <Widget>[
                    Pinned.fromPins(
                      Pin(start: 0.0, end: 0.0),
                      Pin(start: 0.0, end: 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.elliptical(9999.0, 9999.0)),
                          color: const Color(0xff1d336c),
                        ),
                      ),
                    ),
                    Pinned.fromPins(
                      Pin(size: 31.0, middle: 0.4571),
                      Pin(size: 78.0, middle: 0.8039),
                      child: Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(start: 0.0, end: 0.0),
                            child: Image.asset(
                              'assets/images/add.png',
                              //color: Colors.transparent,
                              fit: BoxFit.cover,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Pinned.fromPins(
                Pin(size: 31.0, middle: 0.4571),
                Pin(size: 8.0, middle: 0.8039),
                child: Text(
                  'New Order',
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 8,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: onTapped,
            currentIndex: _currentIndex,
            backgroundColor: Colors.white.withOpacity(0.9),
            fixedColor: Theme.of(context).accentColor,
            unselectedItemColor: Color.fromRGBO(153, 153, 153, 1),
            items: [
              BottomNavigationBarItem(
                label: "Home",
                  icon: Image.asset(
                    "assets/images/home_icon.png",
                    color: _currentIndex == 0
                        ? Colors.cyan[800]
                        : Color.fromRGBO(153, 153, 153, 1),
                    height: 20,
                  ),
              ),
              BottomNavigationBarItem(
                label: "Product",
                  icon: Image.asset(
                    "assets/images/product_icon.png",
                    color: _currentIndex == 1
                        ? Colors.cyan[800]
                        : Color.fromRGBO(153, 153, 153, 1),
                    height: 20,
                  ),

              ),
              BottomNavigationBarItem(
                label: "Inventory",
                  icon: Image.asset(
                    "assets/images/inventory_icon.png",
                    color: _currentIndex == 2
                        ? Colors.cyan[800]
                        : Color.fromRGBO(153, 153, 153, 1),
                    height: 20,
                  ),
              ),
              BottomNavigationBarItem(
                label: "",
                  icon: Image.asset(
                    "assets/images/inventory_icon.png",
                    color: Colors.white,
                    height: 0,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBookingDialog() {
    var textEditingController= TextEditingController();




    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
                type: MaterialType.transparency,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 30.0, top: 25, bottom: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context,true);
                                  },
                                  child: Container(
                                    child: Image.asset(
                                      "assets/images/closebutton.png",
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                      height: 20,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 50.0, right: 50),
                            child: Card(
                              elevation: 5,
                              child: TextFieldSearch(
                                  label: label,
                                  minStringLength: 0,
                                  future: () {
                                    return getNames(
                                        textEditingController.text);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter Customer Name / Code',
                                    contentPadding: EdgeInsets.only(
                                        left: 15, top: 15, right: 15),
                                    filled: false,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      size: 25.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  controller: textEditingController),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 50.0, right: 50, bottom: 5),
                            child: Text(
                              " Select Sales Type",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 50.0, right: 50, bottom: 20),
                              child: Card(
                                elevation: 5,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 50.0, top: 10),
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButton(
                                    isDense: true,
                                    //itemHeight: 50,
                                    iconSize: 35,
                                    isExpanded: true,
                                    hint: Text('Choose sales type'),
                                    value: _selectedLocation,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedLocation = newValue;
                                      });
                                    },
                                    items: _locations.map((location) {
                                      return DropdownMenuItem(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4.0, left: 0),
                                          child: new Text(location),
                                        ),
                                        value: location,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                if(textEditingController.text.isNotEmpty&&_selectedLocation.isNotEmpty){
                                  authenticate(textEditingController.text);
                                }
                              },
                              child: Container(
                                height: 45,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Color(0xfffb4ce5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          child: Image.asset(
                                            "assets/images/save.png",
                                            color: Colors.white,
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " Save",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: (){
                              showAddCustomerDialog();
                            },
                            child: Center(
                              child: Container(
                                height: 45,
                                width: 250,
                                decoration: BoxDecoration(
                                  color: Color(0xfffaa731),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.all(0),
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          child: Image.asset(
                                            "assets/images/addcustomer.png",
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "  Add New Customer",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 120,
                          ),
                          // Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.all(0),
                          //     child: Container(
                          //       height: 100,
                          //       width: 100,
                          //       child: Image.asset(
                          //         "assets/images/scan_blue.png",
                          //         //color: Colors.blueAccent,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Center(
                          //   child: Text(
                          //     "Scan",
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 24,
                          //         fontWeight: FontWeight.w500),
                          //   ),
                          // ),
                        ],
                      )),
                ));
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }



  void showAddCustomerDialog() {
    var name= TextEditingController();
    var balance= TextEditingController();
    var id= TextEditingController();

    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
                type: MaterialType.transparency,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 30.0, top: 25, bottom: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context,true);
                                  },
                                  child: Container(
                                    child: Image.asset(
                                      "assets/images/closebutton.png",
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                      height: 20,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 50.0, right: 50),
                            child: Card(
                              elevation: 5,
                              child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter Customer Name',
                                    contentPadding: EdgeInsets.only(
                                        left: 15, top: 15, right: 15),
                                    filled: false,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      size: 25.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  controller: name),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 50.0, right: 50),
                            child: Card(
                              elevation: 5,
                              child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter Customer ID',
                                    contentPadding: EdgeInsets.only(
                                        left: 15, top: 15, right: 15),
                                    filled: false,
                                    prefixIcon: Icon(
                                      Icons.security,
                                      size: 25.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  controller: id),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 50.0, right: 50),
                            child: Card(
                              elevation: 5,
                              child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter Balance',
                                    contentPadding: EdgeInsets.only(
                                        left: 15, top: 15, right: 15),
                                    filled: false,
                                    prefixIcon: Icon(
                                      Icons.monetization_on,
                                      size: 25.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  controller: balance),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: (){
                              Map<String, String> values = {
                                'Balance': balance.text,
                                'Name': name.text,
                                'CustomerID': id.text,
                              };
                              reference
                                .child("Customers")
                                    .child(id.text)
                                    .set(values).whenComplete(() => {

                              FlutterFlexibleToast.showToast(
                              message: "Added to Customers",
                              toastGravity: ToastGravity.BOTTOM,
                              icon: ICON.SUCCESS,
                              radius: 50,
                              elevation: 10,
                              imageSize: 20,
                              textColor: Colors.white,
                              backgroundColor: Colors.black,
                              timeInSeconds: 2),

                              Navigator.pop(context)
                              });

                            },
                            child: Center(
                              child: Container(
                                height: 45,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Color(0xfffb4ce5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          child: Image.asset(
                                            "assets/images/save.png",
                                            color: Colors.white,
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " Save",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 120,
                          ),
                          // Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.all(0),
                          //     child: Container(
                          //       height: 100,
                          //       width: 100,
                          //       child: Image.asset(
                          //         "assets/images/scan_blue.png",
                          //         //color: Colors.blueAccent,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Center(
                          //   child: Text(
                          //     "Scan",
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 24,
                          //         fontWeight: FontWeight.w500),
                          //   ),
                          // ),
                        ],
                      )),
                ));
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}

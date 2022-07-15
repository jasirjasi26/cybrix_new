// @dart=2.9
import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cybrix/data/getCustomerDetails.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/returns/return_order1.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:textfield_search/textfield_search.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:adobe_xd/pinned.dart';


class ReturnsPage extends StatefulWidget {
  @override
  ReturnsPageState createState() => ReturnsPageState();
}

class ReturnsPageState extends State<ReturnsPage> {
  bool select = true;
  DatabaseReference reference;
  List<String> names = [];
  List<String> amount = [];
  List<String> dates = [];
  List<String> code = [];
  List<String> vNo = [];
  List<String> balance = [];
  List<String> tax = [];
  var name = TextEditingController();
  DatabaseReference allnames;
  String label = "Enter Customer Name";
  List<String> _locations = []; // Option 2
  String _selectedLocation='[None]'; //
  DatabaseReference types; // Opt

  DateTime selectedDate = DateTime.now();
  String from = DateTime.now().year.toString() +
      "-" +
      DateTime.now().month.toString() +
      "-" +
      DateTime.now().day.toString();

  String to = DateTime.now().year.toString() +
      "-" +
      DateTime.now().month.toString() +
      "-" +
      DateTime.now().day.toString();

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        from = selectedDate.year.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.day.toString();
      });

    getCustomerId(from);
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        to = selectedDate.year.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.day.toString();
      });

    getCustomerId(from);
  }


  Future<void> authenticate(String text) async {


    if (await DataConnectionChecker().hasConnection) {
      await allnames.once().then((DataSnapshot snapshot) async {
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
                    return SalesReturn(
                      customerName: text,
                      refNo: "0",
                      salesType: _selectedLocation,
                    );
                  }))
            });
          } else {
            if (text == values["CustomerCode"]) {
              GetCustomerDetails().getCustomerId(text).whenComplete(() => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return SalesReturn(
                        customerName: text,
                        refNo: "0",
                        salesType: _selectedLocation,
                      );
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
                  return SalesReturn(
                    customerName: text,
                    refNo: "0",
                    salesType: _selectedLocation,
                  );
                }))

          });
        } else {
          if (text == values["CustomerCode"]) {
            GetCustomerDetails().getCustomerId(text).whenComplete(() => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return SalesReturn(
                      customerName: text,
                      refNo: "0",
                      salesType: _selectedLocation,
                    );
                  }))
            });
          }
        }
      });
    }

  }

  Future<void> getCustomerId(String customer) async {
    setState(() {
      dates.clear();
      code.clear();
      amount.clear();
      vNo.clear();
      names.clear();
      balance.clear();
      tax.clear();
    });

    await reference.child("Returns").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) async {
        DateFormat inputFormat = DateFormat('yyyy-mm-dd');
        DateTime input = inputFormat.parse(from);
        DateTime inputTo = inputFormat.parse(to);
        DateTime inputKey = inputFormat.parse(key);
        String datefrom = DateFormat('yyyy-mm-dd').format(input);
        String dateTo = DateFormat('yyyy-mm-dd').format(inputTo);
        String dateKeys = DateFormat('yyyy-mm-dd').format(inputKey);

        if (DateTime.parse(dateKeys).isAfter(DateTime.parse(datefrom)) &&
                DateTime.parse(dateKeys).isBefore(DateTime.parse(dateTo)) ||
            DateTime.parse(dateKeys) == (DateTime.parse(dateTo)) ||
            DateTime.parse(dateKeys) == (DateTime.parse(datefrom))) {
          print(key);

          await reference
              .child("Returns")
              .child(key)
              .child(User.vanNo)
              .once()
              .then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, values) {
              if (values['CustomerName']
                  .toString()
                  .toLowerCase()
                  .contains(name.text.toLowerCase())) {
                setState(() {
                  names.add(values['CustomerName'].toString());
                  amount.add(values['Amount'].toString());
                  dates.add(values['VoucherDate'].toString());
                  vNo.add(values['OrderID'].toString());
                  code.add(values['CustomerID'].toString());
                  balance.add(values['Balance'].toString());
                  tax.add(values['TaxAmount'].toString());
                });
              }
            });
          });
        } else {
          print("Noo data");
        }
      });
    });
  }

  void initState() {
    // TODO: implement initState
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);

    types = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database)
        .child("SalesTypes");

    allnames = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database)
        .child("Customers");
    getSalesTypes();
    getCustomerId(from);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        isExtended: true,
        onPressed: showBookingDialog,
        child: Container(
          width: 200,
          height: 200,
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
                      Pin(size: 118.0, middle: 0.8039),
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
                  'Return Request',
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
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          searchRow(),
          salesOrder()
        ],
      ),
    );
  }


  void showBookingDialog() {
    var textEditingController = TextEditingController();
    Future<List> getNames(String input) async {
      List _list = new List();

      if (await DataConnectionChecker().hasConnection) {
        await allnames.once().then((DataSnapshot snapshot) async {
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
                      height: MediaQuery.of(context).size.height * 0.75,
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
                                    Navigator.pop(context, true);
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
                                // future: getNames,
                                // initialList: dummyList,
                                  label: label,
                                  minStringLength: 0,
                                  future: () {
                                    return getNames(textEditingController.text);
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
                                if (textEditingController.text.isNotEmpty &&
                                    _selectedLocation.isNotEmpty) {
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


  searchRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                        hintText: 'Enter customer name here',
                        //filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 15, right: 15),
                        filled: false,
                        isDense: false,
                        prefixIcon: Icon(
                          Icons.person,
                          size: 25.0,
                          color: Colors.grey,
                        ),
                      )),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '  From : ',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 13,
                    color: Color(0xffb0b0b0),
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Text(
                    from,
                    style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 13,
                        color: Colors.black,
                        decoration: TextDecoration.underline),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'To',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 13,
                    color: Color(0xffb0b0b0),
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    _selectToDate(context);
                  },
                  child: Text(
                    to,
                    style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 13,
                        color: Colors.black,
                        decoration: TextDecoration.underline),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  salesOrder() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                  height: 25,
                  width: 500,
                  decoration: BoxDecoration(
                    color: const Color(0xff454d60),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 500,
                      height: MediaQuery.of(context).size.height,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '   V No ',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: const Color(0xffffffff),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '  Date ',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: const Color(0xffffffff),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            width: 180,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  '  Name ',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 12,
                                    color: const Color(0xffffffff),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                ' Code  ',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 12,
                                  color: const Color(0xffffffff),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              ' Amt  ',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: const Color(0xffffffff),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              Container(
                width: 500,
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: new List.generate(
                    names.length,
                    (index) => Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: index.floor().isEven
                            ? Color(0x66d6d6d6)
                            : Color(0x66f3ceef),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              vNo[index],
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              dates[index],
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            width: 180,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                names[index],
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          SizedBox(),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Center(
                              child: Text(
                                code[index],
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              amount[index],
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      automaticallyImplyLeading: true,
      title: Text(
        "Return List",
        style: TextStyle(color: Colors.black),
      ),
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 80,
    );
  }
}

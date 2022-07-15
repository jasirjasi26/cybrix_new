// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../van_page.dart';
class SalesReport1 extends StatefulWidget {

  @override
  SalesReport1State createState() => SalesReport1State();
}

class SalesReport1State extends State<SalesReport1> {
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

      await reference.child("Bills").once().then((DataSnapshot snapshot) {
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
            await reference
                .child("Bills")
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
    print(User.database);
    getCustomerId(from);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          searchRow(),
          salesInvoice()
        ],
      ),
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

  salesInvoice() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                  height: 25,
                  width: 600,
                  decoration: BoxDecoration(
                    color: const Color(0xff454d60),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 600,
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
                            width: 200,
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
                          SizedBox(),
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
                          SizedBox(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Bill Amount  ',
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
                              '   ',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: const Color(0xffffffff),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Text(
                          //     ' Action   ',
                          //     style: TextStyle(
                          //       fontFamily: 'Arial',
                          //       fontSize: 12,
                          //       color: const Color(0xffffffff),
                          //     ),
                          //     textAlign: TextAlign.left,
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  )),
              Container(
                width: 600,
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
                          SizedBox(),
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

                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return VanPage(
                                          customerName: names[index],
                                          voucherNumber: vNo[index],
                                          date: dates[index],
                                          billAmount: amount[index],
                                          back: true);
                                    }));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  //color: Colors.blue[900],
                                ),
                                child: Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      "assets/images/download.png",
                                      fit: BoxFit.scaleDown,
                                      //color: Colors.white
                                    )),
                              ),
                            ),
                          )
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Text(
                          //     "done",
                          //     style: TextStyle(
                          //       fontFamily: 'Arial',
                          //       fontSize: 12,
                          //       color: Colors.black,
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
        "Sales Report",
        style: TextStyle(color: Colors.black),
      ),
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 80,
    );
  }
}

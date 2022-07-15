// @dart=2.9
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/user_data.dart';

class CustomersList extends StatefulWidget {
  @override
  CustomersListState createState() => CustomersListState();
}

class CustomersListState extends State<CustomersList> {
  DatabaseReference reference;
  List<String> names = [];
  List<String> balance = [];
  List<String> id = [];
  var name = TextEditingController();

  Future<void> getCustomerId(String date) async {
    // String url =
    //      "https://cybrixproject1-default-rtdb.firebaseio.com/Companies/CASTELLO/Customers.json";
    // final response = await http.get(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Accept': 'application/json',
    //   },
    // );
    // print(response.body);
    // if (response.statusCode == 200) {
    //   print(response.body);
    // } else {
    //   print("Failed");
    // }

    setState(() {
      names.clear();
      balance.clear();
      id.clear();
    });

    await reference.child("Customers").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        if (values['Name']
            .toString()
            .toLowerCase()
            .contains(name.text.toLowerCase())) {
          setState(() {
            names.add(values["Name"].toString());
            balance.add(
                double.parse(values["Balance"]).toStringAsFixed(User.decimals).toString());
            id.add(values["CustomerCode"].toString());
          });
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
    getCustomerId("");

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
          salesOrder()
        ],
      ),
    );
  }

  searchRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
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
                    borderRadius: BorderRadius.circular(5.0),
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
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Text(
          //         '   From  :',
          //         style: TextStyle(
          //           fontFamily: 'Arial',
          //           fontSize: 14,
          //           color: Color(0xffb0b0b0),
          //         ),
          //         textAlign: TextAlign.left,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       GestureDetector(
          //         onTap:(){
          //           _selectDate(context);
          //         },
          //         child: Text(
          //           from,
          //           style: TextStyle(
          //               fontFamily: 'Arial',
          //               fontSize: 13,
          //               color: Colors.black,
          //               decoration: TextDecoration.underline),
          //           textAlign: TextAlign.left,
          //         ),
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text(
          //         'To',
          //         style: TextStyle(
          //           fontFamily: 'Arial',
          //           fontSize: 13,
          //           color: Color(0xffb0b0b0),
          //         ),
          //         textAlign: TextAlign.left,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       GestureDetector(
          //         onTap:(){
          //           _selectToDate(context);
          //         },
          //         child: Text(
          //           to,
          //           style: TextStyle(
          //               fontFamily: 'Arial',
          //               fontSize: 13,
          //               color: Colors.black,
          //               decoration: TextDecoration.underline),
          //           textAlign: TextAlign.left,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  salesOrder() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xff454d60),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Customer ID',
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
                        'Customer Name',
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
                        'Balance',
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
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width,
                child: new ListView(
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
                              id[index],
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              balance[index],
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
        ));
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
        'Customers',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 20,
          color: const Color(0xff1d336c),
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.left,
      ),
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 80,
    );
  }
}

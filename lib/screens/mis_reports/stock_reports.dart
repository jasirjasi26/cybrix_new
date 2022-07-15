// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StockReports extends StatefulWidget {

  @override
  StockReportsState createState() => StockReportsState();
}

class StockReportsState extends State<StockReports> {
  List<String> _locations = ['All','1', '2', '3','4','5','6']; // Option 2
  String _selectedLocation='All';
  DatabaseReference reference;
  List<String> names = [];
  List<String> stock = [];
  List<String> sRate = [];
  List<String> pRate = [];
  List<String> id = [];
  DateTime selectedDate = DateTime.now();
  String from="2021-12-15";
  var name=TextEditingController();


  Future<void> getCustomerId(String date) async {
    setState(() {
      names.clear();
      stock.clear();
      sRate.clear();
      pRate.clear();
      id.clear();
    });
    if(_selectedLocation=='All'){
      await reference.child("Stocks").once().then((DataSnapshot snapshot) {
        List<dynamic> values = snapshot.value;
        for (int i = 0; i < values.length; i++) {
          if (values[i] != null) {
            if(values[i]['ItemName'].toString().toLowerCase().contains(name.text.toLowerCase())){
              setState(() {
                names.add(values[i]['ItemName'].toString());
                sRate.add(values[i]['SaleRate'].toString());
                pRate.add(values[i]['PurchaseRate'].toString());
                id.add(values[i]['ItemID'].toString());
                stock.add(values[i]['Stock']['All'].toString());
              });
            }
          }
        }
      });
    }
    else{
      await reference.child("Items").once().then((DataSnapshot snapshot) {
        List<dynamic> values = snapshot.value;
        for (int i = 0; i < values.length; i++) {
          if (values[i] != null) {
            if(values[i]['ItemName'].toString().toLowerCase().contains(name.text.toLowerCase())){
              setState(() {
                String unit = values[i]["SaleUnit"].toString();
                names.add(values[i]['ItemName'].toString());
                sRate.add(values[i]["RateAndStock"][unit]["Rate"]);
                pRate.add(values[i]["RateAndStock"][unit]["PurchaseRate"]);
                id.add(values[i]['ItemID'].toString());
                stock.add(values[i]["RateAndStock"][unit]["Stock"][int.parse(_selectedLocation)].toString());
              });
            }
          }
        }
      });
    }
  }

  void initState() {
    // TODO: implement initState
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);
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
          salesOrder()
        ],
      ),
    );
  }

  searchRow() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 140,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.93,
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
                        hintText: 'Enter item name here',
                        //filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 15, right: 15),
                        filled: false,
                        isDense: false,
                        prefixIcon: Icon(
                          Icons.settings_input_composite_outlined,
                          size: 25.0,
                          color: Colors.grey,
                        ),
                      )),
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              SizedBox(width: 20,),
              Card(
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10.0,top: 5),
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton(
                    isDense: true,
                    //itemHeight: 50,
                    iconSize: 35,
                    iconEnabledColor: Color(0xffb0b0b0),
                    isExpanded: true,
                    hint: Text(
                      'Select Depo',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        color: const Color(0xffb0b0b0),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    value: _selectedLocation,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                      getCustomerId(_selectedLocation);
                      print(_selectedLocation);
                    },
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom:4.0,left: 0),
                          child: new Text(
                            location,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: const Color(0xffb0b0b0),
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        value: location,
                      );
                    }).toList(),
                  ),
                ),
              ),
          //
          //     Card(
          //       elevation: 5,
          //       child: Container(
          //         padding: const EdgeInsets.only(
          //             left: 10.0,top: 5),
          //         width: MediaQuery.of(context).size.width * 0.35,
          //         height: 40,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: DropdownButton(
          //           isDense: true,
          //           //itemHeight: 50,
          //           iconSize: 35,
          //           iconEnabledColor: Color(0xffb0b0b0),
          //           isExpanded: true,
          //           hint: Text(
          //             'Select Group',
          //             style: TextStyle(
          //               fontFamily: 'Arial',
          //               fontSize: 12,
          //               color: const Color(0xffb0b0b0),
          //             ),
          //             textAlign: TextAlign.left,
          //           ),
          //           value: _selectedLocation,
          //           onChanged: (newValue) {
          //             setState(() {
          //               _selectedLocation = newValue;
          //             });
          //           },
          //           items: _locations.map((location) {
          //             return DropdownMenuItem(
          //               child: Padding(
          //                 padding: const EdgeInsets.only(bottom:4.0,left: 0),
          //                 child: new Text(
          //                   location,
          //                   style: TextStyle(
          //                     fontFamily: 'Arial',
          //                     fontSize: 12,
          //                     color: const Color(0xffb0b0b0),
          //                   ),
          //                   textAlign: TextAlign.left,
          //                 ),
          //               ),
          //               value: location,
          //             );
          //           }).toList(),
          //         ),
          //       ),
             // ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Text(
          //         'From',
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
          //       Text(
          //         '22/12/2021',
          //         style: TextStyle(
          //             fontFamily: 'Arial',
          //             fontSize: 13,
          //             color: Colors.black,
          //             decoration: TextDecoration.underline),
          //         textAlign: TextAlign.left,
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
          //       Text(
          //         '25/12/2021',
          //         style: TextStyle(
          //             fontFamily: 'Arial',
          //             fontSize: 13,
          //             color: Colors.black,
          //             decoration: TextDecoration.underline),
          //         textAlign: TextAlign.left,
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
        width: 600,
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
                    'Code',
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
                    child: Text(
                      'Name',
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
                    'Stock',
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
                    'Sale Rate',
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
                    'P. Rate',
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
            height: MediaQuery
                .of(context)
                .size
                .height * 0.7,
            width: MediaQuery
                .of(context)
                .size
                .width,

            child: new ListView(
              children: new List.generate(names.length, (index) =>
                  Container(
                    height: 30,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    decoration: BoxDecoration(
                      color: index.floor().isEven ? Color(0x66d6d6d6) : Color(0x66f3ceef),
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
                              color:  Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              names[index],
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                color:  Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                           stock[index],
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
                            sRate[index],
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
                            pRate[index],
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
                  ),),
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
        'Stock Reports',
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

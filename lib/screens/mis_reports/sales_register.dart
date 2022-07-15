// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesRegister extends StatefulWidget {
  SalesRegister({Key key, this.title}) : super(key: key);

  final String title;

  @override
  SalesRegisterState createState() => SalesRegisterState();
}

class SalesRegisterState extends State<SalesRegister> {
  DatabaseReference reference;
  List<String> dates = [];
  List<String> party = [];
  List<String> amount = [];
  List<String> paid = [];
  List<String> balance = [];
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
  var name = TextEditingController();

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


  Future<void> getCustomerId(String date) async {
    setState(() {
      dates.clear();
      party.clear();
      amount.clear();
      paid.clear();
      balance.clear();
    });





    await reference.child("SalesReport").once().then((DataSnapshot snapshot) {
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
          await reference.child("SalesReport").child(key).once().then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, values) {
              if(values['PartyName'].toString().toLowerCase().contains(name.text.toLowerCase())){
                setState(() {
                  dates.add(values['Date'].toString());
                  party.add(values['PartyName'].toString());
                  amount.add(values['GrandAmount'].toString());
                  paid.add(values['Paid'].toString());
                  balance.add(values['Balance'].toString());
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
      height: 105,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10,),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
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
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '   From  :',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    color: Color(0xffb0b0b0),
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap:(){
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
                  onTap:(){
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
                    'Sl No',
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
                    'Date',
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
                        'Party',
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
                  child: Text(
                    'Grand Amt',
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
                    'Paid',
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
            height: MediaQuery
                .of(context)
                .size
                .height * 0.7,
            width: MediaQuery
                .of(context)
                .size
                .width,

            child: new ListView(
              children: new List.generate(dates.length, (index) =>
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
                            index.toString(),
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color:  Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            dates[index],
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
                              party[index],
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
                          padding: const EdgeInsets.all(8.0),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            paid[index],
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
                        )
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
        'Sales Register',
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

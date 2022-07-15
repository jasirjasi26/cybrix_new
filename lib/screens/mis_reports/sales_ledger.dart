// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SalesLedger extends StatefulWidget {
  @override
  SalesLedgerState createState() => SalesLedgerState();
}

class SalesLedgerState extends State<SalesLedger> {
  DatabaseReference reference;
  List<String> names = [];
  List<String> balance = [];

  Future<void> getCustomerId() async {
    setState(() {
      names.clear();
      balance.clear();
    });

    await reference.child("Accounts").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() {
          names.add(key);
          balance.add(values["TotalBalance"].toString());
        });
      });
    });
  }

  void initState() {
    // TODO: implement initState
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);
    getCustomerId();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: ListView(
        children: [salesOrder()],
      ),
    );
  }

  salesOrder() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 30,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color(0xff454d60),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 25,
                ),
                Padding(
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
                Spacer(),
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
                SizedBox(
                  width: 25,
                ),
              ],
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, index) {
                  return Container(
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
                        SizedBox(
                          width: 25,
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
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            balance[index].toString(),
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                      ],
                    ),
                  );
                },
              )),
        ],
      ),
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
        'Sales Ledger',
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

// @dart=2.9
import 'package:cybrix/data/getVouchers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:cybrix/data/customed_details.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/van_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settlement2 extends StatefulWidget {
  Settlement2(
      {Key key, this.customerName, this.date, this.values, this.radioValue})
      : super(key: key);
  final int radioValue;
  final String date;
  final String customerName;
  final Map<String, dynamic> values;

  @override
  SettlementPageState2 createState() => SettlementPageState2();
}

class SettlementPageState2 extends State<Settlement2> {
  var voucherNo = TextEditingController();
  var billAmount = TextEditingController();
  var oldBalance = TextEditingController();
  var paidCash = TextEditingController();
  var paidCard = TextEditingController();
  var subTotal = TextEditingController();
  double finalBalance = 0;
  var totalDisc = 0;
  double rounoff = 0;
  DatabaseReference reference;
  double totalReceived = 0;

  roundOff() {
    double total;
    setState(() {
      total = double.parse(subTotal.text);
      subTotal.text = double.parse(subTotal.text).round().toString();
      rounoff = double.parse(subTotal.text) - total;
    });
  }

  roundDown() {
    double total;
    setState(() {
      total = double.parse(subTotal.text);
      subTotal.text = double.parse(subTotal.text).floor().toString();
      rounoff = total - double.parse(subTotal.text);
    });
  }

  payOn(String a) {
    finalBalance = double.parse(Customer.balance) + double.parse(subTotal.text);
    setState(() {
      finalBalance = finalBalance -
          (double.parse(paidCard.text) + double.parse(paidCash.text));
      totalReceived =
          (double.parse(paidCard.text) + double.parse(paidCash.text));
    });
  }

  addValues() async {
    reference
      ..child("Order")
          .child(User.vanNo)
          .child(widget.values['OrderId'])
          .once()
          .then((DataSnapshot snapshot) {
        var data = snapshot.value;

        reference
          ..child("Bills")
              .child(widget.date)
              .child(User.vanNo)
              .child(voucherNo.text)
              .set(data);

        double ch=double.parse(paidCash.text);
        double cr=double.parse(paidCard.text);

        Map<String, String> values = {
          'Balance': finalBalance.toStringAsFixed(User.decimals),
          'Amount': subTotal.text,
          'CardReceived': cr.toStringAsFixed(User.decimals),
          'CashReceived': cr.toStringAsFixed(User.decimals),
          'OrderID': voucherNo.text,
          'RoundOff': rounoff.toStringAsFixed(User.decimals),
          'TotalReceived': totalReceived.toString(),
          'UpdatedTime': DateTime.now().toString(),
          'VoucherDate': widget.date,
        };

        reference
            .child("Bills")
            .child(widget.date)
            .child(User.vanNo)
            .child(voucherNo.text)
            .update(values);
      });


    ///updating the voucher number
    String lastVoucher = voucherNo.text.replaceAll(User.voucherStarting, "");
    reference
      ..child("Vouchers")
          .child(User.vanNo)
          .child("VoucherNumber")
          .remove()
          .whenComplete(() => {
                reference
                  ..child("Vouchers")
                      .child(User.vanNo)
                      .child("VoucherNumber")
                      .set(lastVoucher.toString())
              });

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("vouchernumber",int.parse(lastVoucher));

    FlutterFlexibleToast.showToast(
        message: "Added to Invoice",
        toastGravity: ToastGravity.BOTTOM,
        icon: ICON.SUCCESS,
        radius: 50,
        elevation: 10,
        imageSize: 20,
        textColor: Colors.white,
        backgroundColor: Colors.black,
        timeInSeconds: 2);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VanPage(
        customerName: widget.customerName,
        voucherNumber: voucherNo.text,
        date: widget.date,
        billAmount: widget.values['BillAmount'],
        from: "Bills",
        back: false,
      );
    }));
  }

  getOldBalance() async {
    await reference.child("Customers").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        if (widget.customerName == values["Name"]) {
          setState(() {
            double a = double.parse(values["Balance"]);
            Customer.balance = a.toStringAsFixed(User.decimals);
            Customer.CustomerName = values["Name"].toString();
            oldBalance.text = Customer.balance;
          });
        }
      });
    });

    // await reference
    //     .child("Vouchers")
    //     .child(User.vanNo)
    //     .once()
    //     .then((DataSnapshot snapshot) {
    //   Map<dynamic, dynamic> values = snapshot.value;
    //   values.forEach((key, values) {
    //     setState(() {
    //       if (key.toString() == "VoucherNumber") {
    //         voucherNo.text = User.voucherStarting +
    //             (int.parse(values.toString()) + 1).toString();
    //       }
    //     });
    //   });
    // });

    setState(() {
      voucherNo.text=User.voucherNumber;
      billAmount.text = widget.values['Amount'].toString();
      subTotal.text = widget.values['Amount'].toString();
      paidCash.text = "0";
      paidCard.text = "0";
      finalBalance =
          double.parse(widget.values['Balance']) + double.parse(subTotal.text);
    });
  }

  void initState() {
    // TODO: implement initState
    reference = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(User.database);

    GetVouchers().getVouchers();
    getOldBalance();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Container(
                      height: 25,
                      width: 25,
                      child: Image.asset("assets/images/voucher.png",
                          fit: BoxFit.scaleDown, color: Colors.black)),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
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
                        controller: voucherNo,
                        decoration: InputDecoration(
                          hintText: 'Voucher Number',
                          //filled: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 15, top: 15, right: 15),
                          filled: false,
                          isDense: false,
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Container(
                      height: 25,
                      width: 25,
                      child: Image.asset("assets/images/balance.png",
                          fit: BoxFit.scaleDown, color: Colors.black)),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.35 - 10,
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
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 15, top: 15, right: 15),
                            child: Text(oldBalance.text),
                          )),
                      Text(
                        "Old Balance",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      height: 25,
                      width: 25,
                      child: Image.asset("assets/images/balance.png",
                          fit: BoxFit.scaleDown, color: Colors.black)),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.35 - 10,
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
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 15, bottom: 15, top: 15, right: 15),
                            child: Text(billAmount.text),
                          )),
                      Text(
                        "Bill Amount",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  Container(
                      height: 30,
                      width: 30,
                      child: Image.asset(
                        "assets/images/cashrecived.png",
                        fit: BoxFit.fill,
                        //    color: Colors.black
                      )),
                  Text(
                    "    Cash Received",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.45 - 10,
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
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  height: 25,
                                  width: 25,
                                  child: Image.asset(
                                    "assets/images/money.png",
                                    fit: BoxFit.scaleDown,
                                    //    color: Colors.black
                                  )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                  controller: paidCash,
                                  onChanged: payOn,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '',
                                    //filled: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 15,
                                        top: 15,
                                        right: 15),
                                    filled: false,
                                    isDense: false,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Paid via cash",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.45 - 10,
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
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  height: 25,
                                  width: 25,
                                  child: Image.asset(
                                    "assets/images/card.png",
                                    fit: BoxFit.scaleDown,
                                    //    color: Colors.black
                                  )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                  controller: paidCard,
                                  onChanged: payOn,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 15,
                                        bottom: 15,
                                        top: 15,
                                        right: 15),
                                    filled: false,
                                    isDense: false,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Paid via card",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  '   Subtotal  ',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 18,
                    color: const Color(0xff5b5b5b),
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
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
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 15, bottom: 15, top: 15, right: 15),
                        child: Text(subTotal.text),
                      )),
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            roundDown();
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: const Color(0xff8561f0),
                            ),
                            child: Image.asset("assets/images/back.png",
                                fit: BoxFit.scaleDown, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            roundOff();
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: const Color(0xff8561f0),
                            ),
                            child: Image.asset("assets/images/front.png",
                                fit: BoxFit.scaleDown, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    Text(
                      "Round Off",
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        color: const Color(0xff5b5b5b),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 50, bottom: 5, top: 25),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  Container(
                      height: 20,
                      width: 20,
                      child: Image.asset(
                        "assets/images/percentage.png",
                        fit: BoxFit.scaleDown,
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Tax :   " + widget.values['TaxAmount'].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Spacer(),
                  Text(
                    'Grand Total  ',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -4.12),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xffffffff),
                          const Color(0xfffaa731)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xfffae7cb),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(child: Text(subTotal.text)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Spacer(),
                  Text(
                    'Balance   ',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -4.12),
                        end: Alignment(0.0, 1.0),
                        colors: [
                          const Color(0xffffffff),
                          const Color(0xfffb4ce5)
                        ],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xfffae7cb),
                          offset: Offset(6, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(child: Text(finalBalance.toStringAsFixed(User.decimals))),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  addValues();
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                      begin: Alignment(0.01, -0.72),
                      end: Alignment(0.0, 1.0),
                      colors: [
                        const Color(0xff385194),
                        const Color(0xff182d66)
                      ],
                      stops: [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x80182d66),
                        offset: Offset(6, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        color: const Color(0xfff7fdfd),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        "Settlements",
        style: TextStyle(color: Colors.black),
      ),
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 80,
    );
  }
}

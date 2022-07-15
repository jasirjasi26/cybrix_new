// @dart=2.9
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/material.dart';
import 'package:cybrix/screens/reciept_portal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:cybrix/ui_elements/bluetooth_print.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/ui_elements/bottomNavigation.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

import 'home.dart';

class ReceiptBill extends StatefulWidget {
  ReceiptBill(
      {Key key,
        this.customerName,
        this.date,
        this.voucherNumber,
        this.billAmount,this.back})
      : super(key: key);

  final String date;
  final String customerName;
  final String voucherNumber;
  final String billAmount;
  final bool back;

  @override
  ReceiptBillState createState() => ReceiptBillState();
}

class ReceiptBillState extends State<ReceiptBill> {
  final _screenshotController = ScreenshotController();
  final pdf = pw.Document();
  DatabaseReference reference;
  String cash = "-";
  String card = "-";
  String balance = "-";
  String generatedPdfFilePath;


  takeBillPdf() async {
    final imageFile = await _screenshotController.capture();

    final image = pw.MemoryImage(
      File(imageFile.path).readAsBytesSync(),
    );

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          ); // Center
        }));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/"+widget.voucherNumber+".pdf");
    await file.writeAsBytes(await pdf.save());
    Share.shareFiles([file.path], text: "Shared from Cybrix");
  }

  Future<void> getBill() async {
    reference.child("ReceiptPortal")
        .child(widget.date)
        .child(User.vanNo)
        .child(widget.voucherNumber)
        .once()
        .then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        setState(() {
          cash = values['CashReceived'].toString();
          card = values['CardReceived'].toString();
          balance = values['Balance'].toString();
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

    getBill();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),

      body: WillPopScope(
        onWillPop: () async {
          // You can do some work here.
          // Returning true allows the pop to happen, returning false prevents it.
          if(widget.back){
            return true;
          }
          else{
            return false;
          }

        },
        child: Stack(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 15.0, left: 15, right: 15),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 0.0),
                            child: Container(
                              height: 50,
                              width: 120,
                              child: Image.asset(
                                'assets/images/cybrix logo.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    homeData()
                  ],
                ),
              ),
            ),
            widget.back ? Container()  : Positioned(
              bottom: 40,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return BottomBar();
                          }));
                    },
                    child: Container(
                      width: 100,
                      height: 45,
                      child: Stack(
                        children: <Widget>[
                          Container(
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
                        ],
                      ),
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

  homeData() {
    return Column(
      children: [
        Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Pinned.fromPins(
                Pin(start: 0.0, end: 0.0),
                Pin(start: 0.0, end: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                  ),
                ),
              ),
              Pinned.fromPins(
                Pin(size: 113.0, end: 0.0),
                Pin(size: 17.0, start: 39.0),
                child: Text(
                  'Voucher Number',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 15,
                    color: const Color(0xff5b5b5b),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Pinned.fromPins(
                Pin(size: 53.0, end: 12.0),
                Pin(size: 17.0, start: 60.0),
                child: Text(
                  widget.voucherNumber,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 15,
                    color: const Color(0xff5b5b5b),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Container(
            height: 130,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Pinned.fromPins(
                  Pin(size: 250.0, start: 3.5),
                  Pin(size: 14.0, start: 0.0),
                  child: Text(
                    'Party Name : ' + widget.customerName,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 32.0, start: 3.5),
                  Pin(size: 14.0, middle: 0.1957),
                  child: Text(
                    'Date :',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 100.0, end: -63),
                  Pin(size: 11.0, middle: 0.2075),
                  child: Text(
                    widget.date,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 50.0, start: 3.5),
                  Pin(size: 14.0, middle: 0.3915),
                  child: Text(
                    'Balance :',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 90.0, end: -50),
                  Pin(size: 14.0, middle: 0.3915),
                  child: Text(
                    balance,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 56.0, start: 3.5),
                  Pin(size: 14.0, middle: 0.5872),
                  child: Text(
                    'Van No : ' + User.vanNo,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 150.0, end: -50),
                  Pin(size: 14.0, middle: 0.5872),
                  child: Text(
                    'Driver : ' + User.number,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff5b5b5b),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 25, right: 15),
          child: Column(
            children: [
              // Row(
              //   children: [
              //     Text(
              //       'Company Name & Address',
              //       style: TextStyle(
              //         fontFamily: 'Arial',
              //         fontSize: 12,
              //         color: const Color(0xff5b5b5b),
              //       ),
              //       textAlign: TextAlign.left,
              //     ),
              //   ],
              // ),
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    letterSpacing: 3,
                    color: const Color(0xff5b5b5b),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Container(
            height: 120,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15,bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cash Received',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        cash,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15,bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card Received',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        card,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        balance,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13,
                          color: const Color(0xff5b5b5b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),

        // Center(
        //   child: GestureDetector(
        //     onTap: () {
        //       Navigator.push(context, MaterialPageRoute(builder: (context) {
        //         return MyHomePage();
        //       }));
        //     },
        //     child: Container(
        //       height: 50,
        //       width: 100,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(8.0),
        //         gradient: LinearGradient(
        //           begin: Alignment(0.01, -0.72),
        //           end: Alignment(0.0, 1.0),
        //           colors: [
        //             const Color(0xff385194),
        //             const Color(0xff182d66)
        //           ],
        //           stops: [0.0, 1.0],
        //         ),
        //         boxShadow: [
        //           BoxShadow(
        //             color: const Color(0x80182d66),
        //             offset: Offset(6, 3),
        //             blurRadius: 6,
        //           ),
        //         ],
        //       ),
        //       child: Center(
        //         child: Text(
        //           'Save',
        //           style: TextStyle(
        //             fontFamily: 'Arial',
        //             fontSize: 18,
        //             color: const Color(0xfff7fdfd),
        //           ),
        //           textAlign: TextAlign.left,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      automaticallyImplyLeading: widget.back ? true : false,
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: GestureDetector(
            onTap: () {
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => Bluetooth()));
            },
            child: Container(
              height: 18,
              width: 40,
              child: Image.asset(
                'assets/images/print.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: GestureDetector(
            onTap: () {
              takeBillPdf();
            },
            child: Container(
              height: 15,
              width: 25,
              child: Image.asset(
                'assets/images/pdf.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => super.widget));
            },
            child: Icon(
              Icons.refresh,
              size: 35,
            )),
        SizedBox(
          width: 15,
        ),
      ],
      elevation: 1.0,
      titleSpacing: 0,
      toolbarHeight: 70,
    );
  }
}

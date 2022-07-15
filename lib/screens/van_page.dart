// @dart=2.9
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:cybrix/ui_elements/bluetooth_print.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/ui_elements/bottomNavigation.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class VanPage extends StatefulWidget {
  VanPage(
      {Key key,
      this.customerName,
      this.date,
      this.voucherNumber,
      this.billAmount,
      this.back,
      this.customerCode,  this.from, this.values})
      : super(key: key);

  final String date;
  final String customerName;
  final String voucherNumber;
  final String billAmount;
  final bool back;
  final String customerCode;
  final String from;
  final Map<String, dynamic> values;

  @override
  VanPageState createState() => VanPageState();
}

class VanPageState extends State<VanPage> {
  final _screenshotController = ScreenshotController();
  final pdf = pw.Document();
  DatabaseReference reference;
  List<String> total = [];
  List<String> item = [];
  List<String> rate = [];
  List<String> qty = [];
  List<String> tax = [];
  List<dynamic> disc = [];
  String cash = "-";
  String card = "-";
  String roundOff = "-";
  String balance = "-";
  String totaltax = "-";
  String totalDisc = "-";
  String bill = "-";
  String generatedPdfFilePath;
  String totalBill = "-";
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  double totalReceived = 0;
  String billTime = "";
  int totalQty = 0;
  double totalQuantity = 0;
  Uint8List bytes;
  bool printBill = false;
  bool isloading = false;

  takeBillPdf() async {
    setState(() {
      printBill = false;
    });
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
    final file = File("${output.path}/" + widget.voucherNumber + ".pdf");
    await file.writeAsBytes(await pdf.save());
    Share.shareFiles([file.path], text: "Shared from Cybrix");
    return file;
    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf.save());
    //Share.shareFiles([file.path], text: "Shared from Cybrix");
    // return pdf.save();
  }

  Future<void> getBill() async {
    setState(() {
      isloading=true;
    });

    if (await DataConnectionChecker().hasConnection) {
      reference
        ..child(widget.from)
            .child(widget.date)
            .child(User.vanNo)
            .child(widget.voucherNumber)
            .child("Items")
            .once()
            .then((DataSnapshot snapshot) {
          List<dynamic> value = snapshot.value;
          for (int i = 0; i < value.length; i++) {
            if (value[i] != null) {
              setState(() {
                item.add(value[i]['ItemName'].toString());
                qty.add(value[i]['Qty']);
                tax.add(value[i]['TaxAmount']);
                total.add(value[i]['Total'].toString());
                rate.add(value[i]['Rate'].toString());
              });
            }
          }
        });

      reference
          .child(widget.from)
          .child(widget.date)
          .child(User.vanNo)
          .child(widget.voucherNumber)
          .once()
          .then((DataSnapshot snapshot) async {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          setState(() {
            cash = values['CashReceived'].toString() ;
            card = values['CardReceived'].toString() ;
            roundOff = values['RoundOff'].toString() ;
            balance = values['Balance'].toString();
            totaltax = values['TaxAmount'].toString();
            bill = values['Amount'].toString();
            totalDisc = values['TotalDiscount'].toString();
            totalBill = values['BillAmount'].toString();
            totalReceived = double.parse(cash) + double.parse(card);
            billTime = values['UpdatedTime'].toString().substring(0, 19);
            //totalQty = qty.reduce((a, b) => a + b) as int;
          });
        });
        setState(() {
          isloading=false;
        });
      });
    }else{
      FlutterFlexibleToast.showToast(
          message: "No Internet",
          toastGravity: ToastGravity.BOTTOM,
          icon: ICON.ERROR,
          radius: 50,
          elevation: 10,
          imageSize: 15,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          timeInSeconds: 2);
      for (int i = 0; i <widget.values['Items'].length; i++) {
         setState(() {
            item.add(widget.values['Items'][i]['ItemName'].toString());
            qty.add(widget.values['Items'][i]['Qty']);
            tax.add(widget.values['Items'][i]['TaxAmount']);
            total.add(widget.values['Items'][i]['Total'].toString());
            rate.add(widget.values['Items'][i]['Rate'].toString());
          });
      }

      setState(() {
        cash = widget.values['CashReceived'].toString() ;
        card = widget.values['CardReceived'].toString() ;
        roundOff = widget.values['RoundOff'].toString() ;
        balance = widget.values['Balance'].toString();
        totaltax = widget.values['TaxAmount'].toString();
        bill = widget.values['Amount'].toString();
        totalDisc = widget.values['TotalDiscount'].toString();
        totalBill = widget.values['BillAmount'].toString();
        totalReceived = double.parse(cash) + double.parse(card);
        billTime = widget.values['UpdatedTime'].toString().substring(0, 19);
        //totalQty = qty.reduce((a, b) => a + b) as int;
      });

      setState(() {
        isloading=false;
      });

    }

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
          if (widget.back) {
            return true;
          } else {
            return false;
          }
        },
        child: Stack(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
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
                    isloading
                        ? Center(
                        child: Container(
                            height: 50,
                            width: 50,
                            child: Center(child: CircularProgressIndicator())))
                        : homeData(),

                  ],
                ),
              ),
            ),

            widget.back
                ? Container()
                : Positioned(
                    top: MediaQuery.of(context).size.height * 0.75,
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
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[500],
            child: Padding(
              padding: const EdgeInsets.only(
                left: 0,
                right: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ITEM',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'QTY',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'RATE',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'TAX',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'TOTAL',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          // height: 200,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            children: new List.generate(
              item.length,
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          item[index],
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 10,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        qty[index],
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        rate[index],
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        tax[index],
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        total[index],
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bill',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        totalBill.toString(),
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tax',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        totaltax,
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RoundOff',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        roundOff,
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cash',
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card',
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        totalDisc.toString(),
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
                // Padding(
                //   padding: EdgeInsets.only(left: 15.0, right: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'Balance',
                //         style: TextStyle(
                //           fontFamily: 'Arial',
                //           fontSize: 12,
                //           color: const Color(0xff5b5b5b),
                //           fontWeight: FontWeight.w500,
                //         ),
                //         textAlign: TextAlign.left,
                //       ),
                //       Text(
                //         balance,
                //         style: TextStyle(
                //           fontFamily: 'Arial',
                //           fontSize: 12,
                //           color: const Color(0xff5b5b5b),
                //         ),
                //         textAlign: TextAlign.left,
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Bill Amount',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        bill,
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
          height: 20,
        ),
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
              // setState(() {
              //   printBill = !printBill;
              // });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Print(
                            billAmount: widget.billAmount,
                            date: widget.date,
                            voucherNumber: widget.voucherNumber,
                            customerName: widget.customerName,
                            customerCode: widget.customerCode,
                          )));
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

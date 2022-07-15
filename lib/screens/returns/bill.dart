// @dart=2.9
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/ui_elements/bottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class BillPage extends StatefulWidget {
  BillPage(
      {Key key,
      this.customerName,
      this.date,
      this.voucherNumber,
      this.billAmount,
      this.back,
      this.customerCode})
      : super(key: key);

  final String date;
  final String customerName;
  final String voucherNumber;
  final String billAmount;
  final bool back;
  final String customerCode;

  @override
  BillPageState createState() => BillPageState();
}

class BillPageState extends State<BillPage> {
  final _screenshotController = ScreenshotController();
  final pdf = pw.Document();
  DatabaseReference reference;
  List<String> total = [];
  List<String> item = [];
  List<String> rate = [];
  List<String> qty = [];
  List<String> tax = [];
  List<dynamic> disc = [];
  // String cash = "-";
  // String card = "-";
  // String roundOff = "-";
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

  Future<void> initPlatformState() async {
    ///Loading image
    final ByteData data = await rootBundle.load('assets/images/logo.jpg');
    setState(() {
      bytes = data.buffer.asUint8List();
    });

    bool isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  sample() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printNewLine();
        bluetooth.printImageBytes(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        bluetooth.printCustom(User.database.toUpperCase(), 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(User.address, 0, 1);
        bluetooth.printCustom("TRN No."+User.trno, 0, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("RETURN INVOICE", 2, 1);
        bluetooth.printCustom("-------------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Cust Name:" + widget.customerName, 0, 0);
        bluetooth.printLeftRight("Cust Code:" + widget.customerCode, "", 0);
        bluetooth.printLeftRight("Invoice No: " + widget.voucherNumber, "", 1);
        bluetooth.printLeftRight("Address: ", "", 0);
        bluetooth.printLeftRight("TRN No.11112223", "", 0);
        bluetooth.printLeftRight("Date & Time: " + billTime, "", 0);
        bluetooth.printLeftRight("Salesman:"+User.name, "", 0);
        bluetooth.printCustom("-------------------------------", 0, 1);
        bluetooth.printCustom("Item Name           Qty   Amount", 0, 0);
        bluetooth.printCustom("-------------------------------", 0, 1);
        for (int i = 0; i < item.length; i++) {
          bluetooth.printLeftRight(item[i].toString(),
              qty[i].toString() + "    " + total[i].toString(), 0);
          //bluetooth.printCustom(item[i].toString()+"   "+qty[i].toString()+"   "+total[i].toString(),0, 0);
          bluetooth.printNewLine();
        }
        bluetooth.printCustom("-------------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("Total Qty: " + totalQty.toString(), "", 0);
        bluetooth.printLeftRight("Grand Total: " + bill, " ", 0);
        bluetooth.printLeftRight("Discount: " + totalDisc, " ", 0);
       // bluetooth.printLeftRight("RoundOff: " + roundOff, " ", 0);
        bluetooth.printLeftRight("Vat (5%): " + totaltax, " ", 0);
        bluetooth.printLeftRight("Net Amount: " + totalBill, " ", 1);
        bluetooth.printNewLine();
        //bluetooth.printLeftRight("Cash: " + cash, "", 0);
        //bluetooth.printLeftRight("Card: " + card, "", 0);
        // bluetooth.printLeftRight(
        //     "Amount Received: " + totalReceived.toString(), "", 0);
        bluetooth.printLeftRight("Current Balance: " + balance, " ", 0);
        bluetooth.printCustom("-------------------------------", 0, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("Customers Signature :    ", "", 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

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
    reference
      ..child("Returns")
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
              qty.add(value[i]['Qty'].toString());
              tax.add(value[i]['TaxAmount'].toStringAsFixed(User.decimals));
              total.add(value[i]['Total'].toStringAsFixed(User.decimals));
              rate.add(value[i]['Rate'].toStringAsFixed(User.decimals));
            });
          }
        }
      });

    reference
        .child("Returns")
        .child(widget.date)
        .child(User.vanNo)
        .child(widget.voucherNumber)
        .once()
        .then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        setState(() {
          balance = values['Balance'].toString();
          totaltax = values['TaxAmount'].toString();
          bill = values['Amount'].toString();
          //totalDisc = values['TotalDiscount'].toString();
          totalBill = values['BillAmount'].toString();
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
    initPlatformState();
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
                color: Colors.white,
                child: ListView(
                  children: [
                    printBill
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Please Select Device:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Device:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      items: _getDeviceItems(),
                                      onChanged: (value) =>
                                          setState(() => _device = value),
                                      value: _device,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.brown),
                                      onPressed: () {
                                        initPlatformState();
                                      },
                                      child: Text(
                                        'Refresh',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: _connected
                                              ? Colors.red
                                              : Colors.green),
                                      onPressed:
                                          _connected ? _disconnect : _connect,
                                      child: Text(
                                        _connected ? 'Disconnect' : 'Connect',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 5),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.blue[900]),
                                      onPressed: () {
                                        sample();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Print Receipt',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                        : Container(),
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
            widget.back
                ? Container()
                : Positioned(
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
                // Padding(
                //   padding: EdgeInsets.only(left: 15.0, right: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'RoundOff',
                //         style: TextStyle(
                //           fontFamily: 'Arial',
                //           fontSize: 12,
                //           color: const Color(0xff5b5b5b),
                //           fontWeight: FontWeight.w500,
                //         ),
                //         textAlign: TextAlign.left,
                //       ),
                //       Text(
                //         roundOff,
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
                // Padding(
                //   padding: EdgeInsets.only(left: 15.0, right: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'Cash',
                //         style: TextStyle(
                //           fontFamily: 'Arial',
                //           fontSize: 12,
                //           color: const Color(0xff5b5b5b),
                //           fontWeight: FontWeight.w500,
                //         ),
                //         textAlign: TextAlign.left,
                //       ),
                //       // Text(
                //       //   cash,
                //       //   style: TextStyle(
                //       //     fontFamily: 'Arial',
                //       //     fontSize: 12,
                //       //     color: const Color(0xff5b5b5b),
                //       //   ),
                //       //   textAlign: TextAlign.left,
                //       // ),
                //     ],
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.only(left: 15.0, right: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'Card',
                //         style: TextStyle(
                //           fontFamily: 'Arial',
                //           fontSize: 12,
                //           color: const Color(0xff5b5b5b),
                //           fontWeight: FontWeight.w500,
                //         ),
                //         textAlign: TextAlign.left,
                //       ),
                //       Text(
                //         card,
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
                // Padding(
                //   padding: EdgeInsets.only(left: 15.0, right: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         'Discount',
                //         style: TextStyle(
                //           fontFamily: 'Arial',
                //           fontSize: 12,
                //           color: const Color(0xff5b5b5b),
                //           fontWeight: FontWeight.w500,
                //         ),
                //         textAlign: TextAlign.left,
                //       ),
                //       Text(
                //         totalDisc.toString(),
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
                  padding: EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: const Color(0xff5b5b5b),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        balance,
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
          height: 30,
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
              setState(() {
                printBill = !printBill;
              });
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

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   new SnackBar(
    //     content: new Text(
    //       message,
    //       style: new TextStyle(
    //         color: Colors.white,
    //       ),
    //     ),
    //     duration: duration,
    //   ),
    //);
  }
}

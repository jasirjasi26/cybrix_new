// @dart=2.9
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SignaturePage extends StatefulWidget {
  @override
  SignaturePageState createState() => SignaturePageState();
}

class SignaturePageState extends State<SignaturePage> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  ///save signature
  ///
  void _handleSaveButtonPressed() async {
    final data =
    await signatureGlobalKey.currentState.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.grey[300],
                child: Image.memory(bytes.buffer.asUint8List()),
              ),
            ),
          );
        },
      ),
    );
  }
///clear signature
  ///
  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState.clear();
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
          homeData()
        ],
      ),
    );
  }

  homeData() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '    Proof of Delivery',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 24,
                  color: const Color(0xff182d66),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    'Draw your signature here ',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      color: const Color(0xff182d66),
                    ),
                    textAlign: TextAlign.left,
                  )),
              SizedBox(
                width: 100,
              ),
              GestureDetector(
                onTap: _handleClearButtonPressed,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 15,
                    color: const Color(0xff182d66),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
        Padding(
            padding: EdgeInsets.only(left: 25,right: 25),
            child: Container(
                child: SfSignaturePad(
                    key: signatureGlobalKey,
                    backgroundColor: Colors.white,
                    strokeColor: Colors.black,
                    minimumStrokeWidth: 1.0,
                    maximumStrokeWidth: 4.0),
                decoration:
                BoxDecoration(border: Border.all(color: Colors.grey)))),
        SizedBox(
          height: 50,
        ),
        GestureDetector(
          onTap: _handleSaveButtonPressed,
          child: Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                begin: Alignment(0.01, -0.72),
                end: Alignment(0.0, 1.0),
                colors: [const Color(0xff385194), const Color(0xff182d66)],
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
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      centerTitle: false,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Container(
            height: 18,
            width: 40,
            child: Image.asset(
              'assets/images/print.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Container(
            height: 15,
            width: 25,
            child: Image.asset(
              'assets/images/pdf.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Container(
            height: 15,
            width: 35,
            child: Image.asset(
              'assets/images/calender.png',
              fit: BoxFit.fill,
              color: Colors.white,
            ),
          ),
        ),
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

// @dart=2.9
import 'package:cybrix/screens/splash.dart';
import 'package:cybrix/ui_elements/bottomNavigation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:cybrix/data/user_data.dart' as user;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class Otp extends StatefulWidget {
  Otp({
    Key key,
    this.phone,
  }) : super(key: key);

  final String phone;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  TextEditingController _verificationCodeController = TextEditingController();
  String verificationCode;
  String code;
  List<String> userNumbers = []; // Option 2
  DatabaseReference numbers;
  var number = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    onStart();

    numbers = FirebaseDatabase.instance
        .reference()
        .child("Companies")
        .child(user.User.database);

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onStart() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              // ToastComponent.showDialog("Authentication Success", context,
              //     gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

            } else {
              FlutterFlexibleToast.showToast(
                  message: "Invalid OTP",
                  toastGravity: ToastGravity.BOTTOM,
                  icon: ICON.ERROR,
                  radius: 50,
                  elevation: 10,
                  imageSize: 15,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                  timeInSeconds: 2);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int resendToken) {
          setState(() {
            verificationCode = verficationID;
            //isLoading=false;
          });
          FlutterFlexibleToast.showToast(
              message: "OTP Sent",
              toastGravity: ToastGravity.BOTTOM,
              icon: ICON.SUCCESS,
              radius: 50,
              elevation: 10,
              imageSize: 15,
              textColor: Colors.white,
              backgroundColor: Colors.black,
              timeInSeconds: 2);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  onPressConfirm() async {
    var code = _verificationCodeController.text.toString();

    if (code == "") {
      FlutterFlexibleToast.showToast(
          message: "Enter verification code",
          toastGravity: ToastGravity.BOTTOM,
          icon: ICON.ERROR,
          radius: 50,
          elevation: 10,
          imageSize: 15,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          timeInSeconds: 2);
      return;
    } else {
      try {
        await FirebaseAuth.instance
            .signInWithCredential(PhoneAuthProvider.credential(
                verificationId: verificationCode, smsCode: code))
            .then((value) async {
          if (value.user != null) {
            print("Authorization is okay");

            await numbers.child("USERS").once().then((DataSnapshot snapshot) {
              Map<dynamic, dynamic> values = snapshot.value;
              values.forEach((key, values) async {
                if (widget.phone == values["ID"].toString()) {
                  if (values["ID"].toString() != null &&
                      values["ID"].toString() != "" &&
                      values["Name"].toString() != null &&
                      values["Name"].toString() != "" &&
                      values["VanNO"].toString() != null &&
                      values["VanNO"].toString() != "") {
                    user.User.number = values["ID"].toString();
                    user.User.name = values["Name"].toString();
                    user.User.vanNo = values["VanNO"].toString();

                    await numbers
                        .child("Details")
                        .once()
                        .then((DataSnapshot snapshot) {
                      Map<dynamic, dynamic> values = snapshot.value;

                      user.User.address = values['Address'].toString();
                      user.User.companyName = values['CompanyName'].toString();
                      user.User.trno = values['TRNNo'].toString();

                      user.User().addUser();
                      FlutterFlexibleToast.showToast(
                          message: "Verification Success",
                          toastGravity: ToastGravity.BOTTOM,
                          icon: ICON.SUCCESS,
                          radius: 50,
                          elevation: 10,
                          imageSize: 15,
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          timeInSeconds: 2);

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BottomBar();
                      }));
                    });
                  } else {
                    user.User().clear();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Splash();
                    }));
                  }
                }
              });
            });
          } else {
            user.User().clear();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Splash();
            }));

            FlutterFlexibleToast.showToast(
                message: "Invalid OTP",
                toastGravity: ToastGravity.BOTTOM,
                icon: ICON.ERROR,
                radius: 50,
                elevation: 10,
                imageSize: 15,
                textColor: Colors.white,
                backgroundColor: Colors.black,
                timeInSeconds: 2);
          }
        });
      } catch (e) {
        user.User().clear();
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Splash();
        }));
        EasyLoading.showError('User not found');
        FocusScope.of(context).unfocus();
        print("nooo");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset("assets/images/loginbackground.png",
                scale: 1.5, fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0, top: 200),
                  child: Container(
                    height: 70,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/login_logo.png'),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 0),
                  child: Text(
                    "Verify your Phone Number",
                    style: TextStyle(
                        //color: MyTheme.accent_color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 0),
                  child: Text(
                    widget.phone,
                    style: TextStyle(
                      //color: MyTheme.accent_color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Container(
                      width: _screen_width * (3 / 4),
                      child: Text(
                          "Enter the verification code that sent to your phone recently.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              //    color: MyTheme.dark_grey, fontSize: 14
                              ))),
                ),
                Container(
                  width: _screen_width * (3 / 4) - 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              child: TextField(
                                controller: _verificationCodeController,
                                autofocus: false,
                                // decoration:
                                // InputDecorations.buildInputDecoration_1(
                                //     hint_text: "123456"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          child: FlatButton(
                            minWidth: MediaQuery.of(context).size.width,
                            //height: 50,
                            color: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                            child: Text(
                              "Confirm",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800),
                            ),
                            onPressed: () {
                              onPressConfirm();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}

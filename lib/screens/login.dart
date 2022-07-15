// @dart=2.9
import 'dart:ui';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/splash.dart';
import 'package:cybrix/ui_elements/bottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  List<dynamic> _locations = [];
  String code;
  List<String> userNumbers = []; // Option 2
  String _selectedLocation;
  DatabaseReference types;
  var number = TextEditingController();
  var database = TextEditingController();

  Future<void> getCountryAndNumbers() async {
    await types.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() {
          _locations.add(values.toString());
        });
      });
    });
  }

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    types = FirebaseDatabase.instance.reference().child("CountryCodes");


    getCountryAndNumbers();
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(77, 102, 169, 1),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset("assets/images/loginbackground.png",
                  scale: 1.5, fit: BoxFit.cover),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25),
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/login_logo.png'),
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 50,
                       // padding: EdgeInsets.only(bottom: 7, left: 5),
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
                            controller: database,
                            maxLines: 1,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.only(left: 20, top: 15),
                              prefixIcon: Icon(
                                Icons.data_usage,
                                size: 25.0,
                                color: Colors.grey,
                              ),
                              hintText: 'Enter Database Name',
                              hintStyle: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 14,
                                //color:  Colors.black,
                              ),
                              //filled: true,
                              border: InputBorder.none,
                              filled: false,
                              isDense: false,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 50,
                            padding: const EdgeInsets.only(),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.flag,
                                  size: 25.0,
                                  color: Colors.grey,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 50,
                                  padding: EdgeInsets.only(
                                    left: 20.0,
                                    top: 10,
                                  ),
                                  child: DropdownButton(
                                    isDense: true,
                                    //itemHeight: 50,
                                    iconSize: 30,
                                    isExpanded: true,
                                    hint: Text('Select Country'),
                                    value: _selectedLocation,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedLocation = newValue;
                                      });
                                      if (_selectedLocation == "UAE") {
                                        setState(() {
                                          code = "+971";
                                        });
                                      }
                                      if (_selectedLocation == "India") {
                                        setState(() {
                                          code = "+91";
                                        });
                                      }
                                      if (_selectedLocation == "Nigeria") {
                                        setState(() {
                                          code = "+234";
                                        });
                                      }
                                      if (_selectedLocation == "Sri Lanka") {
                                        setState(() {
                                          code = "+94";
                                        });
                                      }
                                      if (_selectedLocation == "Kuwait") {
                                        setState(() {
                                          code = "+965";
                                        });
                                      }
                                      if (_selectedLocation == "Saudi Arabia") {
                                        setState(() {
                                          code = "+966";
                                        });
                                      }
                                      if (_selectedLocation == "Oman") {
                                        setState(() {
                                          code = "+968";
                                        });
                                      }
                                      if (_selectedLocation == "Bahrain") {
                                        setState(() {
                                          code = "+973";
                                        });
                                      }
                                      if (_selectedLocation == "Quatar") {
                                        setState(() {
                                          code = "+974";
                                        });
                                      }
                                      print(_selectedLocation);
                                    },
                                    items: _locations.map((location) {
                                      return DropdownMenuItem(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0.0, left: 0),
                                          child: new Text(location),
                                        ),
                                        value: location,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.714,
                        child: Card(
                          elevation: 10,
                          child: Container(
                            child: TextFormField(
                                controller: number,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(left: 20, top: 15),
                                  hintText: 'Enter Mobile Number',
                                  //filled: true,
                                  filled: false,
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    size: 25.0,
                                    color: Colors.grey,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (number.text.isNotEmpty &&
                            database.text.isNotEmpty) {

                          setState(() {
                            User.database=database.text;
                          });

                          if(number.text=="8129902981"){
                            await FirebaseDatabase.instance
                                .reference()
                                .child("Companies")
                                .child(database.text).child("USERS").once().then((DataSnapshot snapshot) {
                              Map<dynamic, dynamic> values = snapshot.value;
                              values.forEach((key, values) async {
                                if (code+number.text== values["ID"].toString()) {
                                  if (values["ID"].toString() != null &&
                                      values["ID"].toString() != "" &&
                                      values["Name"].toString() != null &&
                                      values["Name"].toString() != "" &&
                                      values["VanNO"].toString() != null &&
                                      values["VanNO"].toString() != "") {
                                   User.number = values["ID"].toString();
                                    User.name = values["Name"].toString();
                                    User.vanNo = values["VanNO"].toString();

                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child("Companies")
                                        .child(database.text)
                                        .child("Details")
                                        .once()
                                        .then((DataSnapshot snapshot) {
                                      Map<dynamic, dynamic> values = snapshot.value;

                                      User.address = values['Address'].toString();
                                      User.companyName = values['CompanyName'].toString();
                                      User.trno = values['TRNNo'].toString();

                                      User().addUser();
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
                                    User().clear();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return Splash();
                                        }));
                                  }
                                }
                              });
                            });
                          }else{
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return Otp(
                                    phone: code + number.text,
                                  );
                                }));
                          }


                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 40, right: 40, top: 10, bottom: 10),
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
                        child: Text(
                          ' Login ',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 20,
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
          ],
        ),
      ),
    );
  }
}

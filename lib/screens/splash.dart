// @dart=2.9
import 'dart:ui';
import 'package:adobe_xd/page_link.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/login.dart';
import 'package:cybrix/ui_elements/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  getUser() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("name");
    String number = prefs.getString("number");
    String vanNumber = prefs.getString("vanNo");
    String dbs=prefs.getString("database");
    String company=prefs.getString("companyName");
    String trno=prefs.getString("trno");
    String address=prefs.getString("address");
    int decimal=prefs.getInt("decimal");

    if (name != null && number != null && name!="" && number != "" && dbs != "" && vanNumber != "" ) {
      User.number = number;
      User.name = name;
      User.vanNo = vanNumber;
      User.database=dbs;
      User.trno=trno;
      User.companyName=company;
      User.address=address;
      User.decimals=decimal;

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BottomBar();
      }));
    }
  }

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);


    getUser();
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
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset("assets/images/splashbackground.png",
                scale: 1.5, fit: BoxFit.cover),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.35),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    'It\'s Time To Inspire',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 25,
                      color: const Color(0xfff7fdfd),
                    ),
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                  SizedBox(height: 30,),
                  GestureDetector(
                    onTap: () async {

                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Login();
                            }));

                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 25, right: 25, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -4.76),
                          end: Alignment(0.0, 1.0),
                          colors: [
                            const Color(0xffffffff),
                            const Color(0xff1ebdf2)
                          ],
                          stops: [0.0, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x291ebdf2),
                            offset: Offset(6, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 25,
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
    );
  }
}

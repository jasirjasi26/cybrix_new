// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:cybrix/screens/all_products.dart';
import 'package:cybrix/screens/customers.dart';
import 'package:cybrix/screens/login.dart';
import 'package:cybrix/screens/mis_reports/sales_ledger.dart';
import 'package:cybrix/screens/mis_reports/sales_register.dart';
import 'package:cybrix/screens/mis_reports/stock_reports.dart';
import 'package:cybrix/screens/orders.dart';
import 'package:cybrix/screens/reports/sales_report.dart';
import 'package:cybrix/screens/reports/sales_return_report.dart';
import 'package:cybrix/screens/reports/stock_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../handler/controller.dart';
import '../handler/syncronize.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key key,
  }) : super(key: key);

  @override
  MainDrawerState createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer> {
  bool misHeight = false;
  bool reports = false;


  Future syncToMysql() async {
    await SyncronizationData().fetchAllInfo().then((userList) async {
      EasyLoading.show(status: 'Dont close app. we are on sync...');
      await SyncronizationData().saveToMysqlWith(userList);
      Controller().delete();
      EasyLoading.showSuccess('Sync Success');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 50),
        child: ListView(
          children: <Widget>[
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/van.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.white
                        )),
                  ),
                ),
                title: Text('Van number ' + User.vanNo.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {}),
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/phone.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.white
                        )),
                  ),
                ),
                title: Text(User.number.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) {
                  //      // return DoctorAppoinments();
                  //     }));
                }),
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/customers.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.white
                        )),
                  ),
                ),
                title: Text('Customers',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CustomersList();
                  }));
                }),
            //  : Container(),
            // is_logged_in.value == true
            //     ?
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/product.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.black
                        )),
                  ),
                ),
                title: Text('Products',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AllProductPage(back: true,);
                  }));
                }),
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/images/orders.png",
                            fit: BoxFit.scaleDown, color: Colors.black)),
                  ),
                ),
                title: Text('Orders',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return OrdersPage();
                  }));
                }),
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/misreports.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.white
                        )),
                  ),
                ),
                title: Text('Mis Reports',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  setState(() {
                    misHeight = !misHeight;
                  });
                }),
            SizedBox(height: 5,),
            ///3 types
            ///
            misHeight
                ? ListTile(
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 50.0),
                      child: Text('Sales Register',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SalesRegister();
                      }));
                    })
                : Container(),
            misHeight
                ? ListTile(
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 50.0),
                      child: Text('Stock Reports ',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return StockReports();
                      }));
                    })
                : Container(),
            misHeight
                ? ListTile(
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 50.0),
                      child: Text('Sales Ledger  ',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SalesLedger();
                      }));
                    })
                : Container(),
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/reports.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.white
                        )),
                  ),
                ),
                title: Text('Reports',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  setState(() {
                    reports = !reports;
                  });
                }),

            ///3 types
            ///
            reports
                ? ListTile(
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text('Sales Reports           ',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return SalesReport1();
                          }));
                    })
                : Container(),
            reports
                ? ListTile(
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text('Sales Return Report',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return ReturnsPage1();
                          }));
                    })
                : Container(),
            reports
                ? ListTile(
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text('Stock Report            ',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return StockReports1();
                          }));
                    })
                : Container(),
            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Icon(
                          Icons.sync,
                          color: Colors.black,
                        )),
                  ),
                ),
                title: Text('Sync Data',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () async {
                  await SyncronizationData.isInternet().then((connection) {
                    if (connection) {
                      syncToMysql();
                      print("Internet connection available");
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("No Internet")));
                    }
                  });
                }),

            SizedBox(height: 5,),
            ListTile(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                leading: Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset(
                          "assets/images/logout.png",
                          fit: BoxFit.scaleDown,
                          //    color: Colors.white
                        )),
                  ),
                ),
                title: Text('Logout',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  User().clear();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Login();
                  }));
                }),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
